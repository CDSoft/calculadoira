-- Calculadoira
-- Copyright (C) 2011 - 2015 Christophe Delord
-- http://www.cdsoft.fr/calculadoira
--
-- This file is part of Calculadoira.
--
-- Calculadoira is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published
-- by the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Calculadoira is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Calculadoira.  If not, see <http://www.gnu.org/licenses/>.

do
    os.execute 'title Calculadoira: trial notice'
    os.execute 'cls'
    os.execute 'color 74'
    print [[
+=====================================================================+
| C A L C U L A D O R I A                                             |
| =======================                                             |
|                                                                     |
| Calculadoira is a powerful yet simple to use calculator             |
| designed by programmers and for programmers productivity:           |
| programmable, user defined functions, big numbers, rationnals,      |
| floats, base 2, 8, 10, 16 integers, math functions, ASCII table...  |
|                                                                     |
| This is a demonstration version of Calculadoira.                    |
|                                                                     |
| The demo version is fully functional.                               |
| Anyway you can buy the professionnal version to remove this screen. |
|                                                                     |
| If you find Calculadoira useful, please support it.                 |
|                                                                     |
| The professionnal version is here: http://cdsoft.fr/calculadoira    |
+=====================================================================+
]]
    local t = os.time()
    local tf = t + 10
    while t <= tf do
        local dt = tf-t
        local s = (dt > 1) and "s" or ""
        io.write("\rYou can try Calculadoira in "..dt.." second"..s.."...  ")
        io.flush()
        ps.sleep(0.2)
        t = os.time()
    end
    io.write("\rYou can try Calculadoira right now. Press 'Enter' to continue.")
    io.read "*l"
    os.execute 'title Calculadoira (trial edition)'
    os.execute 'color f0'
end
