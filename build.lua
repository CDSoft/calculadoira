section [[
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
]]

var "builddir" ".build"

local sanitize = false

build.C
    : set "cc" "clang"
    : add "cflags" {
        "-std=gnu2x",
        "-O3",
        "-ferror-limit=1",
        "-Wall",
        "-Wextra",
        "-Wstrict-prototypes",
        "-Wmissing-field-initializers",
        "-Wmissing-prototypes",
        "-Wmissing-declarations",
        "-Werror=switch-enum",
        "-Werror=implicit-fallthrough",
        "-Werror=missing-prototypes",
        "-Werror",
        sanitize and {
            "-O0",
            "-g",
            "-fno-omit-frame-pointer",
            "-fno-optimize-sibling-calls",
            "-fsanitize=address",
            "-fsanitize=undefined",
            "-fsanitize=implicit-conversion",
            "-fsanitize=local-bounds",
            "-fsanitize=nullability-arg",
            "-fsanitize=nullability-assign",
            "-fsanitize=nullability-return",
        } or {},
    }
    : add "ldflags" {
        sanitize and {
            "-fsanitize=address",
            "-fsanitize=undefined",
        } or {
            "-s",
        },
    }

local dedup = build.C:executable "$builddir/dedup" { ls "src/*.c" }
default { dedup }
install "bin" { dedup }
