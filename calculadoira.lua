#!/usr/bin/env bl

--__debug__ = true

license = [[
Calculadoira
Copyright (C) 2011 Christophe Delord
http://www.cdsoft.fr/calculadoira

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

help = [[
+---------------------------------------------------------------------+
|                       C A L C U L A D O I R A                       |
|---------------------------------------------------------------------|
| Modes:                          | Numbers:                          |
|     hex oct bin float ieee      |     binary: b... or ...b          |
|---------------------------------|     octal : o... or ...o          |
| Variable and function:          |     hexa  : h... or ...h or 0x... |
|     variable = expression       |     float : 1.2e-3                |
|     function(x, y) = expression |-----------------------------------|
| Multiple statements:            | Operators:                        |
|     expr1, ..., exprn           |     or xor and not                |
|---------------------------------|     < <= > >= == !=               |
| Builtin functions:              |     cond?expr:expr                |
|     see Lua's math module       |     + - * / % ** | ^ & >> << ~    |
|---------------------------------------------------------------------|
| Commands: ? help bye license    | http://www.cdsoft.fr/calculadoira |
+---------------------------------------------------------------------+
]]

longhelp = [[
Math functions (Lua module)
---------------------------

See http://www.lua.org/manual/5.1/manual.html#5.6

General functions:
    abs, ceil, floor
    exp, log, log10
    fmod, int, fract (1)
    frexp, ldexp
    min, max,
    pow
    random, randomseed
    sqr, sqrt

Trigonometry:
    sin, asin, sinh
    cos, acos, cosh
    tan, atan, atan2, tanh
    deg, rad

32 bit IEEE floats:
    float2ieee, ieee2float

Constants:
    huge, inf
    pi, e

(1) int and fract return modf results

Display modes
-------------

hex, oct and bin commands change the display mode.
When enabled, the integer result is displayed in
hexadecimal, octal and/or binary.
float mode shows the float value of a 32 bit IEEE float.
ieee mode shows the IEEE coding of a 32 bit float.

Blocks
------

A bloc is made of several expressions separated by `,`.
The value of the block is the value of the last expression.

e.g. x=1, y=2, x+y defines x=1, y=2 and returns 3

Definitions made in functions are local.

e.g. f(x) = (y=1, x+y) defines a function f that
returns x+1. y is local to f.

Local definitions can be functions.

e.g. fact(n) = (f(n,p)=(n==1)?p:f(n-1,n*p), f(n,1))

Operator precedence
-------------------

From highest to lowest precedence:

Operator family             Syntax
=========================== =================
Precedence overloading      (...)
Function evaluation         f(...)
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

Credits
-------

Calculadoira: http://www.cdsoft.fr/calculadoira
BonaLuna    : http://www.cdsoft.fr/bl

"Calculadoira" means "Calculator" in Occitan.
]]

if sys.platform == "Windows" then
    os.execute "title Calculadoira"
    os.execute "color f0"
end

if sys.platform == "Windows" then
    function readline(prompt)
        io.write(prompt)
        return io.read "*l"
    end
else
    function readline(prompt)
        local line = rl.read(prompt)
        rl.add(line:gsub("^%s*(.-)%s*$", "%1"))
        return line
    end
end

function pp(t, indent)
    indent = indent or ""
    if type(t) == "table" then
        print(indent.."{")
        for k,v in pairs(t) do
            print(indent.."    "..k.." =")
            pp(v, indent.."        ")
        end
        print(indent.."}")
    else
        print(indent.."        "..tostring(t))
    end
end

function Mode()
    local self = {}
    function self.set(...)
        if not running then return end
        for _, mode in ipairs({...}) do
            self[mode] = true
        end
    end
    function self.toggle(mode)
        if not running then return end
        self[mode] = not self[mode]
    end
    function self.clear()
        for k,v in pairs(self) do
            if v == true then self[k] = false end
        end
    end
    return self
end

mode = Mode()

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
        if not ok then val = val:gsub(".*:%d+:", "") end
        return ok, val
    end
    return self
end

function Quit()
    local self = Expr "Quit"
    function self.eval()
        os.exit()
    end
    return self
end

function Help()
    local self = Expr "Help"
    function self.eval()
        print(help)
    end
    return self
end

function LongHelp()
    local self = Expr "LongHelp"
    function self.eval()
        print(help)
        print(longhelp)
    end
    return self
end

function License()
    local self = Expr "License"
    function self.eval()
        print(license)
    end
    return self
end

function Env(up)
    local self = {}
    local vars = {}
    function self.set(name, value)
        vars[name] = Object(value)
    end
    function self.get(name)
        return vars[name] or (up and up.get(name))
    end
    function self.push()
        return Env(self)
    end
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
    mode.set("float", "ieee")
    return (struct.unpack("I4", struct.pack("f", x)))
end

function ieee2float(x)
    mode.set("float", "ieee")
    return (struct.unpack("f", struct.pack("I4", x)))
end

nan = ieee2float(0x7FC00000)

function Number(n)
    local self = Expr "Number"
    local digits, val
    local m = nil
    digits = n:match("^0x(.*)") or n:match("^h(.*)") or n:match("(.*)h$")
    if digits then val = tonumber(digits, 16) m="hex"
    else
        digits = n:match("^o(.*)") or n:match("(.*)o$")
        if digits then val = tonumber(digits, 8) m="oct"
        else
            digits = n:match("^b(.*)") or n:match("(.*)b$")
            if digits then val = tonumber(digits, 2) m="bin"
            else val = tonumber(n)
            end
        end
    end
    function self.dis() return n end
    function self.eval()
        mode.set(m)
        return val
    end
    return self
end

function Bool(b)
    local self = Expr "Bool"
    local val = nil
    if b == "true" then val = true end
    if b == "false" then val = false end
    function self.dis() return b end
    function self.eval() return val end
    return self
end

function Ident(name)
    local self = Expr "Ident"
    self.name = name
    function self.dis() return name end
    function self.eval(env)
        local val = env.get(name)
        if val then
            return val.eval(env)
        end
        val = constants[name]
        if val then
            return val
        end
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
            return expr.eval(env)
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
    for i, arg in ipairs({...}) do
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

function Ternary(cond, iftrue, iffalse)
    local self = Expr "Ternary"
    function self.dis() return cond.dis().."?"..iftrue.dis()..":"..iffalse.dis() end
    function self.eval(env)
        if cond.eval(env) then
            return iftrue.eval(env)
        else
            return iffalse.eval(env)
        end
    end
    return self
end

function B(f)
    local self = {}
    function self.call(env, ...)
        local xs = {}
        for i, x in ipairs({...}) do
            x = x.eval(env)
            if x == nil then x = nan end
            table.insert(xs, x)
        end
        return f(table.unpack(xs))
    end
    return self
end

function Or()
    local self = {}
    function self.call(env, x, y)
        return x.eval(env) or y.eval(env)
    end
    return self
end

function And()
    local self = {}
    function self.call(env, x, y)
        return x.eval(env) and y.eval(env)
    end
    return self
end

constants = {
    huge = math.huge,
    inf = math.huge,
    nan = nan,
    pi = math.pi,
    e = math.exp(1),
}

builtins = {
    [0] = {
        ["random"] = B(math.random),
    },
    [1] = {
        ["+"] = B(function(x) return x end),
        ["-"] = B(function(x) return -x end),
        ["~"] = B(function(x) mode.set("hex", "bin") return bit32.bnot(x) end),
        ["not"] = B(function(x) return not x end),
        ["abs"] = B(math.abs),
        ["acos"] = B(math.acos),
        ["asin"] = B(math.asin),
        ["atan"] = B(math.atan),
        ["ceil"] = B(math.ceil),
        ["cos"] = B(math.cos),
        ["cosh"] = B(math.cosh),
        ["deg"] = B(math.deg),
        ["exp"] = B(math.exp),
        ["floor"] = B(math.floor),
        ["frexp"] = B(math.frexp),
        ["log"] = B(math.log),
        ["log10"] = B(math.log10),
        ["int"] = B(function(x) local i, f = math.modf(x); return i end),
        ["fract"] = B(function(x) local i, f = math.modf(x); return f end),
        ["rad"] = B(math.rad),
        ["random"] = B(math.random),
        ["randomseed"] = B(math.randomseed),
        ["sin"] = B(math.sin),
        ["sinh"] = B(math.sinh),
        ["sqr"] = B(function(x) return x^2 end),
        ["sqrt"] = B(math.sqrt),
        ["tan"] = B(math.tan),
        ["tanh"] = B(math.tanh),
        ["float2ieee"] = B(float2ieee),
        ["ieee2float"] = B(ieee2float),
    },
    [2] = {
        ["+"] = B(function(x, y) return x + y end),
        ["-"] = B(function(x, y) return x - y end),
        ["|"] = B(function(x, y) mode.set("hex", "bin") return bit32.bor(x, y) end),
        ["^"] = B(function(x, y) mode.set("hex", "bin") return bit32.bxor(x, y) end),
        ["*"] = B(function(x, y) return x * y end),
        ["/"] = B(function(x, y) return x / y end),
        ["%"] = B(function(x, y) return x % y end),
        ["&"] = B(function(x, y) mode.set("hex", "bin") return bit32.band(x, y) end),
        ["<<"] = B(function(x, y) mode.set("hex", "bin") return bit32.lshift(x, y) end),
        [">>"] = B(function(x, y) mode.set("hex", "bin") return bit32.rshift(x, y) end),
        ["**"] = B(function(x, y) return x ^ y end),
        ["or"] = Or(),
        ["xor"] = B(function(x, y) return x and not y or y and not x end),
        ["and"] = And(),
        ["<"] = B(function(x, y) return x < y end),
        ["<="] = B(function(x, y) return x <= y end),
        [">"] = B(function(x, y) return x > y end),
        [">="] = B(function(x, y) return x >= y end),
        ["=="] = B(function(x, y) return x == y end),
        ["!="] = B(function(x, y) return x ~= y end),
        ["~="] = B(function(x, y) return x ~= y end),
        ["atan2"] = B(math.atan2),
        ["fmod"] = B(math.fmod),
        ["ldexp"] = B(math.ldexp),
        ["max"] = B(math.max),
        ["min"] = B(math.min),
        ["pow"] = B(math.pow),
        ["random"] = B(math.random),
    },
}
for i = 3, 10 do
    builtins[i] = {
        max = builtins[2].max,
        min = builtins[2].min,
    }
end

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
        for i, expr in ipairs(exprs) do
            val = expr.eval(env)
        end
        return val
    end
    return self
end

function Toggle(k)
    local self = Expr "Toggle"
    function self.dis() return "Toggle("..k..")" end
    function self.eval(env) mode.toggle(k) end
    return self
end

function Set(k)
    local self = Expr "Set"
    function self.dis() return "Set("..k..")" end
    function self.eval(env) mode.set(k) end
    return self
end

do
    local function parser(p)
        return function(s)
            local i, x = p(s, 1)
            if i == #s+1 then return x end
        end
    end

    local _id = function(...) return ... end

    local function T(pattern, f)
        pattern = "^%s*("..pattern..")%s*"
        f = f or _id
        return function(s, i)
            local i, j, token = s:find(pattern, i)
            if i then return j+1, f(token) end
        end
    end

    local function Seq(ps, f)
        f = f or _id
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
        f = f or _id
        return function(s, i)
            local imax, xmax = 0, nil
            for _, p in ipairs(ps) do
                local j, x = p(s, i)
                if j and j > imax then
                    imax, xmax = j, x
                end
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
    local function _F_(f) return function(x, y) return F(f, x, y) end end
    local function F_(f) return function(x) return F(f, x) end end
    local function _B_() return function(x, y) return Block({x, y}) end end

    local expr = Rule()
    local ident = T("[a-zA-Z_]%w*", Ident)
    local number = Rule()
    number(T("b[01]+", Number))
    number(T("[01]+b", Number))
    number(T("o[0-7]+", Number))
    number(T("[0-7]+o", Number))
    number(T("h[0-9A-Fa-f]+", Number))
    number(T("[0-9A-Fa-f]+h", Number))
    number(T("0[xX][0-9A-Fa-f]+", Number))
    number(T("%d+%.%d*", Number))
    number(T("%d*%.%d+", Number))
    number(T("%d+%.%d*[eE][-+]?%d+", Number))
    number(T("%d*%.%d+[eE][-+]?%d+", Number))
    number(T("%d+[eE][-+]?%d+", Number))
    number(T("%d+", Number))
    local bool = Rule()
    bool(T("true", Bool))
    bool(T("false", Bool))
    bool(T("nil", Bool))

    local addop = Alt{
        T("%+", _F_),
        T("%-", _F_),
        T("%|", _F_),
        T("%^", _F_),
    }
    local mulop = Alt{
        T("%*", _F_),
        T("%/", _F_),
        T("%%", _F_),
        T("%&", _F_),
        T("<<", _F_),
        T(">>", _F_),
    }
    local powop = Alt{
        T("%*%*", _F_),
    }
    local orop = Alt{
        T("or", _F_),
        T("xor", _F_),
    }
    local andop = Alt{
        T("and", _F_),
    }
    local notop = Alt{
        T("not", F_),
    }
    local relop = Alt{
        T("<", _F_),
        T(">", _F_),
        T("<=", _F_),
        T(">=", _F_),
        T("==", _F_),
        T("!=", _F_),
        T("~=", _F_),
    }
    local unop = Alt{
        T("%+", F_),
        T("%-", F_),
        T("%~", F_),
    }

    --[[ grammar:

            S -> 'bye' | 'exit' | 'quit' | '?' | 'help'
            S -> block

            block -> stat sblock
            sblock -> ',' stat sblock | null

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

            pow -> atom spow
            spow -> powop fact | null

            atom -> '(' block ')'
            atom -> number | bool | ident
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
    local relation, arith, term, fact, pow = Rule(), Rule(), Rule(), Rule(), Rule()
    local atom = Rule()

    calc = parser(Alt{
        T("bye", Quit), T("exit", Quit), T("quit", Quit),
        T("%?", Help), T("help", LongHelp),
        T("license", License),
        T("dec", Toggle), T("hex", Toggle), T("oct", Toggle), T("bin", Toggle),
        T("float", Toggle), T("ieee", Toggle),
        block
    })

    local sblock = Rule()
    block(Seq({stat, sblock}, xf))
    sblock(Seq({T(",", _B_), stat, sblock}, _fyg))
    sblock(null)

    stat(Alt{
        T("dec", Set), T("hex", Set), T("oct", Set), T("bin", Set),
        T("float", Set), T("ieee", Set),
    })
    stat(Seq({proto, T"=", ternary},
        function(f, _, expr)
            return Assign(f.name, Function(f.args, expr))
        end
    ))
    stat(ternary)

    local fargs, args = Rule(), Rule()
    proto(Seq({ident, fargs}, function(name, args) return {name=name, args=args} end))
    eval(Seq({ident, args}, function(name, args) return F(name.name, table.unpack(args)) end))

    local _fargs = Rule()
    fargs(Seq({T"%(", _fargs, T"%)"}, function(a, x, b) return x end))
    fargs(T("", function() return Args() end))
    _fargs(Seq({ident, T",", _fargs}, function(x, _, xs) return Args(x, table.unpack(xs)) end))
    _fargs(Seq({ident}, function(x) return Args(x) end))
    _fargs(T("", function() return Args() end))

    local _args = Rule()
    args(Seq({T"%(", _args, T"%)"}, function(a, x, b) return x end))
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
    pow(Seq({atom, spow}, xf))
    spow(Seq({powop, fact}, _fy))
    spow(null)

    atom(number)
    atom(bool)
    atom(ident)
    atom(Seq({T"%(", block, T"%)"}, function(_, x, _) return x end))
    atom(eval)

end

local env = Env()

print(help)

for i = 1, #arg do
    print("loading "..arg[i])
    local f = io.open(arg[i])
    if not f then
        print("! can not open "..arg[i])
    else
        repeat
            local expr = ""
            local line
            repeat
                line = f:read "*l"
                if line then expr = expr..line:gsub("\\%s*$", "") end
            until not line or not line:match("\\%s*$")
            expr = expr:gsub("^%s+", "")
            expr = expr:gsub("%s+$", "")
            if not expr:match("^%-%-") and not expr:match("^%s*$") then
                expr = calc(expr)
                if not expr then
                    print("!", "syntax error")
                else
                    expr.eval(env)
                end
            end
        until not line
    end
end
if #arg > 0 then print "" end

function int(val, config)
    config = config or {}
    local radix = config.radix or 10
    local digits = config.digits or nil
    local groups = config.groups or 3
    local isnumber, val = pcall(math.floor, val)
    if not isnumber then return "" end
    local s = ""
    if radix == 10 and val < 0 then
        n = math.abs(val)
    else
        n = val
    end
    local nb_digits = 0
    n = n % 2^32
    while (digits and nb_digits<digits) or (not digits and n ~= 0) do
        local d = n%radix
        n = (n-d)/radix
        s = string.sub("0123456789ABCDEF", d+1, d+1)..s
        nb_digits = nb_digits + 1
        if nb_digits % groups == 0 then s = " "..s end
    end
    s = string.gsub(s, "^ ", "")
    if s == "" then s = "0" end
    if radix == 10 and val < 0 then s = "-"..s end
    return s
end

while true do
    local line = readline(": ")
    line = line:gsub("%s+", "")
    if #line > 0 then
        local expr = calc(line)
        if not expr then
            print("!", "syntax error")
        else
            if __debug__ then print("debug", expr.dis()) end
            local ok, val = expr.evaluate(env)
            if not ok then
                print("!", val)
            elseif val ~= nil then
                print("=", val)
                if mode.dec then print("dec", int(val)) end
                if mode.hex then print("hex", int(val, {radix=16, digits=8,  groups=4})) end
                if mode.oct then print("oct", int(val, {radix=8,  digits=nil, groups=999})) end
                if mode.bin then print("bin", int(val, {radix=2,  digits=32, groups=4})) end
                if mode.float then print("float", ieee2float(val)) end
                if mode.ieee then print("ieee", "0x"..int(float2ieee(val), {radix=16, digits=8, groups=8})) end
            end
        end
    end
    print ""
end
