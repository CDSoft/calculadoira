#!/usr/bin/env luax

local license = [[
Calculadoira
Copyright (C) 2011 - 2024 Christophe Delord
https://github.com/cdsoft/calculadoira

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
]]

local sys = require "sys"
local fs = require "fs"
local terminal = require "term"
local fun = require "F"
local identity = fun.id
local sh = require "sh"

local bn = require "bn"

local version = "4.6.1"

local help = fun.I{v=version}[[
+---------------------------------------------------------------------+
|      CALCULADOIRA       v. $(v ) |  github.com/cdsoft/calculadoira  |
|----------------------------------+----------------------------------|
| Modes:                           | Numbers:                         |
|     hex oct bin float str reset  |     binary: 0b...    |  sep ""   |
|     hex8/16/32/64 ...            |     octal : 0o...    |  sep " "  |
|----------------------------------|     hexa  : 0x...    |  sep "_"  |
| Variables and functions:         |     float : 1.2e-3               |
|     variable = expression        | Chars     : "abcd" or 'abcd'     |
|     function(x, y) = expression  |             "<abcd" or ">abcd"   |
| Multiple statements:             | Booleans  : true or false        |
|     expr1, ..., exprn            |----------------------------------|
|----------------------------------| Operators:                       |
| Builtin functions:               |     or xor and not               |
|     see help                     |     < <= > >= == !=              |
|----------------------------------|     cond?expr:expr               |
| Commands: ? help license         |     + - * / // % ** !            |
|           edit                   |     | ^ & >> << ~                |
+---------------------------------------------------------------------+
]]

local default_ini = "calculadoira.ini"

