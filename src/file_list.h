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
 * @file file_list.h
 * @brief File collection and duplicate detection system
 *
 * This file provides functionality for scanning directories, collecting file information,
 * and identifying similar or duplicate files. It manages an internal list of files
 * and provides methods to initialize, populate, sort, and analyze this list.
 */

#pragma once

#include <stdbool.h>
#include <stdlib.h>

/**
 * @brief Initialize the file list system
 *
 * This function initializes the internal data structures used by the
 * file list system. It must be called before any other file_list functions.
 */
void file_list_init(void);

/**
 * @brief Scan a directory path and add files to the file list
 *
 * This function recursively scans the specified directory path and adds all
 * discovered files to the internal file list. Each file's metadata and content
 * information is collected for later analysis.
 *
 * @param path The directory path to scan
 * @return The number of files added to the list during this scan
 */
size_t file_list_scan(const char *path);

/**
 * @brief Sort the file list for efficient duplicate detection
 *
 * This function sorts the internal file list using criteria that optimize
 * the process of identifying similar or duplicate files. This should be called
 * after scanning and before analyzing for duplicates.
 */
void file_list_sort(void);

/**
 * @brief Get the number of files in the file list
 *
 * This function returns the current number of files stored in the file list.
 *
 * @return The number of files in the list
 */
size_t file_list_size(void);

/**
 * @brief Identify and display similar or duplicate files
 *
 * This function analyzes the file list to identify similar or duplicate files
 * based on their content and metadata, then outputs the results to the user.
 * The file list should be populated and sorted before calling this function.
 */
void file_list_print_similar_files(void);
