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

version "4.8.4"

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
    build.tar "$builddir/release/${version}/calculadoira-${version}-lua.tar.gz" {
        base = "$builddir/release/.build",
        name = "calculadoira-${version}-lua",
        build.luax.lua("$builddir/release/.build/calculadoira-${version}-lua/bin/calculadoira.lua") { sources },
    },
    require "targets" : map(function(target)
        return build.tar("$builddir/release/${version}/calculadoira-${version}-"..target.name..".tar.gz") {
            base = "$builddir/release/.build",
            name = "calculadoira-${version}-"..target.name,
            build.luax[target.name]("$builddir/release/.build/calculadoira-${version}-"..target.name/"bin/calculadoira") { sources },
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

local ypp = build.ypp_pandoc : new "ypp.md"
    : add "flags" {
        "-a",
        build.ypp_vars {
            CALCULADOIRA = calculadoira,
        },
        "-l", "doc/run.lua",
    }
    : add "implicit_in" { calculadoira }

local pandoc = build.pandoc_gfm : new "pandoc.md"
    : add "flags" {
        "--tab-stop=8",
    }

pipe { ypp, pandoc } "README.md" { "doc/calculadoira.md" }

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
