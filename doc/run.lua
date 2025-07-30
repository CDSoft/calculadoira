--[[
Calculadoira
Copyright (C) 2011 - 2025 Christophe Delord
https://codeberg.org/cdsoft/calculadoira

Calculadoira is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Calculadoira is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Calculadoira.  If not, see <http://www.gnu.org/licenses/>.
--]]

local F = require "F"

assert(CALCULADOIRA, "CALCULADOIRA is not defined")

local function not_match(pattern)
    return function(line) return not line:match(pattern) end
end

local function cut_before(pattern, lines)
    if not pattern then return lines end
    return lines : drop_while(not_match(pattern)) : drop(1)
end

local function cut_after(pattern, lines)
    if not pattern then return lines end
    return lines : drop_while_end(not_match(pattern)) : init()
end

local function clean(lines)
    return lines
        : filter(not_match "^loading")
        : drop_while(string.null)
        : drop_while_end(string.null)
end

local function extract(start_pattern, stop_pattern)
    return F.compose {
        clean,
        F.partial(cut_after, stop_pattern),
        F.partial(cut_before, start_pattern),
        string.lines,
    }
end

local function code(prompt, start_pattern, stop_pattern)
    return {
        ("~"):rep(52),
        extract(start_pattern, stop_pattern)(assert(sh.pipe(CALCULADOIRA)(prompt))),
        ("~"):rep(52),
    }
end

function license()
    return code("license", ": license", nil)
end

function screenshot()
    return code("", nil, "loading")
end

function demo(cmd)
    return code(cmd)
end

function run(cmd)
    return code(cmd, "loading", nil)
end
