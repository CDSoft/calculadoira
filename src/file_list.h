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

#pragma once

#include <stdbool.h>
#include <stdlib.h>

#define DIGEST_SIZE             20
#define PARTIAL_CONTENT_SIZE    (4*1024)
#define READ_BLOCK_SIZE         (64*1024)

typedef struct {
    size_t name_idx;
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

extern t_file_list file_list;

void file_list_init(void);
t_file_id *file_list_new(void);
void file_list_drop_last(void);
char *file_list_get_name(const t_file_id *file_id);
int compare_files(const void *p1, const void *p2);
bool similar_files(t_file_id *f1, t_file_id *f2);
void join_path(const char *dir, const char *name, char *path);
