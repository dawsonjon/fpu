#!/usr/bin/env python

import sys
import subprocess
from random import randint
from random import seed
import struct

def compile():
    subprocess.call("iverilog -o test_bench_tb file_reader_a.v file_writer.v int_to_float.v test_bench.v test_bench_tb.v", shell=True)

def run_test(stimulus_a):

    test = subprocess.Popen("c_test/test", stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    stim_a = open("stim_a", 'w');
    expected_responses = []
    for a in stimulus_a:
        test.stdin.write(str(a)+"\n")
        stim_a.write(str(a) + "\n")
        z = int(test.stdout.readline())
        expected_responses.append(z)
    test.terminate()
    stim_a.close()
    subprocess.call("./test_bench_tb", shell=True)

    stim_z = open("resp_z");
    actual_responses = []
    for value in stim_z:
        actual_responses.append(int(value))

    if len(actual_responses) < len(expected_responses):
        print "Fail ... not enough results"
        exit(0)

    for expected, actual, a in zip(expected_responses, actual_responses, stimulus_a):
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
            print a

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
stimulus_a = [0xf5360a58, 0x2f005329, 0x34082401, 0xba57711a, 0xbf9b1e94, 0x5e8ef81, 0x5c75da81, 0x2b017]
run_test(stimulus_a)
count += len(stimulus_a)
print count, "vectors passed"

#corner cases
from itertools import permutations
stimulus_a = [i for i in [0x80000000, 0x00000000, 0x7f800000, 0xff800000, 0x7fc00000, 0xffc00000]]
run_test(stimulus_a)
count += len(stimulus_a)
print count, "vectors passed"

#seed(0)
for i in xrange(100000):
    stimulus_a = [randint(0, 1<<32) for i in xrange(1000)]
    run_test(stimulus_a)
    count += 1000
    print count, "vectors passed"
