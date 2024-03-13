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

local F = require "F"
local sys = require "sys"

help.name "Calculadoira"
help.description "$name compilation, test and installation"

local target, args = target(arg)
if #args > 0 then
    F.error_without_stack_trace(args:unwords()..": unexpected arguments")
end

var "builddir" (".build"/(target and target.name))

clean "$builddir"

---------------------------------------------------------------------
section "Compilation"
---------------------------------------------------------------------

rule "luaxc" {
    description = "LUAXC $out",
    command = "luaxc $arg -q -o $out $in",
}

local calculadoira = build("$builddir/calculadoira"..(target or sys).exe) {
    "luaxc",
    ls "src/*",
    arg = target and {"-t", target.name},
}

---------------------------------------------------------------------
section "Installation"
---------------------------------------------------------------------

install "bin" { calculadoira }

if not target then
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

rule "panda" {
    description = "PANDA $in",
    command = "PATH=$builddir:$$PATH LANG=en panda -t gfm $in -o $out",
    implicit_in = calculadoira,
}

build "README.md" { "panda", "doc/calculadoira.md" }
end

---------------------------------------------------------------------
section "Shortcuts"
---------------------------------------------------------------------

help "all" "compile, test and generate the documentation"
help "compile" "compile $name"
if not target then
help "test" "run $name tests"
help "doc" "generate documentation (README.md)"
end

phony "compile" { calculadoira }
if not target then
phony "test" { "$builddir/tests.txt" }
phony "doc" { "README.md" }
end

phony "all" { "compile", target and {} or {"test", "doc"} }
default "all"
