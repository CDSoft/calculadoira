/* This file is part of dedup.
 *
 * dedup is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * dedup is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with dedup.  If not, see <https://www.gnu.org/licenses/>.
 *
 * For further information about dedup you can visit
 * http://cdelord.fr/dedup
 */

#include "file_list.h"

#include "name_list.h"
#include "options.h"
#include "sha1.h"

#include <stdio.h>
#include <string.h>

t_file_list file_list;

void file_list_init(void)
{
    file_list.capacity = 1024;
    file_list.length = 0;
    file_list.files = malloc(file_list.capacity * sizeof(file_list.files[0]));
    if (file_list.files == NULL) {
        fprintf(stderr, "Memory allocation error (too many files)\n");
        exit(EXIT_FAILURE);
    }
}

t_file_id *file_list_new(void)
{
    if (file_list.length == file_list.capacity) {
        file_list.capacity *= 2;
        file_list.files = realloc(file_list.files, file_list.capacity * sizeof(file_list.files[0]));
        if (file_list.files == NULL) {
            fprintf(stderr, "Memory allocation error (too many files)\n");
            exit(EXIT_FAILURE);
        }
    }
    t_file_id *file_id = &file_list.files[file_list.length++];
    return file_id;
}

void file_list_drop_last(void)
{
    if (file_list.length > 0) {
        file_list.length--;
    }
}

char *file_list_get_name(const t_file_id *file_id)
{
    return name_list_get(file_id->name_idx);
}

static const unsigned char *start_digest(t_file_id *file)
{
    if (file->vanished || file->start_digest_evaluated) { goto end; }
    char buf[PARTIAL_CONTENT_SIZE];
    const char *name = file_list_get_name(file);
    FILE *f = fopen(name, "rb");
    if (f == NULL) {
        perror(name);
        file->vanished = true;
        goto end;
    }
    const size_t len = fread(buf, 1, sizeof(buf), f);
    fclose(f);
    SHA1_CTX ctx;
    SHA1Init(&ctx);
    SHA1Update(&ctx, (const unsigned char*)buf, len);
    SHA1Final((unsigned char *)file->start_digest, &ctx);
    file->start_digest_evaluated = true;
end:
    return file->start_digest;
}

static const unsigned char *end_digest(t_file_id *file)
{
    if (file->vanished || file->end_digest_evaluated) { goto end; }
    char buf[PARTIAL_CONTENT_SIZE];
    const char *name = file_list_get_name(file);
    FILE *f = fopen(name, "rb");
    if (f == NULL) {
        perror(name);
        file->vanished = true;
        goto end;
    }
    if (fseek(f, file->size-PARTIAL_CONTENT_SIZE, SEEK_SET) != 0) {
        perror(name);
        file->vanished = true;
        goto end;
    }
    const size_t len = fread(buf, 1, sizeof(buf), f);
    fclose(f);
    SHA1_CTX ctx;
    SHA1Init(&ctx);
    SHA1Update(&ctx, (const unsigned char*)buf, len);
    SHA1Final((unsigned char *)file->end_digest, &ctx);
    file->end_digest_evaluated = true;
end:
    return file->end_digest;
}

static const unsigned char *digest(t_file_id *file)
{
    if (file->vanished || file->digest_evaluated) { goto end; }
    char buf[READ_BLOCK_SIZE];
    const char *name = file_list_get_name(file);
    FILE *f = fopen(name, "rb");
    if (f == NULL) {
        perror(name);
        file->vanished = true;
        goto end;
    }
    SHA1_CTX ctx;
    SHA1Init(&ctx);
    size_t len;
    while ((len = fread(buf, 1, sizeof(buf), f)) > 0) {
        SHA1Update(&ctx, (const unsigned char*)buf, len);
    }
    fclose(f);
    SHA1Final((unsigned char *)file->digest, &ctx);
    file->digest_evaluated = true;
end:
    return file->digest;
}

int compare_files(const void *p1, const void *p2)
{
    t_file_id *f1 = (t_file_id*)p1;
    t_file_id *f2 = (t_file_id*)p2;

    /* sort by size */
    if (f1->size < f2->size) { return -1; }
    if (f1->size > f2->size) { return +1; }

    /* check inode */
    if (f1->device == f2->device && f1->inode == f2->inode) {
        /* same hard links => sort by name */
        const char *name1 = file_list_get_name(f1);
        const char *name2 = file_list_get_name(f2);
        return strcmp(name1, name2);
    }

    /* check first bytes */
    const unsigned char *start_digest_1 = start_digest(f1);
    const unsigned char *start_digest_2 = start_digest(f2);
    const int start_digest_order = memcmp(start_digest_1, start_digest_2, DIGEST_SIZE);
    if (start_digest_order != 0) { return start_digest_order; }

    /* check last bytes */
    if (f1->size > PARTIAL_CONTENT_SIZE) {
        const unsigned char *end_digest_1 = end_digest(f1);
        const unsigned char *end_digest_2 = end_digest(f2);
        const int end_digest_order = memcmp(end_digest_1, end_digest_2, DIGEST_SIZE);
        if (end_digest_order != 0) { return end_digest_order; }
    }

    /* check complete content */
    if (opts.safe) {
        if (f1->size > 2*PARTIAL_CONTENT_SIZE) {
            const unsigned char *digest_1 = digest(f1);
            const unsigned char *digest_2 = digest(f2);
            const int digest_order = memcmp(digest_1, digest_2, DIGEST_SIZE);
            if (digest_order != 0) { return digest_order; }
        }
    }

    /* sort by name */
    const char *name1 = file_list_get_name(f1);
    const char *name2 = file_list_get_name(f2);
    return strcmp(name1, name2);
}

bool similar_files(t_file_id *f1, t_file_id *f2)
{
    if (f1->size != f2->size) { return false; }
    if (f1->device == f2->device && f1->inode == f2->inode) { return true; }

    /* check first bytes */
    const unsigned char *start_digest_1 = start_digest(f1);
    const unsigned char *start_digest_2 = start_digest(f2);
    const int start_digest_order = memcmp(start_digest_1, start_digest_2, DIGEST_SIZE);
    if (start_digest_order != 0) { return false; }

    /* check last bytes */
    if (f1->size > PARTIAL_CONTENT_SIZE) {
        const unsigned char *end_digest_1 = end_digest(f1);
        const unsigned char *end_digest_2 = end_digest(f2);
        const int end_digest_order = memcmp(end_digest_1, end_digest_2, DIGEST_SIZE);
        if (end_digest_order != 0) { return false; }
    }

    /* check complete content */
    if (opts.safe) {
        if (f1->size > 2*PARTIAL_CONTENT_SIZE) {
            const unsigned char *digest_1 = digest(f1);
            const unsigned char *digest_2 = digest(f2);
            const int digest_order = memcmp(digest_1, digest_2, DIGEST_SIZE);
            if (digest_order != 0) { return false; }
        }
    }

    return true;
}

bool identical_files(t_file_id *f1, t_file_id *f2)
{
    return f1->device == f2->device && f1->inode == f2->inode;
}

void join_path(const char *dir, const char *name, char *path)
{
    strcpy(path, dir);
    strcat(path, "/");
    strcat(path, name);
}
