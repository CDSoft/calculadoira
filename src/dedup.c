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
 * @file dedup.c
 * @brief Main program entry point for the dedup application
 *
 * This file contains the main function that orchestrates the duplicate file
 * detection process. It initializes the necessary subsystems, processes
 * command-line options, and executes the file scanning and duplicate detection
 * workflow in the correct sequence.
 */

#include "file_list.h"
#include "name_list.h"
#include "options.h"

/**
 * @brief Main entry point for the dedup application
 *
 * This function implements the high-level workflow of the dedup application:
 * 1. Initialize the name list system for file path management
 * 2. Initialize the file list system for file collection and analysis
 * 3. Process command-line arguments and options
 * 4. Sort the collected files for efficient duplicate detection
 * 5. Identify and display similar or duplicate files
 *
 * @param argc The number of command-line arguments
 * @param argv An array of command-line argument strings
 * @return Exit status code (0 for success)
 */

int main(int argc, const char *argv[])
{
    name_list_init();
    file_list_init();
    options_init(argc, argv);
    file_list_sort();
    file_list_print_similar_files();
    return EXIT_SUCCESS;
}
