#!/usr/bin/env python

""" Regression tests for Calculadoira
"""

import re
import subprocess
import sys
import time
import atexit

class Calc:

    def __init__(self):
        self.p = subprocess.Popen("bl calculadoira.lua", shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE);
        atexit.register(self.close)
        self.nbtests = 0
        self.nberr = 0

    def close(self):
        self.p.stdin.write("bye\n")

    def __call__(self, input):
        self.p.stdin.write(input+"\n")
        while True:
            line = self.p.stdout.readline()
            if line.startswith("="):
                v = line[1:].strip().replace("_", "")
                if '/' in v:
                    return "rat", self.evalfloat(v)
                else:
                    return "int", self.evalint(v)
            if line.startswith("!"):
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
        print "test %d: %s ="%(self.nbtests, expr),
        sys.stdout.flush()
        try:
            evint = self.evalint(expr)
            evfloat = self.evalfloat(expr)
        except ZeroDivisionError:
            evint = evfloat = "Division by zero"
        vtype, v = self(expr)
        print "%s (%s)"%(v, vtype)
        if (v == 'int' and v != evint) or (v == 'rat' and str(v) != str(evfloat)):
            self.nberr += 1
            print "Error: %s is not %s (%s)"%(expr, evfloat, evint)

    def summary(self):
        if self.nberr == 0:
            print "%d tests: all pass"%self.nbtests
        else:
            print "%d tests: %d errors"%(self.nbtests, self.nberr)

calc = Calc()

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
