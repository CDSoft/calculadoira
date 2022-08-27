% Calculadoira Manual
% Christophe Delord
% {{mdate}}

<!--
Calculadoira
Copyright (C) 2011-2022 Christophe Delord
http://cdelord.fr/calculadoira

This file is part of Calculadoira.

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
-->

Introduction
============

Calculadoira is a simple yet powerful calculator.
Unlike most of other calculators, Calculadoira is based on a textual interface.
It may seem a bit spartan and outdated but entering expressions with the keyboard
is way easier than with a mouse.
And you get nice editing features for free (edition, copy/paste, history, ...).

You can contribute to [Calculadoira on GitHub](https://github.com/CDSoft/calculadoira).

License
=======

~~~~~~~~~~~~~~~~~~ {cmd=bash}
echo license | calculadoira | sed -e '1,/: license/d'
~~~~~~~~~~~~~~~~~~

Download and installation
=========================

[LuaX]: http://cdelord.fr/luax
[Panda]: http://cdelord.fr/panda
[Pandoc]: http://pandoc.org/

**Installation from sources:**

- Prerequisites
    - [LuaX]
    - [Panda] and [Pandoc] to generate the documentation (optional)

``` bash
# First install LuaX
$ git clone https://github.com/CDSoft/luax && make install -C luax
# Then Calculadoira
$ git clone https://github.com/CDSoft/calculadoira && make install -C calculadoira
```

**Binaries:**

Some binaries are available here:

OS              Calculadoira executable
--------------- ------------------------------------------------------------------------
Linux           [calculadoira-x86_64-linux-musl](http://cdelord.fr/calculadoira/calculadoira-x86_64-linux-musl)
Raspberry Pi    [calculadoira-aarch64-linux-musl](http://cdelord.fr/calculadoira/calculadoira-aarch64-linux-musl)
MacOS (Intel)   [calculadoira-x86_64-macos-gnu](http://cdelord.fr/calculadoira/calculadoira-x86_64-macos-gnu)
MacOS (ARM)     [calculadoira-aarch64-macos-gnu](http://cdelord.fr/calculadoira/calculadoira-aarch64-macos-gnu)
Windows         [calculadoira-x86_64-windows-gnu.exe](http://cdelord.fr/calculadoira/calculadoira-x86_64-windows-gnu.exe)

Screenshot
==========

~~~~~~~~~~~~~~~~~~ {cmd=bash}
calculadoira < /dev/null | sed -e '/loading/,$d'
~~~~~~~~~~~~~~~~~~

Usage
=====

Calculadoira is a interactive terminal calculator.
Expressions are entered with the keyboard, evaluated and the result is printed.
The next section lists all the operators and functions provided by Calculadoira.

A typical interactive session looks like this:

``` meta
calculadoira_full = "calculadoira < %s | expand | sed /loading/d"
```

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira_full}}"}
x = 21
y = 2
(x * y) ** 2
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

User's manual
=============

``` meta
calculadoira = "calculadoira < %s | expand | sed -e '1,/loading/d'"
```

## Numbers

### Integers

Integers can be decimal, hexadecimal, octal or binary numbers:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
42
0x24
0o37
0b1010
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Rational numbers

Rational numbers can be used to make *exact* computations instead of
using floating point numbers.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
1 + 2/3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Some functions don't support rational numbers and will produce floating point numbers.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
1/2 + cos(0)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Floating point numbers

Floating point numbers are single (32 bit) or double (64 bits) precision
floating point numbers.

They are represented internally by 64 bit numbers but can be converted to 32 bit
numbers as well as to their IEEE 754 representation.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
3.14
1.23e-6
e
pi
float32
float64
nan
inf
-inf
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Automatic type conversion

Number types are automatically converted in a way to preserve the best precision.
Integers are preferred to rational numbers and rational numbers are preferred
to floating point numbers.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
1+2/3
1/3+2/3
(2/3) * 0.5
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Display mode

By default only the raw value of the result is displayed.
The user can activate additional display modes by selecting:

- the integral base (`dec`, `hex`, `oct`, `bin`)
- the number of bits (`8`, `16`, `32`, `64`)
- the IEEE 754 representation of floating point numbers (`float32`, `float64`)
- `reset` resets the display mode

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
42424242
dec8            # 8 bit decimal numbers
hex16           # 16 bit hexadecimal numbers
oct32           # 32 bit octal numbers
bin64           # 64 bit binary numbers
reset           # raw decimal value only
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Calculadoira automatically activates some display modes under some circonstances:

- integer entered in a specific base
- usage of a bitwise operator in an expression

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
4               # only the default display mode
0b100           # this number activates the binary display mode
1<<10           # this operator activates the hexadecimal display mode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Booleans

Boolean values can be used in conditional and boolean expressions.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
true
false
true and false
1+1 == 2
1+1==2 ? "ok" : "bug"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Operators

### Arithmetic operators

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
x = 13
-x
+x
x + 1
x - 1
x * 2
x / 5
x // 5                  # integral division
x % 5                   # integral remainder (Euclidean division)
x ** 2
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Bitwise operators

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
bin16
~1                      # bitwise complement
1 | 4                   # bitwise or
0b1100 ^ 0b0110         # bitwise exclusive or
0b1100 & 0b0110         # bitwise and
1 << 10                 # left shift
1024 >> 1               # right shift
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Boolean operators

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
not true
true or false
true xor false
true and false
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Comparison operators

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
12 < 13
12 <= 13
12 > 13
12 >= 13
12 == 13
12 != 13
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Operator precedence

From highest to lowest precedence:

Operator family             Syntax
--------------------------- -----------------------------
Precedence overloading      `(...)`
Function evaluation         `f(...)`
Factorial                   `x!`
Exponentiation              `x**y`
Unary operators             `+x`, `-y`, `~z`
Multiplicative operators    `*` `/` `%` `&` `<<` `>>`
Additive operators          `+` `-` `|` `^`
Relational operators        `<` `<=` `>` `>=` `==` `!=`
Logical not                 `not x`
Logical and                 `and`
Logical or                  `or` `xor`
Ternary operator            `x ? y : z`
Assignement                 `x = y`
Blocks                      `expr1, ..., exprn`

## Variables

Calculadoira can define and reuse variables.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
x = 1
y = 2
x+y
y = 3
x+y
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Functions

Calculadoira can also define functions.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
f(x) = 2 * x
f(5)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Functions can be defined with multiple statements and be recursive.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
fib(n) = (n <= 1 ? 1 : (f1=fib(n-1), f2=fib(n-2), f1+f2))
fib(1)
fib(10)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can see in the previous example that the evaluation is lazy!
Thanks to laziness, functions can also be mutually recursive.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
isEven(n) = n == 0 ? true : isOdd(n-1)
isOdd(n) = n == 0 ? false : isEven(n-1)
isEven(10)
isOdd(10)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Builtin functions

### Type conversion

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
int(pi)                     # Integral part
float(2/3)                  # Conversion to floating point numbers
rat(pi)                     # Rational approximation
rat(pi, 1e-2)               # Rational approximation with a given precision
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Math

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
x = pi, y = e, b = 3

abs(x)                      # absolute value of x
ceil(x)                     # smallest integer larger than or equal to x
floor(x)                    # largest integer smaller than or equal to x
round(x)                    # round to the nearest integer
trunc(x)                    # round toward zero
mantissa(x)                 # m such that x = m2e, |m| is in [0.5, 1[
exponent(x)                 # e such that x = m2e, e is an integer
int(x)                      # integral part of x
fract(x)                    # fractional part of x
min(x, y)                   # minimum value among its arguments
max(x, y)                   # maximum value among its arguments

sqr(x)                      # square of x (x**2)
sqrt(x)                     # square root of x (x**0.5)
cbrt(x)                     # cubic root of x (x**(1/3))

cos(x)                      # trigonometric functions
acos(x)
cosh(x)
sin(x)
asin(x)
sinh(x)
tan(x)
atan(x)
tanh(x)
atan(y, x)                  # arc tangent of y/x (in radians)
atan2(y, x)                 # arc tangent of y/x (in radians)
deg(x)                      # angle x (given in radians) in degrees
rad(x)                      # angle x (given in degrees) in radians

exp(x)                      # e**x
log(x)                      # logarithm of x in base e
ln(x)                       # logarithm of x in base e
log10(x)                    # logarithm of x in base 10
log2(x)                     # logarithm of x in base 2
log(b, x)                   # logarithm of x in base b
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### IEEE 754 representation

#### 32 bit numbers

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
x = pi, n = 0x402df854

float32
float2ieee(x)               # IEEE 754 representation of x (32 bits)
ieee2float(n)               # 32 bit float value of the IEEE 754 integer n
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#### 64 bit numbers

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
x = pi, n = 0x4005bf0a8b145769

float64
double2ieee(x)              # IEEE 754 representation of x (64 bits)
ieee2double(n)              # 64 bit float value of the IEEE 754 integer n
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### Specific values

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
x = pi

isfinite(x)                 # true if x is finite
isinf(x)                    # true if x is infinite
isnan(x)                    # true if x is not a number
isnormal(x)                 # true if x is a normalized number
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

## Other commands

Other commands              Description
--------------------------- ---------------------------
bye, exit, quit             quit
help                        print this help
version                     print the version number

Online help
===========

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {cmd="{{calculadoira}}"}
help
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
