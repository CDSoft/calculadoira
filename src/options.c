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

#include <ctype.h>
#include <linux/limits.h>
#include <stdio.h>
#include <string.h>

t_opts opts = {
    .skip_hidden = true,
    .safe = false,
    .ignore_patterns = NULL,
    .nb_ignore_patterns = 0,
};

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

void read_conf(void)
{
    char ignore_file[PATH_MAX];
    sprintf(ignore_file, "%s/.config/dedup/dedup.ignore", getenv("HOME"));
    FILE *f = fopen(ignore_file, "rt");
    if (f != NULL) {
        ssize_t ret;
        do {
            char *pattern = NULL;
            size_t n = 0;
            if ((ret = getline(&pattern, &n, f)) > 0) {
                while (ret > 0 && isspace(pattern[ret-1])) {
                    pattern[ret-1] = '\0';
                    ret--;
                }
                opts.nb_ignore_patterns++;
                opts.ignore_patterns = realloc(opts.ignore_patterns, opts.nb_ignore_patterns*sizeof(opts.ignore_patterns[0]));
                opts.ignore_patterns[opts.nb_ignore_patterns-1] = pattern;
            } else {
                free(pattern);
            }
        } while (ret > 0);
        fclose(f);
    }
}

bool ignored(const char *path)
{
    for (size_t i = 0; i < opts.nb_ignore_patterns; i++) {
        if (fnmatch(opts.ignore_patterns[i], path, FNM_PATHNAME | FNM_PERIOD | FNM_EXTMATCH) == 0) {
            return true;
        }
    }
    return false;
}
