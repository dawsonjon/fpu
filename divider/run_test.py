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
    tb.generate_testbench(100000)

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
    test.terminate()
    stim_a.close()
    stim_b.close()
    tb.compile_iverilog(True)
    #tb.compile_iverilog()

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
            expected_mantissa = expected & 0x7fffff
            expected_exponent = ((expected & 0x7f800000) >> 23) - 127
            expected_sign = ((expected & 0x80000000) >> 31)
            actual_mantissa = actual & 0x7fffff
            actual_exponent = ((actual & 0x7f800000) >> 23) - 127
            actual_sign = ((actual & 0x80000000) >> 31)
            if expected_exponent == 128 and expected_mantissa != 0:
                if(actual_exponent == 128):
                    passed = True
            else:
                passed = False
        else:
             passed = True

        if not passed:

            print "Fail ... expected:", hex(expected), "actual:", hex(actual)

            print hex(a)
            print "a mantissa:", a & 0x7fffff
            print "a exponent:", ((a & 0x7f800000) >> 23) - 127
            print "a sign:", ((a & 0x80000000) >> 31)

            print hex(b)
            print "b mantissa:", b & 0x7fffff
            print "b exponent:", ((b & 0x7f800000) >> 23) - 127
            print "b sign:", ((b & 0x80000000) >> 31)

            print hex(expected)
            print "expected mantissa:", expected & 0x7fffff
            print "expected exponent:", ((expected & 0x7f800000) >> 23) - 127
            print "expected sign:", ((expected & 0x80000000) >> 31)

            print hex(actual)
            print "actual mantissa:", actual & 0x7fffff
            print "actual exponent:", ((actual & 0x7f800000) >> 23) - 127
            print "actual sign:", ((actual & 0x80000000) >> 31)

            sys.exit(0)

tb = build_test_bench()
count = 0

#regression tests
stimulus_a = [0xbf9b1e94, 0x34082401, 0x5e8ef81, 0x5c75da81, 0x2b017]
stimulus_b = [0xc038ed3a, 0xb328cd45, 0x114f3db, 0x2f642a39, 0xff3807ab]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

#corner cases
from itertools import permutations
stimulus_a = [i[0] for i in permutations([0x80000000, 0x00000000, 0x7f800000, 0xff800000, 0x7fc00000, 0xffc00000], 2)]
stimulus_b = [i[1] for i in permutations([0x80000000, 0x00000000, 0x7f800000, 0xff800000, 0x7fc00000, 0xffc00000], 2)]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

#edge cases
stimulus_a = [0x80000000 for i in xrange(1000)]
stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_a = [0x00000000 for i in xrange(1000)]
stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_b = [0x80000000 for i in xrange(1000)]
stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_b = [0x00000000 for i in xrange(1000)]
stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_a = [0x7F800000 for i in xrange(1000)]
stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_a = [0xFF800000 for i in xrange(1000)]
stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_b = [0x7F800000 for i in xrange(1000)]
stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_b = [0xFF800000 for i in xrange(1000)]
stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_a = [0x7FC00000 for i in xrange(1000)]
stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_a = [0xFFC00000 for i in xrange(1000)]
stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_b = [0x7FC00000 for i in xrange(1000)]
stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_b = [0xFFC00000 for i in xrange(1000)]
stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
run_test(tb, stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

#seed(0)
for i in xrange(10000):
    stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
    stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
    run_test(tb, stimulus_a, stimulus_b)
    count += 1000
    print count, "vectors passed"
