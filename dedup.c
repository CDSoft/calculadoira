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

#include <assert.h>
#include <dirent.h>
#include <linux/limits.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#include "sha1.h"

#define DIGEST_SIZE             20
#define PARTIAL_CONTENT_SIZE    (4*1024)
#define READ_BLOCK_SIZE         (64*1024)

void help(void)
{
    printf(
        "dedup - Deduplicate files\n"
        "\n"
        "Usage: dedup [--fast] [--safe] [--hidden] [--skip-hidden] directories\n"
        "\n"
        "Options:\n"
        "    --fast          fast file comparisons (only first and last bytes)\n"
        "    --safe          safe file comparisons (all bytes, slower)\n"
        "    --hidden        check hidden (dotted) files\n"
        "    --skip-hidden   ignore hidden files\n"
        "\n"
        "The default options are --skip-hidden and --fast\n"
        "\n"
        "For more information, see https://github.com/CDSoft/dedup\n");
    exit(EXIT_SUCCESS);
}

typedef struct {
    bool skip_hidden;
    bool safe;
} t_opts;

static t_opts opts = {
    .skip_hidden = true,
    .safe = false,
};

typedef struct {
    size_t capacity;
    size_t length;
    char *buffer;
} t_name_list;

typedef struct {
    size_t name_idx;
    t_name_list *name_list;
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

void name_list_init(t_name_list *name_list)
{
    name_list->capacity = 1024;
    name_list->length = 0;
    name_list->buffer = malloc(name_list->capacity);
    if (name_list->buffer == NULL) {
        fprintf(stderr, "Memory allocation error (too many files)\n");
        exit(EXIT_FAILURE);
    }
}

size_t name_list_new(t_name_list *name_list, size_t name_size)
{
    if (name_list->length + name_size + 1 >= name_list->capacity) {
        while (name_list->length + name_size + 1 >= name_list->capacity) {
            name_list->capacity *= 2;
        }
        name_list->buffer = realloc(name_list->buffer, name_list->capacity);
        if (name_list->buffer == NULL) {
            fprintf(stderr, "Memory allocation error (too many files)\n");
            exit(EXIT_FAILURE);
        }
    }
    const size_t name_idx = name_list->length;
    name_list->length += name_size + 1;
    return name_idx;
}

char *name_list_get(const t_name_list *name_list, size_t name_idx) {
    return &name_list->buffer[name_idx];
}

typedef struct {
    size_t capacity;
    size_t length;
    t_name_list names;
    t_file_id *files;
} t_file_list;

void file_list_init(t_file_list *file_list)
{
    file_list->capacity = 16;
    file_list->length = 0;
    file_list->files = malloc(file_list->capacity * sizeof(file_list->files[0]));
    if (file_list->files == NULL) {
        fprintf(stderr, "Memory allocation error (too many files)\n");
        exit(EXIT_FAILURE);
    }
    name_list_init(&file_list->names);
}

t_file_id *file_list_new(t_file_list *file_list)
{
    if (file_list->length == file_list->capacity) {
        file_list->capacity *= 2;
        file_list->files = realloc(file_list->files, file_list->capacity * sizeof(file_list->files[0]));
        if (file_list->files == NULL) {
            fprintf(stderr, "Memory allocation error (too many files)\n");
            exit(EXIT_FAILURE);
        }
    }
    t_file_id *file_id = &file_list->files[file_list->length++];
    file_id->name_list = &file_list->names;
    return file_id;
}

void file_list_drop_last(t_file_list *file_list)
{
    if (file_list->length > 0) {
        file_list->length--;
    }
}

char *file_list_get_name(const t_file_id *file_id)
{
    return name_list_get(file_id->name_list, file_id->name_idx);
}

void join_path(const char *dir, const char *name, char *path)
{
    strcpy(path, dir);
    strcat(path, "/");
    strcat(path, name);
}

size_t scan(const char *path, t_file_list *file_list)
{
    size_t n = 0;
    DIR *d = opendir(path);
    if (d == NULL)
    {
        perror(path);
        return 0; /* ignore unreadable directories */
    }
    assert(d != NULL);
    struct dirent *file;
    while ((file = readdir(d)) != NULL) {
        if (opts.skip_hidden) {
            if (file->d_name[0] == '.') { continue; }
        }
        switch (file->d_type) {
            case DT_DIR:
            {
                if (strcmp(file->d_name, ".") == 0) break;
                if (strcmp(file->d_name, "..") == 0) break;
                char subdir[PATH_MAX];
                join_path(path, file->d_name, subdir);
                n += scan(subdir, file_list);
                break;
            }
            case DT_REG:
            {
                t_file_id *file_id = file_list_new(file_list);
                const size_t name_len = strlen(path) + 1 + strlen(file->d_name);
                file_id->name_idx = name_list_new(&file_list->names, name_len);
                char *name = file_list_get_name(file_id);
                join_path(path, file->d_name, name);

                struct stat st;
                const int ret = stat(name, &st);
                if (ret != 0) {
                    perror(name);
                    file_list_drop_last(file_list);
                    break;
                }
                if (st.st_size == 0) {
                    file_list_drop_last(file_list);
                    break;
                }

                file_id->size = st.st_size;
                file_id->device = st.st_dev;
                file_id->inode = st.st_ino;
                file_id->start_digest_evaluated = false;
                file_id->end_digest_evaluated = false;
                file_id->digest_evaluated = false;
                file_id->vanished = false;
                n++;
                break;
            }
            default:
                break;
        }
    }
    closedir(d);
    return n;
}

const unsigned char *start_digest(t_file_id *file)
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
end:
    file->start_digest_evaluated = true;
    return file->start_digest;
}

