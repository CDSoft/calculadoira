#!/usr/bin/env bl

do
    local keyname = "calculadoira.key"

    local function key(path)
        path = path:gsub("\\", "/")
        path = path:gsub("[^/]*$", "")
        local f = io.open(path..keyname)
        if f then
            local name = f:read "*l"
            local key = f:read "*l"
            f:close()
            name = name:gsub("^%s*", ""):gsub("%s*$", "")
            key = tonumber(key, 16)
            for i = 1, #name, 4 do
                key = key + struct.unpack("<I4", name:sub(i, i+3).."\0\0\0")
            end
            if key%2^32 == 0 then
                return name
            end
        end
    end

    local function check_license()
        for i = 0, #arg do
            local name = key(arg[i])
            if name then
                print("Calculadoira is registered to "..name)
                return
            end
        end
        print [[
Calculadoira is not registered.

If you find Calculadoira useful,
please visit http://cdsoft.fr/calculadoira
to receive a keyfile.

The unregistered version is fully functional
but you have to answer this before continuing:
]]
        math.randomseed(os.time())
        x = math.random(0, 10)
        y = math.random(0, 10)
        io.write(x.." + "..y.." = ")
        z = io.read("*l")
        if tonumber(z) == x+y then
            print("Ok, let's try Calculadoira.")
        else
            print("Wrong answer, try again later...")
            os.exit(1)
        end
    end

    check_license()
end
