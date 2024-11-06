# Deduplication of files

`dedup` searches for duplicate files in a set of directories.

# Installation

First download `dedup` from Github:

``` sh
$ git clone https://github.com/CDSoft/dedup
$ cd dedup
```

`dedup` can be installed in `~/.local/bin` with:

``` sh
$ ninja install
```

Or just compiled in `.build` with:

``` sh
$ ninja
```

# Usage

Syntax:

    dedup [options] directories

Where options are:

`--hidden`
:   Show hidden files

`--skip-hidden`
:   Skip hidden files (faster)

`--safe`
:   Compare the whole files

`--fast`
:   Only compare the beginning and the end of the files (faster)

`dedup` won't modify the file system.
It just prints the list of duplicate files on `stdout`.
Its output can be redirected to a script and modified to e.g. delete some files.

> [!WARNING]
> The output is a shell script which deletes all the duplicate files.
> All lines are commented.
> The user can uncomment some lines to delete files.
> **If you uncomment all lines, all files will be deleted.**
> It's up to you to wisely choose which lines to uncomment!

# Configuration

The configuration files are in `$HOME/.config/dedup/`.

`$HOME/.config/dedup/dedup.ignore`
:   contains one file pattern per line to exclude directories.

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

