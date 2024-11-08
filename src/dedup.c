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

#define _GNU_SOURCE

#include "file_list.h"
#include "name_list.h"
#include "options.h"

#include <assert.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define MINIMAL_FILE_SIZE       1024

static size_t scan(const char *path)
{
    if (ignored(path)) { return 0; }
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
                n += scan(subdir);
                break;
            }
            case DT_REG:
            {
                t_file_id *file_id = file_list_new();
                file_id->name_idx = name_list_new(strlen(path) + 1 + strlen(file->d_name));
                char *name = file_list_get_name(file_id);
                join_path(path, file->d_name, name);

                struct stat st;
                const int ret = stat(name, &st);
                if (ret != 0) {
                    perror(name);
                    file_list_drop_last();
                    break;
                }
                if (st.st_size < MINIMAL_FILE_SIZE) {
                    file_list_drop_last();
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
    printf("# Same files (%s)\n", size_unit(files[first].size));

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

int main(int argc, const char *argv[])
{
    read_conf();
    name_list_init();
    file_list_init();

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--help"       ) == 0) { help(); }
        if (strcmp(argv[i], "-h"           ) == 0) { help(); }
        if (strcmp(argv[i], "--hidden"     ) == 0) { opts.skip_hidden = false; continue; }
        if (strcmp(argv[i], "--skip-hidden") == 0) { opts.skip_hidden = true; continue; }
        if (strcmp(argv[i], "--fast"       ) == 0) { opts.safe = false; continue; }
        if (strcmp(argv[i], "--safe"       ) == 0) { opts.safe = true; continue; }
        char *path = realpath(argv[i], NULL);
        const size_t n = scan(path);
        printf("# %s (%zu files)\n", path, n);
        free(path);
    }

    printf("# Memory usage: %lu Mb\n",
            ( sizeof(file_list) + file_list.capacity*sizeof(file_list.files[0])
            + sizeof(name_list) + name_list.capacity
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
            lost += print_block(block_start, block_end);
            block_start = i;
            block_end = i;
        }
    }
    lost += print_block(block_start, block_end);
    printf("\n");
    printf("# Lost space: %s\n", size_unit(lost));
}
