#!/usr/bin/env python3

# Calculadoira
# Copyright (C) 2011-2024 Christophe Delord
# https://github.com/cdsoft/calculadoira
#
# This file is part of Calculadoira.
#
# Calculadoira is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Calculadoira is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Calculadoira.  If not, see <http://www.gnu.org/licenses/>.

""" Regression tests for Calculadoira
"""

import re
import subprocess
import sys
import atexit

class Calc:

    def __init__(self, exe):
        self.p = subprocess.Popen(exe, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE);
        atexit.register(self.close)
        self.nbtests = 0
        self.nberr = 0

    def close(self):
        assert(self.p.stdin)
        self.p.stdin.write(b"bye\n")

    def __call__(self, input):
        assert(self.p.stdin)
        assert(self.p.stdout)
        self.p.stdin.write(str.encode(input+"\n"))
        self.p.stdin.flush()
        while True:
            line = self.p.stdout.readline()
            if line.startswith(b"="):
                v = line[1:].decode().strip().replace("_", "")
                if '/' in v:
                    return "rat", self.evalfloat(v)
                else:
                    return "int", self.evalint(v)
            if line.startswith(b"!"):
                return [line[1:].strip()]*2

    def evalfloat(self, expr):
        expr = re.sub(r"(\d+)", r"\1.", expr)
        try:
            expr = expr.replace("false", "False").replace("true", "True")
            return eval(expr)
        except OverflowError:
            return None
        except TypeError:
            return None

    def evalint(self, expr):
        expr = expr.replace("false", "False").replace("true", "True")
        return eval(expr)

    def test(self, expr):
        self.nbtests += 1
        print("test %d: %s ="%(self.nbtests, expr), end='')
        sys.stdout.flush()
        try:
            evint = self.evalint(expr)
            evfloat = self.evalfloat(expr)
        except ZeroDivisionError:
            evint = evfloat = "Division by zero"
        vtype, v = self(expr)
        print("%s (%s)"%(v, vtype))
        if (v == 'int' and v != evint) or (v == 'rat' and str(v) != str(evfloat)):
            self.nberr += 1
            print("Error: %s is not %s (%s)"%(expr, evfloat, evint))

    def summary(self):
        if self.nberr == 0:
            print("%d tests: all pass"%self.nbtests)
        else:
            print("%d tests: %d errors"%(self.nbtests, self.nberr))
            sys.exit(1)

calc = Calc(sys.argv[1])

for a in [0, 1, 15, 20, 21, 43, 511, 512, 123456789, 987654321]:
    for sa in [-1, 1]:
        for b in [0, 1, 15, 20, 21, 43, 511, 512, 23456789, 987654321]:
            for sb in [-1, 1]:
                for op in "+ - * / // % ** | & ^ >> << ~ < <= > >= == !=".split():
                    if op == '%' and sb == -1: continue
                    if op == '**' and b > 100: continue
                    if op in ["|", "&", "^", "<<", ">>"] and (sa == -1 or sb == -1): continue
                    if op in ["<<", ">>"] and b > 1000: continue
                    if op in ["+", "-"]:
                        calc.test("%s %s"%(op, a*sa))
                        calc.test("%s %s"%(op, b*sb))
                    if op in ["~"]:
                        calc.test("%s %s"%(op, a*sa))
                        calc.test("%s %s"%(op, b*sb))
                    else:
                        calc.test("%s %s %s"%(a*sa, op, b*sb))

for a in ["false", "true"]:
    for b in ["false", "true"]:
        for op in "not or and".split():
            if op in ["not"]:
                calc.test("%s %s"%(op, a))
                calc.test("%s %s"%(op, b))
            else:
                calc.test("%s %s %s"%(a, op, b))

calc.summary()
