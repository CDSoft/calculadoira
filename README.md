# Deduplication of files

<p align=center width="100%"><img src="dedup.svg" style="height:64"/></p>

`dedup` is a tool that searches for duplicate files in a set of directories.
It helps you easily identify identical files to free up disk space.

# Installation

## Download from Codeberg

``` sh
$ git clone https://codeberg.org/cdsoft/dedup
$ cd dedup
```

## Compilation and Installation

First generate the Ninja build file:

``` sh
$ bang
```

Then `dedup` can be installed in `~/.local/bin` with:

``` sh
$ ninja install
```

Or just compiled in the `.build` directory with:

``` sh
$ ninja
```

# User Guide

## Basic Syntax

```
dedup [options] directories
```

## Available Options

`--hidden`
:   Include hidden files (starting with a dot) in the analysis

`--skip-hidden`
:   Ignore hidden files (faster, default option)

`--safe`
:   Compare the entire content of files to ensure accurate duplicate detection

`--fast`
:   Only compare the beginning and the end of files (faster, default option)

`--help` or `-h`
:   Display help and exit

## How It Works

`dedup` won't modify the file system.
It just prints the list of duplicate files on the standard output (`stdout`).
Its output can be redirected to a script and modified to, for example, delete some files.

### Usage Example

```sh
# Search for duplicates in the Photos directory
$ dedup ~/Photos > duplicates.sh

# Edit the script to choose which files to delete
$ nano duplicates.sh

# Run the script to delete the selected files
$ sh ./duplicates.sh
```

> [!WARNING]
> The output is a shell script which deletes all the duplicate files.
> All lines are commented by default.
> The user can uncomment some lines to delete files.
> **If you uncomment all lines, all files will be deleted.**
> It's up to you to wisely choose which lines to uncomment!

## Output Format

The output of `dedup` is organized in blocks of identical files.
Each block starts with the filename and its size, followed by the list of duplicate files.
At the end, `dedup` displays the total space that could be freed.

Example output:

```
# image.jpg (2.5 Mb)
# rm "/home/user/Photos/2023/image.jpg"
# rm "/home/user/Photos/Backup/image.jpg"
# rm "/home/user/Documents/image.jpg"

# document.pdf (1.2 Mb)
# rm "/home/user/Documents/document.pdf"
# rm "/home/user/Downloads/document.pdf"

# Lost space: 6.2 Mb
```

## Detection Algorithm

`dedup` uses several steps to identify duplicate files:

1. Sorting files by size (files of different sizes cannot be identical)
2. Checking for hard links (files sharing the same inode)
3. Comparing the beginning of files (first 4 KB)
4. Comparing the end of files (last 4 KB)
5. In `--safe` mode, comparing the complete content of files

This approach optimizes detection speed while maintaining good accuracy.

# Configuration

The configuration files are in `$HOME/.config/dedup/`.

`$HOME/.config/dedup/dedup.ignore`
:   Contains one file pattern per line to exclude directories or files from the analysis.

## Format of `dedup.ignore` File

Each line in the `dedup.ignore` file contains a glob pattern that will be used to exclude files or directories.
For example:

```
*.tmp
.git
node_modules
```

This configuration will ignore all `.tmp` files, `.git` and `node_modules` directories.

# Common Use Cases

## Cleaning Up Duplicate Photos

```sh
$ dedup --safe ~/Photos > photo_duplicates.sh
```

## Analyzing Multiple Directories

```sh
$ dedup ~/Documents ~/Downloads ~/Desktop > duplicates.sh
```

## Analyzing Hidden Files

```sh
$ dedup --hidden ~ > hidden_duplicates.sh
```

# Tips and Best Practices

1. Use the `--safe` option for important files to avoid false positives
2. Always create a backup before deleting files
3. Carefully check the generated script before running it
4. Consider using hard links instead of deletion to save space while preserving files

# Troubleshooting

- If `dedup` is slow on large directories, use the `--fast` and `--skip-hidden` options
- If you encounter access errors, check the permissions of files and directories
- For very large sets of files, consider analyzing by subdirectories

# License

    This file is part of dedup.

    dedup is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    dedup is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with dedup.  If not, see <https://www.gnu.org/licenses/>.

    For further information about dedup you can visit
    https://cdelord.fr/dedup

