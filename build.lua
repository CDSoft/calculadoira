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
http://cdelord.fr/calculadoira
]]

help.name "Calculadoira"
help.description "$name compilation, test and installation"

var "builddir" ".build"

var "calculadoira" "$builddir/calculadoira"

clean "$builddir"

---------------------------------------------------------------------
section "Compilation"
---------------------------------------------------------------------

build "$calculadoira" { ls "src/*.lua",
    command = "luax -o $out $in",
}

---------------------------------------------------------------------
section "Installation"
---------------------------------------------------------------------

install "bin" "$calculadoira"

---------------------------------------------------------------------
section "Tests"
---------------------------------------------------------------------

build "$builddir/tests.txt" { "test/tests.py",
    command = "python3 $in $calculadoira > $out.tmp && mv $out.tmp $out",
    implicit_in = {
        "$calculadoira",
    },
}

---------------------------------------------------------------------
section "Documentation"
---------------------------------------------------------------------

build "README.md" { "doc/calculadoira.md",
    command = "PATH=$builddir:$$PATH LANG=en panda -t gfm $in -o $out",
    implicit_in = {
        "$calculadoira",
    },
}

---------------------------------------------------------------------
section "Shortcuts"
---------------------------------------------------------------------

help "all" "Compile, test and generate the documentation"
help "compile" "Compile $name"
help "install" "Install $name"
help "test" "Run $name tests"
help "doc" "Generate documentation (README.md)"

phony "compile" "$calculadoira"
phony "test" { "$builddir/tests.txt" }
phony "doc" { "README.md" }

phony "all" { "compile", "test", "doc" }
