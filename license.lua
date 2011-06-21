-- Calculadoira
-- Copyright (C) 2011 Christophe Delord
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
    local keyname = "calculadoira.key"

    local function key(path)
        local f = io.open(path)
        if f then
            local name = f:read "*l"
            local key = f:read "*l"
            f:close()
            name = name:gsub("^%s*(%S*)%s*$", "%1")
            key = tonumber(key, 16)
            for i = 1, #name, 4 do
                key = key + struct.unpack("<I4", name:sub(i, i+3).."\0\0\0")
            end
            return #name>0 and key%2^32==0 and name
        end
    end

    local function check_license()
        if sys.platform == "Windows" then
            os.execute 'title Checking Calculadoira registration'
            os.execute 'color f0'
        end
        local name = key(keyname)
        for i = -1, #arg do
            name = name or key(fs.dirname(arg[i])..fs.sep..keyname)
        end
        if name then
            print("Calculadoira is registered to "..name)
            return
        end
        os.execute 'color 84'
        print [[
Calculadoira is not registered.

If you find Calculadoira useful,
please visit http://cdsoft.fr/calculadoira
to receive a keyfile.

The unregistered version is fully functional
but you have to answer this before continuing:
]]
        math.randomseed(os.time())
        x = math.random(1, 10)
        y = math.random(1, 10)
        io.write(x.." + "..y.." = ")
        z = io.read "*l"
        if tonumber(z) == x+y then
            print "Ok, let's try Calculadoira."
        else
            print "Wrong answer, try again later..."
            os.exit(1)
        end
    end

    check_license()
end
