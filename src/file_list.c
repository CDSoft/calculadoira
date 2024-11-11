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
#include "path.h"
#include "sha1.h"

#include <libgen.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MINIMAL_FILE_SIZE       1024
#define PARTIAL_CONTENT_SIZE    (4*1024)
#define READ_BLOCK_SIZE         (4*1024)

#define DIGEST_SIZE             20

typedef struct {
    t_name name;
    size_t device, inode;
    size_t size;
    unsigned char start_digest[DIGEST_SIZE];
    unsigned char end_digest[DIGEST_SIZE];
    unsigned char digest[DIGEST_SIZE];
    bool start_digest_evaluated;
    bool end_digest_evaluated;
    bool digest_evaluated;
    bool vanished;
} t_file_id;

typedef struct {
    size_t capacity;
    size_t length;
    t_file_id *files;
} t_file_list;

static t_file_list file_list;

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

static char *file_list_get_name(const t_file_id *file_id)
{
    return name_list_get(file_id->name);
}

static const t_file_id *file_list_new(const char *path, const char *name)
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
    memset(file_id, 0, sizeof(t_file_id));
    file_id->name = name_list_new(path, name);

    struct stat st;
    const int ret = stat(file_list_get_name(file_id), &st);
    if (ret != 0) {
        perror(file_list_get_name(file_id));
        file_list.length--;
        return NULL;
    }
    if (st.st_size < MINIMAL_FILE_SIZE) {
        file_list.length--;
        return NULL;
    }

    file_id->size = st.st_size;
    file_id->device = st.st_dev;
    file_id->inode = st.st_ino;

    return file_id;
}

size_t file_list_scan(const char *path)
{
    if (ignored(path)) { return 0; }
    size_t n = 0;
    DIR *d = opendir(path);
    if (d == NULL) {
        perror(path);
        return 0; /* ignore unreadable directories */
    }
    struct dirent *file;
    while ((file = readdir(d)) != NULL) {
        if (file->d_name[0] == '.' && !scan_hidden_files()) { continue; }
        switch (file->d_type) {
            case DT_DIR:
            {
                if (strcmp(file->d_name, ".") == 0) break;
                if (strcmp(file->d_name, "..") == 0) break;
                char subdir[strlen(path) + 1 + strlen(file->d_name) + 1];
                join_path(path, file->d_name, subdir);
                n += file_list_scan(subdir);
                break;
            }
            case DT_REG:
            {
                if (file_list_new(path, file->d_name) != NULL) {
                    n++;
                }
                break;
            }
            default:
                break;
        }
    }
    closedir(d);
    return n;
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

static int compare_files(const void *p1, const void *p2)
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
    if (safe_check()) {
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

static bool similar_files(t_file_id *f1, t_file_id *f2)
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
    if (safe_check()) {
        if (f1->size > 2*PARTIAL_CONTENT_SIZE) {
            const unsigned char *digest_1 = digest(f1);
            const unsigned char *digest_2 = digest(f2);
            const int digest_order = memcmp(digest_1, digest_2, DIGEST_SIZE);
            if (digest_order != 0) { return false; }
        }
    }

    return true;
}

void file_list_sort(void)
{
    qsort(file_list.files, file_list.length, sizeof(file_list.files[0]), compare_files);
}

size_t file_list_size(void)
{
    return sizeof(file_list) + file_list.capacity*sizeof(file_list.files[0]);
}

static const volatile char *size_unit(size_t size)
{
    static const struct { size_t k; size_t u; const char *name; } units[4] = {
        {4, 1024*1024*1024, "Gb"},
        {4,      1024*1024, "Mb"},
        {4,           1024, "Kb"},
        {0,              1, "bytes"},
    };
    static char out[64];
    out[0] = '\0';
    for (size_t i = 0; i < 4; i++) {
        if (size >= units[i].k*units[i].u) {
            sprintf(out, "%zu %s", size/units[i].u, units[i].name);
            break;
        }
    }
    return out;
}

static size_t print_block(size_t first, size_t last)
{
    t_file_id *files = file_list.files;

    bool files_have_different_inodes = false;
    for (size_t i = first+1; i <= last; i++) {
        if (files[i].device != files[first].device || files[i].inode != files[first].inode) {
            files_have_different_inodes = true;
            break;
        }
    }
    if (!files_have_different_inodes) { return 0; }

    printf("\n");
    printf("# %s (%s)\n", basename(file_list_get_name(&files[first])), size_unit(files[first].size));

    size_t lost = 0;

    for (size_t i = first; i <= last; i++) {

        printf("# rm \"%s\"\n", file_list_get_name(&files[i]));

        bool new_file = true;
        for (size_t j = first; j < i; j++) {
            if (files[i].device == files[j].device && files[i].inode == files[j].inode) {
                new_file = false;
                break;
            }
        }
        if (new_file) {
            lost += files[i].size;
        }

    }

    return lost;
}

void file_list_print_similar_files(void)
{
    /* loop over similar file blocks in the sorted file list */
    size_t lost = 0;
    size_t block_start = 0;
    size_t block_end = 0;
    for (size_t i = 1; i < file_list.length; i++) {
        if (similar_files(&file_list.files[i-1], &file_list.files[i])) {
            block_end = i;
        } else {
            lost += print_block(block_start, block_end);
            block_start = i;
            block_end = i;
        }
    }
    lost += print_block(block_start, block_end);
    printf("\n");
    printf("# Lost space: %s\n", size_unit(lost));
}
