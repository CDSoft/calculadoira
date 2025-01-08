<!--
Calculadoira
Copyright (C) 2011-2024 Christophe Delord
https://github.com/cdsoft/calculadoira
&#10;This file is part of Calculadoira.
&#10;Calculadoira is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
&#10;Calculadoira is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
&#10;You should have received a copy of the GNU General Public License
along with Calculadoira.  If not, see <http://www.gnu.org/licenses/>.
-->

# Introduction

Calculadoira is a simple yet powerful calculator. Unlike most of other
calculators, Calculadoira is based on a textual interface. It may seem a
bit spartan and outdated but entering expressions with the keyboard is
way easier than with a mouse. And you get nice editing features for free
(edition, copy/paste, history, …).

You can contribute to [Calculadoira on
GitHub](https://github.com/CDSoft/calculadoira).

# License

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

# Download and installation

**Installation from sources:**

- Prerequisites
  - [LuaX](https://github.com/cdsoft/luax)
  - [Panda](https://github.com/cdsoft/panda) and
    [Pandoc](http://pandoc.org/) to generate the documentation
    (optional)

``` bash
# First install LuaX
$ git clone https://github.com/CDSoft/luax && ninja install -C luax
# Then Calculadoira
$ git clone https://github.com/CDSoft/calculadoira && ninja install -C calculadoira
```

# Screenshot

    +---------------------------------------------------------------------+
    |      CALCULADOIRA       v. 4.5.1 |  https://github.com/cdsoft/calculadoira  |
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

# Usage

Calculadoira is an interactive terminal calculator. Expressions are
entered with the keyboard, evaluated and the result is printed. The next
section lists all the operators and functions provided by Calculadoira.

A typical interactive session looks like this:

    +---------------------------------------------------------------------+
    |      CALCULADOIRA       v. 4.5.1 |  https://github.com/cdsoft/calculadoira  |
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

    : x = 21
    =       21

    : y = 2
    =       2

    : (x * y) ** 2
    =       1764

# User’s manual

## Numbers

### Integers

Integers can be decimal, hexadecimal, octal or binary numbers:

    : 42
    =       42

    : 0x24
    =       36
    hex     0x24

    : 0o37
    =       31
    hex     0x1F
    oct     0o37

    : 0b1010
    =       10
    hex     0xA
    oct     0o12
    bin     0b1010

### Rational numbers

Rational numbers can be used to make *exact* computations instead of
using floating point numbers.

    : 1 + 2/3
    =       5 / 3
    =       1 + 2/3
    ~       1.6666666666667

Some functions don’t support rational numbers and will produce floating
point numbers.

    : 1/2 + cos(0)
    =       1.5

### Floating point numbers

Floating point numbers are single (32 bit) or double (64 bits) precision
floating point numbers.

They are represented internally by 64 bit numbers but can be converted
to 32 bit numbers as well as to their IEEE 754 representation.

    : 3.14
    =       3.14

    : 1.23e-6
    =       1.23e-06

    : e
    =       2.718281828459

    : pi
    =       3.1415926535898

    : float32
    : pi
    =       3.1415926535898
    IEEE    3.1415927410126 <=> 0x40490FDB

    : float64
    : pi
    =       3.1415926535898
    IEEE    3.1415926535898 <=> 0x400921FB54442D18

    : nan
    =       nan
    IEEE    nan <=> 0x7FF8000000000000

    : inf
    =       inf
    IEEE    inf <=> 0x7FF0000000000000

    : -inf
    =       -inf
    IEEE    -inf <=> 0xFFF0000000000000

### Automatic type conversion

Number types are automatically converted in a way to preserve the best
precision. Integers are preferred to rational numbers and rational
numbers are preferred to floating point numbers.

    : 1+2/3
    =       5 / 3
    =       1 + 2/3
    ~       1.6666666666667

    : 1/3+2/3
    =       1

    : (2/3) * 0.5
    =       0.33333333333333

### Display mode

By default only the raw value of the result is displayed. The user can
activate additional display modes by selecting:

- the integral base (`dec`, `hex`, `oct`, `bin`)
- the number of bits (`8`, `16`, `32`, `64`)
- the IEEE 754 representation of floating point numbers (`float32`,
  `float64`)
- `reset` resets the display mode

<!-- -->

    : 42424242
    =       42424242

    : dec8            # 8 bit decimal numbers
    : 42424242
    =       42424242
    dec8    178

    : hex16           # 16 bit hexadecimal numbers
    : 42424242
    =       42424242
    dec16   22450
    hex16   0x57B2

    : oct32           # 32 bit octal numbers
    : 42424242
    =       42424242
    dec32   0042424242
    hex32   0x028757B2
    oct32   0o00241653662

    : bin64           # 64 bit binary numbers
    : 42424242
    =       42424242
    dec64   0000000000042424242
    hex64   0x00000000028757B2
    oct64   0o0000000000000241653662
    bin64   0b0000000000000000000000000000000000000010100001110101011110110010

    : reset           # raw decimal value only
    : 42424242
    =       42424242

Calculadoira automatically activates some display modes under some
circonstances:

- integer entered in a specific base
- usage of a bitwise operator in an expression

<!-- -->

    : 4               # only the default display mode
    =       4

    : 0b100           # this number activates the binary display mode
    =       4
    bin     0b100

    : 1<<10           # this operator activates the hexadecimal display mode
    =       1024
    hex     0x400
    bin     0b10000000000

## Booleans

Boolean values can be used in conditional and boolean expressions.

    : true
    =       true

    : false
    =       false

    : true and false
    =       false

    : 1+1 == 2
    =       true

    : 1+1==2 ? "ok" : "bug"
    =       28523
    hex     0x6F6B
    str     "ok"

## Operators

### Arithmetic operators

    : x = 13
    =       13

    : -x
    =       -13

    : +x
    =       13

    : x + 1
    =       14

    : x - 1
    =       12

    : x * 2
    =       26

    : x / 5
    =       13 / 5
    =       2 + 3/5
    ~       2.6

    : x // 5                  # integral division
    =       2

    : x % 5                   # integral remainder (Euclidean division)
    =       3

    : x ** 2
    =       169

### Bitwise operators

    : bin16
    : ~1                      # bitwise complement
    =       -2
    hex16   0xFFFE
    bin16   0b1111111111111110

    : 1 | 4                   # bitwise or
    =       5
    hex16   0x0005
    bin16   0b0000000000000101

    : 0b1100 ^ 0b0110         # bitwise exclusive or
    =       10
    hex16   0x000A
    bin16   0b0000000000001010

    : 0b1100 & 0b0110         # bitwise and
    =       4
    hex16   0x0004
    bin16   0b0000000000000100

    : 1 << 10                 # left shift
    =       1024
    hex16   0x0400
    bin16   0b0000010000000000

    : 1024 >> 1               # right shift
    =       512
    hex16   0x0200
    bin16   0b0000001000000000

### Boolean operators

    : not true
    =       false

    : true or false
    =       true

    : true xor false
    =       true

    : true and false
    =       false

### Comparison operators

    : 12 < 13
    =       true

    : 12 <= 13
    =       true

    : 12 > 13
    =       false

    : 12 >= 13
    =       false

    : 12 == 13
    =       false

    : 12 != 13
    =       true

### Operator precedence

From highest to lowest precedence:

| Operator family          | Syntax                      |
|:-------------------------|:----------------------------|
| Precedence overloading   | `(...)`                     |
| Function evaluation      | `f(...)`                    |
| Factorial                | `x!`                        |
| Exponentiation           | `x**y`                      |
| Unary operators          | `+x`, `-y`, `~z`            |
| Multiplicative operators | `*` `/` `%` `&` `<<` `>>`   |
| Additive operators       | `+` `-` `|` `^`             |
| Relational operators     | `<` `<=` `>` `>=` `==` `!=` |
| Logical not              | `not x`                     |
| Logical and              | `and`                       |
| Logical or               | `or` `xor`                  |
| Ternary operator         | `x ? y : z`                 |
| Assignement              | `x = y`                     |
| Blocks                   | `expr1, ..., exprn`         |

## Variables

Calculadoira can define and reuse variables.

    : x = 1
    =       1

    : y = 2
    =       2

    : x+y
    =       3

    : y = 3
    =       3

    : x+y
    =       4

## Functions

Calculadoira can also define functions.

    : f(x) = 2 * x
    : f(5)
    =       10

Functions can be defined with multiple statements and be recursive.

    : fib(n) = (n <= 1 ? 1 : (f1=fib(n-1), f2=fib(n-2), f1+f2))
    : fib(1)
    =       1

    : fib(10)
    =       89

You can see in the previous example that the evaluation is lazy! Thanks
to laziness, functions can also be mutually recursive.

    : isEven(n) = n == 0 ? true : isOdd(n-1)
    : isOdd(n) = n == 0 ? false : isEven(n-1)
    : isEven(10)
    =       true

    : isOdd(10)
    =       false

## Builtin functions

### Type conversion

    : int(pi)                     # Integral part
    =       3

    : float(2/3)                  # Conversion to floating point numbers
    =       0.66666666666667

    : rat(pi)                     # Rational approximation
    =       355 / 113
    =       3 + 16/113
    ~       3.141592920354

    : rat(pi, 1e-2)               # Rational approximation with a given precision
    =       22 / 7
    =       3 + 1/7
    ~       3.1428571428571

### Math

    : x = pi, y = e, b = 3
    =       3

    : 
    : abs(x)                      # absolute value of x
    =       3.1415926535898

    : ceil(x)                     # smallest integer larger than or equal to x
    =       4

    : floor(x)                    # largest integer smaller than or equal to x
    =       3

    : round(x)                    # round to the nearest integer
    =       3.0

    : trunc(x)                    # round toward zero
    =       3.0

    : mantissa(x)                 # m such that x = m2e, |m| is in [0.5, 1[
    =       0.78539816339745

    : exponent(x)                 # e such that x = m2e, e is an integer
    =       2

    : int(x)                      # integral part of x
    =       3

    : fract(x)                    # fractional part of x
    =       0.14159265358979

    : min(x, y)                   # minimum value among its arguments
    =       2.718281828459

    : max(x, y)                   # maximum value among its arguments
    =       3.1415926535898

    : 
    : sqr(x)                      # square of x (x**2)
    =       9.8696044010894

    : sqrt(x)                     # square root of x (x**0.5)
    =       1.7724538509055

    : cbrt(x)                     # cubic root of x (x**(1/3))
    =       1.4645918875615

    : 
    : cos(x)                      # trigonometric functions
    =       -1.0

    : acos(x)
    =       nan

    : cosh(x)
    =       11.591953275522

    : sin(x)
    =       1.2246467991474e-16

    : asin(x)
    =       nan

    : sinh(x)
    =       11.548739357258

    : tan(x)
    =       -1.2246467991474e-16

    : atan(x)
    =       1.2626272556789

    : tanh(x)
    =       0.99627207622075

    : atan(y, x)                  # arc tangent of y/x (in radians)
    =       0.71328454043905

    : atan2(y, x)                 # arc tangent of y/x (in radians)
    =       0.71328454043905

    : deg(x)                      # angle x (given in radians) in degrees
    =       180.0

    : rad(x)                      # angle x (given in degrees) in radians
    =       0.054831135561608

    : 
    : exp(x)                      # e**x
    =       23.140692632779

    : log(x)                      # logarithm of x in base e
    =       1.1447298858494

    : ln(x)                       # logarithm of x in base e
    =       1.1447298858494

    : log10(x)                    # logarithm of x in base 10
    =       0.49714987269413

    : log2(x)                     # logarithm of x in base 2
    =       1.6514961294723

    : log(b, x)                   # logarithm of x in base b
    =       0.95971311856939

### IEEE 754 representation

#### 32 bit numbers

    : x = pi, n = 0x402df854
    =       1076754516
    hex     0x402DF854

    : 
    : float32
    : x = pi, n = 0x402df854
    =       1076754516
    hex32   0x402DF854
    IEEE    2.7182817459106 <=> 0x402DF854

    : float2ieee(x)               # IEEE 754 representation of x (32 bits)
    =       1078530011
    hex32   0x40490FDB
    IEEE    3.1415927410126 <=> 0x40490FDB

    : ieee2float(n)               # 32 bit float value of the IEEE 754 integer n
    =       2.7182817459106
    IEEE    2.7182817459106 <=> 0x402DF854

#### 64 bit numbers

    : x = pi, n = 0x4005bf0a8b145769
    =       4613303445314885481
    hex     0x4005BF0A8B145769

    : 
    : float64
    : x = pi, n = 0x4005bf0a8b145769
    =       4613303445314885481
    hex64   0x4005BF0A8B145769
    IEEE    2.718281828459 <=> 0x4005BF0A8B145769

    : double2ieee(x)              # IEEE 754 representation of x (64 bits)
    =       4614256656552045848
    hex64   0x400921FB54442D18
    IEEE    3.1415926535898 <=> 0x400921FB54442D18

    : ieee2double(n)              # 64 bit float value of the IEEE 754 integer n
    =       2.718281828459
    IEEE    2.718281828459 <=> 0x4005BF0A8B145769

### Specific values

    : x = pi
    =       3.1415926535898

    : 
    : isfinite(x)                 # true if x is finite
    =       true

    : isinf(x)                    # true if x is infinite
    =       false

    : isnan(x)                    # true if x is not a number
    =       false

    : isnormal(x)                 # true if x is a normalized number
    =       true

## Other commands

| Other commands  | Description              |
|:----------------|:-------------------------|
| bye, exit, quit | quit                     |
| help            | print this help          |
| version         | print the version number |

# Online help

    : help
    +---------------------------------------------------------------------+
    |      CALCULADOIRA       v. 4.5.1 |  https://github.com/cdsoft/calculadoira  |
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


    Constants                   Value
    =========================== ===============================================

    nan, NaN                    Not a Number
    inf, Inf                    Infinite
    pi                          3.1415926535898
    e                           2.718281828459

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

    edit                        Edit calculadoira.ini
    bye exit quit               Quit
    ?                           Help summary
    help                        Full help
    license                     Show Calculadoira license

    Credits
    =======

    Calculadoira: https://github.com/cdsoft/calculadoira
    LuaX        : https://github.com/cdsoft/luax

    "Calculadoira" means "Calculator" in Occitan.
