#!/usr/bin/env python

from chips.api.api import *
import sys
import subprocess
import atexit
from random import randint
from random import seed

children = []
def cleanup():
    for child in children:
        print "Terminating child process"
        child.terminate()
atexit.register(cleanup)

def compile():
    subprocess.call("iverilog -o test_bench_tb file_reader_a.v file_writer.v long_to_double.v test_bench.v test_bench_tb.v", shell=True)

def run_test(stimulus_a):

    process = subprocess.Popen("c_test/test", stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    children.append(process)
    stim_a = open("stim_a", 'w');
    expected_responses = []
    for a in stimulus_a:
        process.stdin.write(str(a)+"\n")
        stim_a.write(str(a>>32) + "\n")
        stim_a.write(str(a&0xffffffff) + "\n")
        z = long(process.stdout.readline())
        expected_responses.append(z)

    process.terminate()
    children.remove(process)

    stim_a.close()


    process = subprocess.Popen("./test_bench_tb", shell=True)
    children.append(process)
    process.wait()
    children.remove(process)

    stim_z = open("resp_z");
    actual_responses = []
    high = True
    for value in stim_z:
        if high:
            msb = int(value) << 32
            high = False
        else:
            actual_responses.append(msb | int(value))
            high = True

    if len(actual_responses) < len(expected_responses):
        print "Fail ... not enough results"
        exit(0)

    for expected, actual, a in zip(expected_responses, actual_responses, stimulus_a):
        if(expected != actual):
            expected_mantissa =   expected & 0x000fffffffffffff
            expected_exponent = ((expected & 0x7ff0000000000000) >> 52) - 1023
            expected_sign     = ((expected & 0x8000000000000000) >> 63)
            actual_mantissa   =     actual & 0x000fffffffffffff
            actual_exponent   = ((  actual & 0x7ff0000000000000) >> 52) - 1023
            actual_sign       = ((  actual & 0x8000000000000000) >> 63)
            if expected_exponent == 1024 and expected_mantissa != 0:
                if(actual_exponent == 1024):
                    passed = True
            else:
                passed = False
        else:
             passed = True

        if not passed:

            print "Fail ... expected:", hex(expected), "actual:", hex(actual)

            print hex(a)
            print "a mantissa:",                 a & 0x000fffffffffffff
            print "a exponent:",               ((a & 0x7ff0000000000000) >> 52) - 1023
            print "a sign:",                   ((a & 0x8000000000000000) >> 63)

            sys.exit(0)

compile()
count = 0

#regression tests
stimulus_a = [0x43e9cd2c912d5218, 0xce6964896a90c000L, 0xff80000000000000, 0xc3e8356aefb949d9L]
run_test(stimulus_a)
count += len(stimulus_a)
print count, "vectors passed"

#corner cases
from itertools import permutations
stimulus_a = [long(i) for i in [
    0x8000000000000000, 
    0x0000000000000000, 
    0x7ff8000000000000, 
    0xfff8000000000000, 
    0x7ff0000000000000, 
    0xfff0000000000000
]]
run_test(stimulus_a)
count += len(stimulus_a)
print count, "vectors passed"

#seed(0)
for i in xrange(100000):
    stimulus_a = [randint(0, 1<<64) for i in xrange(1000)]
    run_test(stimulus_a)
    count += 1000
    print count, "vectors passed"
