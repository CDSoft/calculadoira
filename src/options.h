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

/**
 * @file options.h
 * @brief Command-line options handling for dedup
 *
 * This file provides functions to parse and access command-line options
 * for the dedup application. It handles initialization of program options
 * and provides query functions to check various settings.
 */

#pragma once

#include <stdbool.h>

/**
 * @brief Initialize program options from command-line arguments
 *
 * This function parses the command-line arguments and initializes
 * the internal options structure used by the program.
 *
 * @param argc The number of command-line arguments
 * @param argv The array of command-line argument strings
 */
void options_init(int argc, const char *argv[]);

/**
 * @brief Check if a path should be ignored
 *
 * Determines whether a given file or directory path should be ignored
 * during the deduplication process based on the configured ignore patterns.
 *
 * @param path The file or directory path to check
 * @return true if the path should be ignored, false otherwise
 */
bool ignored(const char *path);

/**
 * @brief Check if hidden files should be scanned
 *
 * Returns the setting that determines whether hidden files and directories
 * (those starting with a dot on Unix-like systems) should be included in
 * the deduplication process.
 *
 * @return true if hidden files should be scanned, false otherwise
 */
bool scan_hidden_files(void);

/**
 * @brief Check if safe mode is enabled
 *
 * In safe mode, the program performs additional checks before modifying
 * files to prevent data loss. This function returns the current setting
 * of this safety feature.
 *
 * @return true if safe mode is enabled, false otherwise
 */
bool safe_check(void);
