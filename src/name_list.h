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
 * @file name_list.h
 * @brief File name management system
 *
 * This file provides a centralized registry for file names used throughout
 * the dedup application. It maintains an internal list of file paths and
 * provides functions to add, retrieve, and manage these paths using numeric
 * identifiers instead of string pointers.
 */

#pragma once

#include <stdlib.h>

/**
 * @typedef t_name
 * @brief Identifier type for file names in the name list
 *
 * This type represents a handle to a file name stored in the name list.
 * It is used as an opaque identifier to reference file names without
 * directly manipulating string pointers.
 */
typedef size_t t_name;

/**
 * @brief Initialize the name list system
 *
 * This function initializes the internal data structures used by the
 * name list system. It must be called before any other name_list functions.
 */
void name_list_init(void);

/**
 * @brief Add a new file name to the name list
 *
 * This function creates a new entry in the name list by combining a directory
 * path and a file name. It returns a unique identifier that can be used to
 * retrieve the full path later.
 *
 * @param dir The directory path component
 * @param name The file name component
 * @return A unique identifier (t_name) for the stored path
 */
t_name name_list_new(const char *dir, const char *name);

/**
 * @brief Retrieve a file name from the name list
 *
 * This function retrieves the full file path associated with the given
 * identifier from the name list.
 *
 * @param name The identifier of the file name to retrieve
 * @return A pointer to the full file path string
 */
char *name_list_get(t_name name);

/**
 * @brief Get the number of entries in the name list
 *
 * This function returns the current number of file names stored in the
 * name list.
 *
 * @return The number of entries in the name list
 */
size_t name_list_size(void);
