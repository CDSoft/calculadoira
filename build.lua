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

help.name "Calculadoira"
help.description "$name compilation, test and installation"

var "builddir" ".build"

clean "$builddir"

---------------------------------------------------------------------
section "Compilation"
---------------------------------------------------------------------

local targets = F(require "sys".targets):map(F.partial(F.nth, "name"))
local target, ext = nil, ""
F(arg) : foreach(function(a)
    if targets:elem(a) then
        if target then F.error_without_stack_trace("multiple target definition", 2) end
        target = a
        if target:match"windows" then ext = ".exe" end
    else
        F.error_without_stack_trace(a..": unknown argument")
    end
end)

rule "luaxc" {
    command = "luaxc $arg -o $out $in",
}

local calculadoira = build("$builddir/calculadoira"..ext) {
    "luaxc",
    ls "src/*",
    arg = target and {"-t", target},
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
    command = { "python3", "$in", calculadoira, "> $out" },
    implicit_in = calculadoira,
}

build "$builddir/tests.txt" { "run_test", "test/tests.py" }

---------------------------------------------------------------------
section "Documentation"
---------------------------------------------------------------------

rule "panda" {
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
