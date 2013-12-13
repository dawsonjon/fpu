#!/usr/bin/env python

from chips.api.api import *
import sys
import subprocess
from random import randint
from random import seed

def compile():
    subprocess.call("iverilog -o test_bench_tb file_reader_a.v file_reader_b.v file_writer.v adder.v test_bench.v test_bench_tb.v", shell=True)

def run_test(stimulus_a, stimulus_b):

    test = subprocess.Popen("c_test/test", stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    stim_a = open("stim_a", 'w');
    stim_b = open("stim_b", 'w');
    expected_responses = []
    for a, b in zip(stimulus_a, stimulus_b):
        test.stdin.write(str(a)+"\n")
        test.stdin.write(str(b)+"\n")
        stim_a.write(str(a) + "\n")
        stim_b.write(str(b) + "\n")
        z = int(test.stdout.readline())
        expected_responses.append(z)
    test.terminate()
    stim_a.close()
    stim_b.close()
    subprocess.call("./test_bench_tb", shell=True)

    stim_z = open("resp_z");
    actual_responses = []
    for value in stim_z:
        actual_responses.append(int(value))

    if len(actual_responses) < len(expected_responses):
        print "Fail ... not enough results"
        exit(0)

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

compile()
count = 0

#regression tests
stimulus_a = [0x22cb525a, 0x40000000, 0x83e73d5c, 0xbf9b1e94, 0x34082401, 0x5e8ef81, 0x5c75da81, 0x2b017]
stimulus_b = [0xadd79efa, 0xC0000000, 0x1c800000, 0xc038ed3a, 0xb328cd45, 0x114f3db, 0x2f642a39, 0xff3807ab]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

#corner cases
from itertools import permutations
stimulus_a = [i[0] for i in permutations([0x80000000, 0x00000000, 0x7f800000, 0xff800000, 0x7fc00000, 0xffc00000], 2)]
stimulus_b = [i[1] for i in permutations([0x80000000, 0x00000000, 0x7f800000, 0xff800000, 0x7fc00000, 0xffc00000], 2)]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

#edge cases
stimulus_a = [0x80000000 for i in xrange(1000)]
stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_a = [0x00000000 for i in xrange(1000)]
stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_b = [0x80000000 for i in xrange(1000)]
stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_b = [0x00000000 for i in xrange(1000)]
stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_a = [0x7F800000 for i in xrange(1000)]
stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_a = [0xFF800000 for i in xrange(1000)]
stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_b = [0x7F800000 for i in xrange(1000)]
stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_b = [0xFF800000 for i in xrange(1000)]
stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_a = [0x7FC00000 for i in xrange(1000)]
stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_a = [0xFFC00000 for i in xrange(1000)]
stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_b = [0x7FC00000 for i in xrange(1000)]
stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

stimulus_b = [0xFFC00000 for i in xrange(1000)]
stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
run_test(stimulus_a, stimulus_b)
count += len(stimulus_a)
print count, "vectors passed"

#seed(0)
for i in xrange(100000):
    stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
    stimulus_b = [randint(0, 1<<32) for i in xrange(1000)]
    run_test(stimulus_a, stimulus_b)
    count += 1000
    print count, "vectors passed"