const unsigned char *end_digest(t_file_id *file)
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
end:
    file->end_digest_evaluated = true;
    return file->end_digest;
}

const unsigned char *digest(t_file_id *file)
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
end:
    file->digest_evaluated = true;
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

const char *size_unit(size_t size)
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

void print_block(t_file_id *files, size_t first, size_t last)
{
    if (last > first) {
        printf("# Same files (%s)\n", size_unit(files[first].size));
        for (size_t i = first; i <= last; i++) {
            printf("# rm \"%s\"\n", file_list_get_name(&files[i]));
        }
    }
}

int main(int argc, const char *argv[])
{
    t_file_list file_list;
    file_list_init(&file_list);

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--help"       ) == 0) { help(); }
        if (strcmp(argv[i], "-h"           ) == 0) { help(); }
        if (strcmp(argv[i], "--hidden"     ) == 0) { opts.skip_hidden = false; continue; }
        if (strcmp(argv[i], "--skip-hidden") == 0) { opts.skip_hidden = true; continue; }
        if (strcmp(argv[i], "--fast"       ) == 0) { opts.safe = false; continue; }
        if (strcmp(argv[i], "--safe"       ) == 0) { opts.safe = true; continue; }
        const size_t n = scan(argv[i], &file_list);
        printf("# - %s (%zu files)\n", argv[i], n);
    }

    printf("# Memory usage: %lu Mb\n",
            ( sizeof(file_list)
            + file_list.capacity*sizeof(file_list.files[0])
            + file_list.names.capacity
            ) / (1024*1024)
    );

    qsort(file_list.files, file_list.length, sizeof(file_list.files[0]), compare_files);

    /* loop over similar file blocks in the sorted file list */
    size_t lost = 0;
    size_t block_start = 0;
    size_t block_end = 0;
    for (size_t i = 1; i < file_list.length; i++) {
        if (similar_files(&file_list.files[i-1], &file_list.files[i])) {
            block_end = i;
        } else {
            lost += file_list.files[block_start].size * (block_end-block_start);
            print_block(file_list.files, block_start, block_end);
            block_start = i;
            block_end = i;
        }
    }
    lost += file_list.files[block_start].size * (block_end-block_start);
    print_block(file_list.files, block_start, block_end);
    printf("# Lost space: %s\n", size_unit(lost));
}
