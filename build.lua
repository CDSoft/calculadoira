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

rule "luax" { command = "luax -q -o $out $in" }

build "$calculadoira" { "luax", ls "src/*" }

---------------------------------------------------------------------
section "Installation"
---------------------------------------------------------------------

install "bin" "$calculadoira"

---------------------------------------------------------------------
section "Tests"
---------------------------------------------------------------------

rule "run_test" {
    command = "python3 $in $calculadoira > $out",
    implicit_in = "$calculadoira",
}

build "$builddir/tests.txt" { "run_test", "test/tests.py" }

---------------------------------------------------------------------
section "Documentation"
---------------------------------------------------------------------

rule "panda" {
    command = "PATH=$builddir:$$PATH LANG=en panda -t gfm $in -o $out",
    implicit_in = "$calculadoira",
}

build "README.md" { "panda", "doc/calculadoira.md" }

---------------------------------------------------------------------
section "Shortcuts"
---------------------------------------------------------------------

help "all" "compile, test and generate the documentation"
help "compile" "compile $name"
help "test" "run $name tests"
help "doc" "generate documentation (README.md)"

phony "compile" "$calculadoira"
phony "test" { "$builddir/tests.txt" }
phony "doc" { "README.md" }

phony "all" { "compile", "test", "doc" }
default "all"
