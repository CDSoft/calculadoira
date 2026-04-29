section [[
This file is part of Calculadoira.

Calculadoira is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Calculadoira is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Calculadoira.  If not, see <https://www.gnu.org/licenses/>.

For further information about Calculadoira you can visit
https://codeberg.org/cdsoft/calculadoira
]]

version "4.9.3"

help.name "Calculadoira"
help.description "$name compilation, test and installation"

clean "$builddir"

---------------------------------------------------------------------
section "Compilation"
---------------------------------------------------------------------

build.luax.add_global "flags" "-q"

local sources = {
    ls "src/*",
    file "$builddir/version" { vars.version },
}

local calculadoira = build.luax.native "$builddir/calculadoira" { sources }

phony "release" {
    (function()
        local script = build.luax.lua("$builddir/release/.build/calculadoira-${version}-lua/bin/calculadoira.lua") { sources }
        return {
            build.tar "$builddir/release/${version}/calculadoira-${version}-lua.tar.gz" {
                base = "$builddir/release/.build",
                name = "calculadoira-${version}-lua",
                script,
            },
            build.cp "$builddir/release/${version}/calculadoira.lua" { script },
        }
    end)(),
    require "luax-targets" : map(function(target)
        local exe = build.luax[target.name]("$builddir/release/.build/calculadoira-${version}-"..target.name/"bin/calculadoira") { sources }
        return {
            build.tar("$builddir/release/${version}/calculadoira-${version}-"..target.name..".tar.gz") {
                base = "$builddir/release/.build",
                name = "calculadoira-${version}-"..target.name,
                exe,
            },
            build.cp("$builddir/release/${version}/calculadoira-"..target.name..target.exe) { exe }
        }
    end),
}

---------------------------------------------------------------------
section "Installation"
---------------------------------------------------------------------

install "bin" { calculadoira }

---------------------------------------------------------------------
section "Tests"
---------------------------------------------------------------------

rule "run_test" {
    description = "TEST",
    command = { "python3", "$in", calculadoira, "> $out" },
    implicit_in = calculadoira,
}

build "$builddir/tests.txt" { "run_test", "test/tests.py" }

---------------------------------------------------------------------
section "Documentation"
---------------------------------------------------------------------

local ypp = build.ypp : new "ypp.md"
    : add "flags" {
        "-a",
        build.ypp_vars {
            CALCULADOIRA = calculadoira,
        },
        "-l", "doc/run.lua",
    }
    : add "implicit_in" { calculadoira }
    : set "depfile" "$builddir/tmp/$out.d"

ypp "README.md" { "doc/calculadoira.md" }

---------------------------------------------------------------------
section "Shortcuts"
---------------------------------------------------------------------

help "all" "compile, test and generate the documentation"
help "compile" "compile $name"
help "test" "run $name tests"
help "doc" "generate documentation (README.md)"

phony "compile" { calculadoira }
phony "test" { "$builddir/tests.txt" }
phony "doc" { "README.md" }

phony "all" { "compile", "test", "doc" }
default "all"
