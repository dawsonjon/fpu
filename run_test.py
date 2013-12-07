#!/usr/bin/env python

from chips.api.api import *
import sys
import subprocess
from random import randint
from random import seed


def build_test_bench():
    tb = Chip("test_bench")
    file_reader_a = Component("file_reader_a.c")
    file_reader_b = Component("file_reader_b.c")
    file_writer = Component("file_writer.c")
    divider = VerilogComponent("divider", ["a", "b"], ["z"], "")

    a = Wire(tb)
    b = Wire(tb)
    z = Wire(tb)

    file_reader_a(tb, {}, {"z":a})
    file_reader_b(tb, {}, {"z":b})
    file_writer(tb, {"a": z}, {})
    divider(tb, {"a":a, "b":b}, {"z":z})

    tb.generate_verilog()
    tb.generate_testbench(10000)

    return tb

def run_test(tb, stimulus_a, stimulus_b):

    test = subprocess.Popen("c_test/test", stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    stim_a = open("stim_a", 'w');
    stim_b = open("stim_b", 'w');
    expected_responses = []
    for a, b in zip(stimulus_a, stimulus_b):
        test.stdin.write(str(a)+"\n")
        test.stdin.write(str(b)+"\n")
        stim_a.write(str(a>>16) + "\n")
        stim_a.write(str(a&0xffff) + "\n")
        stim_b.write(str(b>>16) + "\n")
        stim_b.write(str(b&0xffff) + "\n")
        z = int(test.stdout.readline())
        expected_responses.append(z)
    stim_a.close()
    stim_b.close()
    tb.compile_iverilog(True)

    stim_z = open("resp_z");
    actual_responses = []
    high = True
    for value in stim_z:
        if high:
            high_word = int(value) << 16
        else:
            actual_responses.append(high_word | int(value))
        high = not high

    for expected, actual, a, b in zip(expected_responses, actual_responses, stimulus_a, stimulus_b):
        if(expected != actual):
            print "Fail ... expected:", hex(expected), "actual:", hex(actual)

            print "a mantissa:", a & 0x7fffff
            print "a exponent:", ((a & 0x7f800000) >> 23) - 127
            print "a sign:", ((a & 0x80000000) >> 31)

            print "b mantissa:", b & 0x7fffff
            print "b exponent:", ((b & 0x7f800000) >> 23) - 127
            print "b sign:", ((b & 0x80000000) >> 31)

            print "expected mantissa:", expected & 0x7fffff
            print "expected exponent:", ((expected & 0x7f800000) >> 23) - 127
            print "expected sign:", ((expected & 0x80000000) >> 31)

            print "actual mantissa:", actual & 0x7fffff
            print "actual exponent:", ((actual & 0x7f800000) >> 23) - 127
            print "actual sign:", ((actual & 0x80000000) >> 31)


            sys.exit(0)
        else:
            print "Pass"

tb = build_test_bench()
seed(0)
stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
run_test(tb, stimulus_a, stimulus_b)
