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

#include "options.h"

#include "name_list.h"
#include "file_list.h"
#include "path.h"

#include <ctype.h>
#include <fnmatch.h>
#include <linux/limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char *ignore_file = ".config/dedup/dedup.ignore";

typedef struct {
    bool show_hidden;
    bool safe;
    char **ignore_patterns;
    size_t nb_ignore_patterns;
} t_opts;

t_opts opts = {
    .show_hidden = false,
    .safe = false,
    .ignore_patterns = NULL,
    .nb_ignore_patterns = 0,
};

static void help(void)
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

static void read_conf(void)
{
    const char *home = getenv("HOME");
    char ignore_file_path[strlen(home) + 1 + strlen(ignore_file) + 1];
    join_path(home, ignore_file, ignore_file_path);
    FILE *f = fopen(ignore_file_path, "rt");
    if (f == NULL) { return; }
    while (true) {
        char *pattern = NULL;
        size_t n = 0;
        ssize_t ret;
        if ((ret = getline(&pattern, &n, f)) <= 0) {
            free(pattern);
            break;
        }
        while (ret > 0 && isspace(pattern[ret-1])) {
            pattern[ret-1] = '\0';
            ret--;
        }
        if (ret == 0) {
            free(pattern);
            continue;
        }
        opts.nb_ignore_patterns++;
        opts.ignore_patterns = realloc(opts.ignore_patterns, opts.nb_ignore_patterns*sizeof(opts.ignore_patterns[0]));
        opts.ignore_patterns[opts.nb_ignore_patterns-1] = pattern;
    }
    fclose(f);
}

void options_init(int argc, const char *argv[])
{
    read_conf();
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--help"       ) == 0) { help(); }
        if (strcmp(argv[i], "-h"           ) == 0) { help(); }
        if (strcmp(argv[i], "--hidden"     ) == 0) { opts.show_hidden = true; continue; }
        if (strcmp(argv[i], "--skip-hidden") == 0) { opts.show_hidden = false; continue; }
        if (strcmp(argv[i], "--fast"       ) == 0) { opts.safe = false; continue; }
        if (strcmp(argv[i], "--safe"       ) == 0) { opts.safe = true; continue; }
        char *path = realpath(argv[i], NULL);
        if (path != NULL) {
            const size_t n = file_list_scan(path);
            printf("# %s (%zu files)\n", path, n);
            free(path);
        }
    }
    printf("# Memory usage: %lu Mb\n",
            ( file_list_size()
            + name_list_size()
            ) / (1024*1024)
    );
}

bool ignored(const char *path)
{
    for (size_t i = 0; i < opts.nb_ignore_patterns; i++) {
        if (fnmatch(opts.ignore_patterns[i], path, FNM_PATHNAME | FNM_PERIOD) == 0) {
            return true;
        }
    }
    return false;
}

bool scan_hidden_files(void)
{
    return opts.show_hidden;
}

bool safe_check(void)
{
    return opts.safe;
}
