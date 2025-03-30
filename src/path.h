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
 * @file path.h
 * @brief Path manipulation utilities
 *
 * This file provides functions to manipulate file paths.
 */

#pragma once

/**
 * @brief Joins a directory path and a file name into a complete path
 *
 * This function combines a directory path and a file name to create a complete
 * file path.
 *
 * @param dir The directory path
 * @param name The file name to append to the directory
 * @param path The buffer where the resulting path will be stored (must be pre-allocated)
 *
 * @note The caller is responsible for ensuring that the path buffer is large enough
 *       to hold the combined path.
 */
void join_path(const char *dir, const char *name, char *path);