local longhelp = fun.I{default_ini=default_ini, math=math}[[

Constants                   Value
=========================== ===============================================

nan, NaN                    Not a Number
inf, Inf                    Infinite
pi                          $(math.pi)
e                           $(math.exp(1))

Operators / functions       Description
=========================== ===============================================

+x, -x
x + y, x - y                sum, difference
x * y, x / y, x % y         product, division
x // y, x % y               integral division, modulo
x ** y                      x to the power y

~x                          bitwise not
x | y, x ^ y, x & y         bitwise or, xor, and
x << n, x >> n              x left or right shifted by n bits

not x                       boolean not
x or y, x xor y, x and y    boolean or, xor, and
x < y, x <= y               comparisons
x > y, x >= y
x == y, x != y, x ~= y

x!                          factorial of x

int(x)                      x converted to int
float(x)                    x converted to float
rat(x)                      x converted to rat

abs(x)                      absolute value of x
ceil(x)                     smallest integer larger than or equal to x
floor(x)                    largest integer smaller than or equal to x
round(x)                    round to the nearest integer
trunc(x)                    tround toward zero
mantissa(x)                 m such that x = m2e, |m| is in [0.5, 1[
exponent(x)                 e such that x = m2e, e is an integer
int(x)                      integral part of x
fract(x)                    fractional part of x
fmod(x, y)                  remainder of the division of x by y
ldexp(m, e)                 m*2**e (e should be an integer)
pow(x, y)                   x to the power y
min(...), max(...)          minimum / maximum value among its arguments

sqr(x)                      square of x (x**2)
sqrt(x)                     square root of x (x**0.5)
cbrt(x)                     cubic root of x (x**(1/3))

cos(x), acos(x), cosh(x)    trigonometric functions
sin(x), asin(x), sinh(x)
tan(x), atan(x), tanh(x)
atan(y, x), atan2(y, x)     arc tangent of y/x (in radians)
deg(x)                      angle x (given in radians) in degrees
rad(x)                      angle x (given in degrees) in radians

exp(x)                      e**x
exp2(x)                     2**x
expm1(x)                    e**x - 1
log(x), ln(x)               logarithm of x in base e
log10(x), log2(x)           logarithm of x in base 10, 2
log1p(x)                    log(1 + x)
logb(x)                     log2(|x|)
log(x, b)                   logarithm of x in base b

random()                    random number in [0, 1[
random(m)                   random integer in [1, m]
random(m, n)                random integer in [m, n]
randomseed(x)               x as the "seed" for the pseudo-random generator

float2ieee(x)               IEEE 754 representation of x (32 bits)
ieee2float(n)               32 bit float value of the IEEE 754 integer n
double2ieee(x)              IEEE 754 representation of x (64 bits)
ieee2double(n)              64 bit float value of the IEEE 754 integer n

erf(x)                      error function
erfc(x)                     complementary error function
gamma(x)                    gamma function
lgamma(x)                   log-gamma function

isfinite(x)                 true if x is finite
isinf(x)                    true if x is infinite
isnan(x)                    true if x is not a number

copysign(x, y)              sign(y) * |x|
fdim(x, y)                  x - y if x>y, 0 otherwise
hypot(x, y)                 sqrt(x**2 + y**2)
nextafter(x, y)             next float after x in the direction of y
remainder(x, y)             remainder of x/y
scalbn(x, n)                x * 2**n

fma(x, y, z)                x*y + z

Display modes
=============

dec, hex, oct, bin and str commands change the display mode.
When enabled, the integer result is displayed in
hexadecimal, octal, binary and/or as a string.
float mode shows float values and their IEEE encoding.
str mode show the ASCII representation of 1 upto 4 chars.

dec, hex, oct, bin can have suffixes giving the number of bits
to be displayed (e.g. hex16 shows 16 bit results). Valid suffixes
are 8, 16, 32, 64 and 128.

float can have suffixes giving the size of floats (32 or 64).

The reset command reset the display mode.

The sep command set the digit separator. valid separators are:
- sep "": no separator
- sep " ": digits separated with space
- sep "_": digits separated with an underscore

Note: the space separator cannot be used to enter numbers.

Blocks
======

A block is made of several expressions separated by `,` or ` `.
The value of the block is the value of the last expression.

e.g. x=1, y=2, x+y defines x=1, y=2 and returns 3

Definitions made in functions are local.

e.g. f(x) = (y=1, x+y) defines a function f that
returns x+1. y is local to f.

Local definitions can be functions.

e.g. fact(n) = (f(n,p)=(n==1)?p:f(n-1,n*p), f(n,1))

Operator precedence
===================

From highest to lowest precedence:

Operator family             Syntax
=========================== =================
Precedence overloading      (...)
Function evaluation         f(...)
Factorial                   x!
Exponentiation              x**y
Unary operators             +x, -y, ~z
Multiplicative operators    * / % & << >>
Additive operators          + - | ^
Relational operators        < <= > >= == !=
Logical not                 not x
Logical and                 and
Logical or                  or xor
Ternary operator            x ? y : z
Assignement                 x = y
Blocks                      expr1, ..., exprn

Other commands              Description
=========================== ===========================

edit                        Edit $(default_ini)
bye exit quit               Quit
?                           Help summary
help                        Full help
license                     Show Calculadoira license

Credits
=======

Calculadoira: https://github.com/cdsoft/calculadoira
LuaX        : https://github.com/cdsoft/luax

"Calculadoira" means "Calculator" in Occitan.
]]

local config

local running = false

function Mode()
    local self = {bits=nil}
    function self.set(...)
        if not running then return end
        for _, mode in ipairs({...}) do
            self[mode] = true
        end
    end
    function self.toggle(mode)
        if not running then return end
        self[mode] = not self[mode]
        if (mode == "dec" or mode == "hex" or mode == "oct" or mode == "bin")
        and not self["dec"] and not self["hex"] and not self["oct"] and not self["bin"]
        and not self["float"] then
            self.bits = nil
        end
        if mode == "float" and self["float"] and (self.bits ~= 32 and self.bits ~= 64) then
            self.bits = 32
        end
    end
    function self.set_bits(bits)
        if not running then return end
        self.bits = bits and math.tointeger(bn.Int(bits):tonumber())
        if self.bits ~= 32 and self.bits ~= 64 then
            self["float"] = false
        end
    end
    function self.clear()
        for k,v in pairs(self) do
            if v == true then self[k] = false end
        end
        self.bits = nil
    end
    return self
end

local mode = Mode()

function Virtual(obj, method)
    return function()
        error(string.format("%s.%s not implemented", obj.class, method))
    end
end

function Expr(class)
    local self = {class=(class or "Expr")}
    self.eval = Virtual(self, "eval")
    self.call = Virtual(self, "call")
    self.dis = Virtual(self, "dis")
    function self.evaluate(env)
        running = true
        local ok, val = pcall(self.eval, env)
        running = false
        if not ok then
            assert(type(val) == "string")
            val = val:gsub(".*:%d+:", "")
        end
        return ok, val
    end
    return self
end

function Comment(comment)
    local self = Expr "Comment"
    function self.dis() return comment end
    function self.eval() return nil end
    return self
end

function Quit()
    local self = Expr "Quit"
    function self.eval() os.exit() end
    return self
end

function Edit()
    local self = Expr "Edit"
    function self.eval() config.edit() end
    return self
end

function Help()
    local self = Expr "Help"
    function self.eval() print(help) end
    return self
end

function LongHelp()
    local self = Expr "LongHelp"
    function self.eval() print(help) print(longhelp) end
    return self
end

function License()
    local self = Expr "License"
    function self.eval() print(license) end
    return self
end

function Env(up)
    local self = {}
    local vars = {}
    function self.set(name, value) vars[name] = Object(value) end
    function self.get(name) return vars[name] or (up and up.get(name)) end
    function self.push() return Env(self) end
    return self
end

function Object(val)
    if type(val) == "table" and type(val.eval) == "function" then
        return val
    else
        local self = Expr "Object"
        function self.eval() return val end
        return self
    end
end

function float2ieee(x)
    mode.set("float")
    mode.set_bits(32)
    x = bn.Float(x):tonumber()
    if type(x) == 'number' then
        return bn.Int((string.unpack("I4", string.pack("f", x))))
    end
end

function ieee2float(x)
    mode.set("float")
    mode.set_bits(32)
    x = bn.Int(x):tonumber()
    if type(x) == 'number' then
        return bn.Float((string.unpack("f", string.pack("I4", x))))
    end
end

function double2ieee(x)
    mode.set("float")
    mode.set_bits(64)
    x = bn.Float(x):tonumber()
    if type(x) == 'number' then
        local lo, hi = string.unpack("I4I4", string.pack("d", x))
        return bn.bor(bn.lshift(bn.Int(hi), 32), bn.Int(lo))
    end
end

function ieee2double(x)
    mode.set("float")
    mode.set_bits(64)
    local lo = bn.band(x, bn.Int(0xFFFFFFFF))
    local hi = bn.band(bn.rshift(x, 32), bn.Int(0xFFFFFFFF))
    return bn.Float((string.unpack("d", string.pack("I4I4", lo:tonumber(), hi:tonumber()))))
end

function IntNumber(base, m)
    return function(n)
        local self = Expr "IntNumber"
        function self.dis() return string.sub(m or "", 1, 1)..n end
        function self.eval()
            mode.set(m)
            if base == 2 then return bn.Int("0b"..n) end
            if base == 8 then return bn.Int("0o"..n) end
            if base == 16 then return bn.Int("0x"..n) end
            return bn.Int(n)
        end
        return self
    end
end

function FloatNumber()
    return function(n)
        local self = Expr "FloatNumber"
        function self.dis() return string.sub(m or "", 1, 1)..n end
        function self.eval() return bn.Float(n) end
        return self
    end
end

function Bool(b)
    local self = Expr "Bool"
    local bools = {["true"]=true; ["false"]=false}
    function self.dis() return b end
    function self.eval() return bools[b] end
    return self
end

function Str(endianess, str)
    local self = Expr "Str"
    if endianess == "" then endianess = ">" end
    function self.dis() return string.format("'%s'", str) end
    function self.eval()
        mode.set("str", "hex")
        if endianess == ">" then
            return bn.Int(string.unpack(">I4", string.rep("\0", 4-#str)..str))
        else
            return bn.Int(string.unpack("<I4", str..string.rep("\0", 4-#str)))
        end
    end
    return self
end

function Ident(name)
    local self = Expr "Ident"
    self.name = name
    function self.dis() return name end
    function self.eval(env)
        local val = env.get(name)
        if val then return val.eval(env) end
        val = constants[name]
        if type(val) == "function" then val = val() end
        if val then return val end
        error("Unknown identifier: "..name)
    end
    return self
end

function Function(args, expr)
    local self = Expr "Function"
    function self.dis()
        if #args > 0 then
            return args.dis().."="..expr.dis()
        else
            return expr.dis()
        end
    end
    function self.eval(env)
        if #args == 0 then
            return expr.eval(env.push())
        end
    end
    function self.call(env, ...)
        local xs = {...}
        local fenv = env.push()
        if #xs > #args then error("Too many arguments") end
        if #xs < #args then error("Not enough arguments") end
        for i, arg in ipairs(args) do
            fenv.set(arg.name, xs[i].eval(env))
        end
        return expr.eval(fenv)
    end
    return self
end

function Args(...)
    local self = Expr "Args"
    for _, arg in ipairs({...}) do
        table.insert(self, arg)
    end
    function self.dis()
        if #self > 0 then
            local s = "("
            for i, arg in ipairs(self) do
                s = s..arg.dis()
                if i < #self then s = s.."," end
            end
            s = s..")"
            return s
        else
            return ""
        end
    end
    return self
end

function cnum(x)
    assert(type(x) == 'table', "numeric expression expected")
    return x
end

function cbool(x)
    assert(type(x) == 'boolean', "boolean expression expected")
    return x
end

function Ternary(cond, iftrue, iffalse)
    local self = Expr "Ternary"
    function self.dis() return cond.dis().."?"..iftrue.dis()..":"..iffalse.dis() end
    function self.eval(env) return (cbool(cond.eval(env)) and iftrue or iffalse).eval(env) end
    return self
end

function B(f)
    local self = {}
    function self.call(env, ...)
        local xs = {}
        for _, x in ipairs({...}) do
            x = self.check(x.eval(env))
            if x == nil then x = constants.nan() end
            table.insert(xs, x)
        end
        return f(table.unpack(xs))
    end
    self.check = cnum
    return self
end

function Bbool(f)
    local self = B(f)
    self.check = cbool
    return self
end

constants = {
    -- nan and inf are generating new constants each times they are used
    -- to avoid comparisons of primitively equal values
    -- (and let nan == nan be false as expected)
    nan = function() return bn.Float(math.abs(0.0/0.0)) end,
    NaN = function() return bn.Float(math.abs(0.0/0.0)) end,
    inf = function() return bn.Float(1.0/0.0) end,
    Inf = function() return bn.Float(1.0/0.0) end,
    pi = bn.pi,
    e  = bn.e,
}

local function factorial(n)
    n = bn.Int(n):tonumber()
    local f = bn.one
    for i = 1, n do f = f*bn.Int(i) end
    return f
end

builtins = {
    [0] = {
        ["random"] = B(math.random),
    },
    [1] = {
        ["+"] = B(function(x) return x end),
        ["-"] = B(function(x) return -x end),
        ["~"] = B(function(x) mode.set("hex") return bn.bnot(x) end),
        ["!"] = B(factorial),
        ["not"] = Bbool(function(x) return not x end),
        ["abs"] = B(bn.abs),
        ["acos"] = B(bn.acos),
        ["acosh"] = B(bn.acosh),
        ["asin"] = B(bn.asin),
        ["asinh"] = B(bn.asinh),
        ["atan"] = B(bn.atan),
        ["atanh"] = B(bn.atanh),
        ["ceil"] = B(bn.ceil),
        ["cos"] = B(bn.cos),
        ["cosh"] = B(bn.cosh),
        ["deg"] = B(bn.deg),
        ["erf"] = B(bn.erf),
        ["erfc"] = B(bn.erfc),
        ["exp"] = B(bn.exp),
        ["exp2"] = B(bn.exp2),
        ["expm1"] = B(bn.expm1),
        ["floor"] = B(bn.floor),
        ["mantissa"] = B(function(x) local m, _ = bn.frexp(x) return m end),
        ["exponent"] = B(function(x) local _, e = bn.frexp(x) return e end),
        ["gamma"] = B(bn.gamma),
        ["isfinite"] = B(bn.isfinite),
        ["isinf"] = B(bn.isinf),
        ["isnan"] = B(bn.isnan),
        ["isnormal"] = B(bn.isnormal),
        ["lgamma"] = B(bn.lgamma),
        ["log"] = B(bn.log),
        ["ln"] = B(bn.log),
        ["log10"] = B(function(x) return bn.log10(x) end),
        ["log1p"] = B(function(x) return bn.log1p(x) end),
        ["log2"] = B(function(x) return bn.log2(x) end),
        ["logb"] = B(function(x) return bn.logb(x) end),
        ["int"] = B(function(x) return bn.Int(x) end),
        ["rat"] = B(function(x) return bn.Rat(x) end),
        ["float"] = B(function(x) return bn.Float(x) end),
        ["fract"] = B(function(x) local _, f = bn.modf(x) return f end),
        ["nearbyint"] = B(bn.nearbyint),
        ["rad"] = B(bn.rad),
        ["random"] = B(bn.random),
        ["randomseed"] = B(bn.randomseed),
        ["round"] = B(bn.round),
        ["sin"] = B(bn.sin),
        ["sinh"] = B(bn.sinh),
        ["sqr"] = B(function(x) return x*x end),
        ["sqrt"] = B(bn.sqrt),
        ["cbrt"] = B(bn.cbrt),
        ["tan"] = B(bn.tan),
        ["tanh"] = B(bn.tanh),
        ["trunc"] = B(bn.trunc),
        ["float2ieee"] = B(float2ieee),
        ["ieee2float"] = B(ieee2float),
        ["double2ieee"] = B(double2ieee),
        ["ieee2double"] = B(ieee2double),
    },
    [2] = {
        ["+"] = B(function(x, y) return x + y end),
        ["-"] = B(function(x, y) return x - y end),
        ["|"] = B(function(x, y) mode.set("hex") return bn.bor(x, y) end),
        ["^"] = B(function(x, y) mode.set("hex") return bn.bxor(x, y) end),
        ["*"] = B(function(x, y) return x * y end),
        ["/"] = B(function(x, y) return x / y end),
        ["//"] = B(function(x, y) return x // y end),
        ["%"] = B(function(x, y) return x % y end),
        ["&"] = B(function(x, y) mode.set("hex") return bn.band(x, y) end),
        ["<<"] = B(function(x, y) mode.set("hex") return bn.lshift(x, y:tonumber()) end),
        [">>"] = B(function(x, y) mode.set("hex") return bn.rshift(x, y:tonumber()) end),
        ["**"] = B(function(x, y) return x ^ y end),
        ["or"] = Bbool(function(x, y) return x or y end),
        ["xor"] = Bbool(function(x, y) return x and not y or y and not x end),
        ["and"] = Bbool(function(x, y) return x and y end),
        ["<"] = B(function(x, y) return x < y end),
        ["<="] = B(function(x, y) return x <= y end),
        [">"] = B(function(x, y) return x > y end),
        [">="] = B(function(x, y) return x >= y end),
        ["=="] = B(function(x, y) return x == y end),
        ["!="] = B(function(x, y) return x ~= y end),
        ["~="] = B(function(x, y) return x ~= y end),
        ["atan"] = B(bn.atan2),
        ["atan2"] = B(bn.atan2),
        ["copysign"] = B(bn.copysign),
        ["fdim"] = B(bn.fdim),
        ["fmod"] = B(bn.fmod),
        ["hypot"] = B(bn.hypot),
        ["ldexp"] = B(bn.ldexp),
        ["log"] = B(function(x, base) return bn.log(x, base:tonumber()) end),
        ["max"] = B(bn.max),
        ["min"] = B(bn.min),
        ["nextafter"] = B(bn.nextafter),
        ["pow"] = B(bn.pow),
        ["random"] = B(bn.random),
        ["rat"] = B(function(x, eps) return x:toRat(eps:tonumber()) end),
        ["remainder"] = B(bn.remainder),
        ["scalbn"] = B(bn.scalbn),
    },
    [3] = {
        ["fma"] = B(bn.fma),
    },
}
for i = 3, 10 do
    builtins[i] = builtins[i] or {}
    builtins[i].max = builtins[2].max
    builtins[i].min = builtins[2].min
end

local replay = false

function F(f, ...)
    local self = Expr("F")
    local xs = {...}
    function self.dis()
        local s = f
        if #xs > 0 then
            s = s.."("
            for i, x in ipairs(xs) do
                s = s..x.dis()
                if i < #xs then s = s.."," end
            end
            s = s..")"
        end
        return s
    end
    function self.eval(env)
        local func = (
            env.get(f)
            or (builtins[#xs] and builtins[#xs][f])
            or error("Unknown function: "..f.."/"..#xs)
        )
        return func.call(env, table.unpack(xs))
    end
    return self
end

function Assign(ident, expr)
    local self = Expr "Assign"
    function self.dis() return ident.name.."="..expr.dis() end
    function self.eval(env)
        env.set(ident.name, expr)
        return expr.eval(env)
    end
    return self
end

function Block(exprs)
    local self = Expr "Block"
    function self.dis()
        local s = ""
        for i, e in ipairs(exprs) do
            s = s..e.dis()
            if i < #exprs then s = s.."," end
        end
        return "("..s..")"
    end
    function self.eval(env)
        local val = nil
        for _, expr in ipairs(exprs) do
            local newval = expr.eval(env)
            if newval ~= nil then val = newval end
        end
        return val
    end
    return self
end

function Toggle(k)
    local self = Expr "Toggle"
    function self.dis() return "Toggle("..k..")" end
    function self.eval(_) mode.toggle(k) replay = true end
    return self
end

function Set(k)
    local self = Expr "Set"
    local bits
    k, bits = k:match("(%a+)(%d*)")
    if (not bits or bits=="") and k=="float" then bits = 32 end
    function self.dis() return "Set("..k..", "..bits..")" end
    function self.eval(_)
        mode.set(k)
        if bits and bits~="" then mode.set_bits(bits) end
        replay = true
    end
    return self
end

function Reset()
    local self = Expr "Reset"
    function self.dis() return "Reset()" end
    function self.eval(_) mode.clear() replay = true end
    return self
end

function Sep(_, s)
    local self = Expr "Sep"
    function self.dis() return "Sep("..s..")" end
    function self.eval(_) bn.sep(s) replay = true end
    return self
end

do
    local max_position

    local function parser(p)
        return function(s)
            max_position = 0
            local i, x = p(s, 1)
            if i == #s+1 then
                return x
            else
                local err
                if max_position > #s then
                    err = "the end"
                else
                    err = string.sub(s, max_position)
                    err = err:gsub("^%s*(.-)%s*$", "%1")
                    if #err > 10 then err = string.sub(err, 1, 10).."..." end
                end
                return nil, "Syntax error near "..err
            end
        end
    end

    local function T(token, f)
        local pattern = "^%s*("..token..")%s*"
        f = f or identity
        return function(s, i)
            local j, k, match, x1, x2, x3 = s:find(pattern, i)
            if j then
                return k+1, f(x1 or match, x2, x3)
            else
                max_position = math.max(max_position, i)
            end
        end
    end

    local function Tneglookahead(token, lookahead, f)
        local pattern = "^%s*("..token..")"
        lookahead = "^"..lookahead
        f = f or identity
        return function(s, i)
            local j, k, match, x1, x2, x3 = s:find(pattern, i)
            if j and not s:find(lookahead, k+1) then
                j, k = s:find("^%s*", k+1)
                return k+1, f(x1 or match, x2, x3)
            else
                max_position = math.max(max_position, i)
            end
        end
    end

    local function Seq(ps, f)
        f = f or identity
        return function(s, i)
            local t = {}
            for _, p in ipairs(ps) do
                local x
                i, x = p(s, i)
                if not i then return end
                table.insert(t, x)
            end
            return i, f(table.unpack(t))
        end
    end

    local function Alt(ps, f)
        f = f or identity
        return function(s, i)
            local imax, xmax = 0, nil
            for _, p in ipairs(ps) do
                local j, x = p(s, i)
                if j and j > imax then imax, xmax = j, x end
            end
            if imax > 0 then
                return imax, f(xmax)
            end
        end
    end

    local function Rule()
        local ps = {}
        local p = Alt(ps)
        return function(s, i)
            if type(s) == "function" then
                table.insert(ps, s)
                p = Alt(ps)
            else
                return p(s, i)
            end
        end
    end

    local function _() return function(x) return x end end
    local function xf(x, f) return f(x) end
    local function fx(f, x) return f(x) end
    local function _fy(f, y) return function(x) return f(x, y) end end
    local function _fyg(f, y, g) return function(x) return g(f(x, y)) end end
    local function _fg(f, g) return function(x) return g(f(x)) end end
    local function _F_(f) return function(x, y) return F(f, x, y) end end
    local function F_(f) return function(x) return F(f, x) end end
    local function _B_() return function(x, y) return Block({x, y}) end end

    local ident = T("[a-zA-Z_][%w_]*", Ident)
    local number = Rule()
    number(T("0[bB]([_01]+)", IntNumber(2, "bin")))
    number(T("0[oO]([_0-7]+)", IntNumber(8, "oct")))
    number(T("0[xX]([_0-9A-Fa-f]+)", IntNumber(16, "hex")))
    number(T("%d[_%d]*%.[_%d]*", FloatNumber()))
    number(T("[_%d]*%.[_%d]*%d", FloatNumber()))
    number(T("%d[_%d]*%.[_%d]*[eE]_*[-+]?[_%d]*%d", FloatNumber()))
    number(T("[_%d]*%.[_%d]*%d[_%d]*[eE]_*[-+]?[_%d]*%d", FloatNumber()))
    number(T("%d[_%d]*[eE]_*[-+]?_*[_%d]*%d", FloatNumber()))
    number(T("%d[_%d]*", IntNumber()))
    local bool = Rule()
    bool(T("true", Bool))
    bool(T("false", Bool))
    local str = Rule()
    str(T([["([<>]?)([^"][^"]?[^"]?[^"]?)"]], Str))
    str(T([['([<>]?)([^'][^']?[^']?[^']?)']], Str))

    local addop = Alt{T("%+", _F_), T("%-", _F_), T("%|", _F_), T("%^", _F_), }
    local mulop = Alt{T("%*", _F_), T("%/", _F_), T("%/%/", _F_), T("%%", _F_), T("%&", _F_), T("<<", _F_), T(">>", _F_), }
    local powop = Alt{T("%*%*", _F_), }
    local orop = Alt{T("or", _F_), T("xor", _F_), }
    local andop = Alt{T("and", _F_), }
    local notop = Alt{T("not", F_), }
    local relop = Alt{T("<", _F_), T(">", _F_), T("<=", _F_), T(">=", _F_), T("==", _F_), T("!=", _F_), T("~=", _F_), }
    local unop = Alt{T("%+", F_), T("%-", F_), T("%~", F_), }
    local postunop = Alt{Tneglookahead("%!", "%=", F_), }

    --[[ grammar:

            S -> 'bye' | 'exit' | 'quit' | '?' | 'help'
            S -> block

            block -> stat sblock
            sblock -> ',?' stat sblock | null

            stat -> proto '=' ternary
            stat -> ternary

            ternary -> logic sternary
            sternary -> '?' stat ':' stat | null

            logic -> orterm slogic
            slogic -> orop orterm slogic | null

            orterm -> andterm sorterm
            sortem -> andop andterm sorterm | null

            andterm -> notop andterm
            andterm -> relation

            relation -> arith srelation | arith
            srelation -> relop arith srelation | relop arith

            arith -> term sarith
            sarith -> addop term sarith | null

            term -> fact sterm
            sterm -> mulop fact sterm | null

            fact -> unop fact | pow

            pow -> post spow
            spow -> powop fact | null

            post -> atom spost
            spost -> postunop spost | null

            atom -> '(' block ')'
            atom -> number | bool | str | ident
            atom -> eval

            proto -> ident fargs
            eval -> ident args

            fargs -> '(' _fargs ')' | null
            _fargs -> ident (',' _fargs | null)

            args -> '(' _args ')'
            _args -> stat (',' _args | null)

    --]]

    local block = Rule()
    local null = T("", _)
    local stat, ternary, proto, eval = Rule(), Rule(), Rule(), Rule()
    local logic, orterm, andterm = Rule(), Rule(), Rule()
    local relation, arith, term, fact, pow, post = Rule(), Rule(), Rule(), Rule(), Rule(), Rule()
    local atom = Rule()

    calc = parser(Alt{
        T("bye", Quit), T("exit", Quit), T("quit", Quit),
        T("%?", Help), T("help", LongHelp),
        T("license", License),
        T("edit", Edit),
        Seq({T"sep", T"'([ _]?)'"}, Sep),
        Seq({T"sep", T'"([ _]?)"'}, Sep),
        T("dec", Toggle), T("hex", Toggle), T("oct", Toggle), T("bin", Toggle),
        T("float", Toggle),
        T("dec8", Set), T("dec16", Set), T("dec32", Set), T("dec64", Set), T("dec128", Set),
        T("hex8", Set), T("hex16", Set), T("hex32", Set), T("hex64", Set), T("hex128", Set),
        T("oct8", Set), T("oct16", Set), T("oct32", Set), T("oct64", Set), T("oct128", Set),
        T("bin8", Set), T("bin16", Set), T("bin32", Set), T("bin64", Set), T("bin128", Set),
        T("float32", Set), T("float64", Set),
        T("str", Toggle),
        T("reset", Reset),
        block
    })

    local sblock = Rule()
    block(Seq({stat, sblock}, xf))
    sblock(Seq({T(",?", _B_), stat, sblock}, _fyg))
    sblock(null)

    stat(T("[;#]%s*[^\r\n]*", Comment))
    stat(Alt{
        Seq({T"sep", T"'([ _]?)'"}, Sep),
        Seq({T"sep", T'"([ _]?)"'}, Sep),
        T("dec", Set), T("hex", Set), T("oct", Set), T("bin", Set),
        T("dec8", Set), T("dec16", Set), T("dec32", Set), T("dec64", Set), T("dec128", Set),
        T("hex8", Set), T("hex16", Set), T("hex32", Set), T("hex64", Set), T("hex128", Set),
        T("oct8", Set), T("oct16", Set), T("oct32", Set), T("oct64", Set), T("oct128", Set),
        T("bin8", Set), T("bin16", Set), T("bin32", Set), T("bin64", Set), T("bin128", Set),
        T("float", Set),
        T("float32", Set), T("float64", Set),
        T("str", Set),
        T("reset", Reset),
    })
    stat(Seq({proto, T"=", ternary},
        function(f, _, expr) return Assign(f.name, Function(f.args, expr)) end
    ))
    stat(ternary)

    local fargs, args = Rule(), Rule()
    proto(Seq({ident, fargs}, function(name, func_args) return {name=name, args=func_args} end))
    eval(Seq({ident, args}, function(name, func_args) return F(name.name, table.unpack(func_args)) end))

    local _fargs = Rule()
    fargs(Seq({T"%(", _fargs, T"%)"}, function(_, x, _) return x end))
    fargs(T("", function() return Args() end))
    _fargs(Seq({ident, T",", _fargs}, function(x, _, xs) return Args(x, table.unpack(xs)) end))
    _fargs(Seq({ident}, function(x) return Args(x) end))
    _fargs(T("", function() return Args() end))

    local _args = Rule()
    args(Seq({T"%(", _args, T"%)"}, function(_, x, _) return x end))
    args(T("", function() return Args() end))
    _args(Seq({stat, T",", _args}, function(x, _, xs) return Args(x, table.unpack(xs)) end))
    _args(Seq({stat}, function(x) return Args(x) end))
    _args(T("", function() return Args() end))

    local sternary = Rule()
    ternary(Seq({logic, sternary}, xf))
    sternary(Seq({T"%?", stat, T":", stat}, function(_, iftrue, _, iffalse) return function(cond) return Ternary(cond, iftrue, iffalse) end end))
    sternary(null)

    local slogic = Rule()
    logic(Seq({orterm, slogic}, xf))
    slogic(Seq({orop, orterm, slogic}, _fyg))
    slogic(null)

    local sorterm = Rule()
    orterm(Seq({andterm, sorterm}, xf))
    sorterm(Seq({andop, andterm, sorterm}, _fyg))
    sorterm(null)

    andterm(Seq({notop, andterm}, fx))
    andterm(relation)

    -- relation x<y<z <=> x<y and y<z
    local srelation = Rule()
    relation(Seq({arith, srelation}, xf))
    relation(arith)
    srelation(Seq({relop, arith, srelation}, function(f, y, g) return function(x) return F("and", f(x,y), g(y)) end end))
    srelation(Seq({relop, arith}, function(f, y) return function(x) return f(x,y) end end))

    local sarith = Rule()
    arith(Seq({term, sarith}, xf))
    sarith(Seq({addop, term, sarith}, _fyg))
    sarith(null)

    local sterm = Rule()
    term(Seq({fact, sterm}, xf))
    sterm(Seq({mulop, fact, sterm}, _fyg))
    sterm(null)

    fact(Seq({unop, fact}, fx))
    fact(pow)

    local spow = Rule()
    pow(Seq({post, spow}, xf))
    spow(Seq({powop, fact}, _fy))
    spow(null)

    local spost = Rule()
    post(Seq({atom, spost}, xf))
    spost(Seq({postunop, spost}, _fg))
    spost(null)

    atom(number)
    atom(bool)
    atom(str)
    atom(ident)
    atom(Seq({T"%(", block, T"%)"}, function(_, x, _) return x end))
    atom(eval)

end

function Config()
    local ini_path = fun.case(sys.os) {
        windows   = (os.getenv "APPDATA" or "") / default_ini,
        [fun.Nil] = (os.getenv "HOME" or "") / ".config" / default_ini,
    }
    local editor = os.getenv "EDITOR" or "vi"
    local self = {}
    local mtime = 0
    if not fs.is_file(ini_path) then
        fs.write(ini_path, require(default_ini))
    end
    function self.run(env)
        local st = fs.stat(ini_path)
        if st == nil then
            -- This should not happen???
            print("!", "Can not read "..ini_path)
            return
        end
        if st.mtime == mtime then return end -- file already loaded
        mtime = st.mtime
        local expr = fs.read(ini_path)
        if not expr then return end
        print("loading "..ini_path)
        local result, err = calc(expr)
        if not result then
            print("!", err)
        else
            local ok, val = result.evaluate(env)
            if not ok then
                print("!", val)
            end
        end
    end
    function self.edit()
        sh.run { editor, ini_path }
    end
    return self
end

function str(val)
    local isnumber
    isnumber, val = pcall(math.floor, (val % bn.Int(2^32)):tonumber())
    if not isnumber then return "" end
    local s = string.pack(">I4", val):gsub("^%z+(.+)", "%1")
    return string.format("%q", s)
end

print(help)

local env = Env()

config = Config()
config.run(env)

local last_line = nil

local is_a_tty = terminal.isatty()
local prompt = is_a_tty and ": " or ""

local linenoise = require "linenoise"
local history = fun.case(sys.os) {
    windows   = function() return (os.getenv "APPDATA" or "") / "calculadoira_history" end,
    [fun.Nil] = function() return (os.getenv "HOME" or "") / ".calculadoira_history" end,
}()
linenoise.load(history)

local function hist(input)
    linenoise.add(input)
    linenoise.save(history)
end

while true do
    local line
    if replay and last_line then
        line = last_line
        print(": "..line)
    else
        line = linenoise.read(prompt)
        if not line then break end
        if not is_a_tty then print(": "..line) end
        hist(line)
    end
    replay = false
    config.run(env) -- autoreload
    if not line:match("^%s*$") then
        local expr, err = calc(line)
        if not expr then
            print("!", err)
            print ""
        else
            --print("debug", expr.dis())
            local ok, val = expr.evaluate(env)
            if not ok then
                print("!", val)
                print ""
            elseif val ~= nil then
                replay = false
                last_line = line
                print("=", val)
                if type(val) == "table" then
                    if val.isInt then
                        fun{"dec", "hex", "oct", "bin"}:map(function(base)
                            if mode[base] then
                                print(base..(mode.bits or ""), bn[base](val, mode.bits))
                            end
                        end)
                    end
                    if val.isRat then
                        if val < bn.zero or val > bn.one then
                            print("=", val:to_us_frac())
                        end
                        print("~", val:tonumber())
                    end
                    if mode.float then
                        local int, float
                        if val.isInt then
                            int = val
                            if mode.bits == 64 then
                                float = ieee2double(val)
                            else
                                float = ieee2float(val)
                            end
                        else
                            if mode.bits == 64 then
                                int = double2ieee(val)
                                float = ieee2double(int)
                            else
                                int = float2ieee(val)
                                float = ieee2float(int)
                            end
                        end
                        print("IEEE", ("%s <=> %s"):format(float, bn.hex(int, mode.bits)))
                    end
                    if mode.str and val.isInt then print("str", str(val)) end
                end
                print ""
            end
        end
    end
end
