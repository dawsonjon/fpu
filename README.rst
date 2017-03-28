IEEE 754 floating point arithmetic
==================================

Synthesiseable IEEE 754 floating point library in Verilog.

	+ Provides Divider, Multiplier and Adder
	+ Provides float_to_int and int_to_float
	+ Supports Denormal Numbers
	+ Round-to-nearest (ties to even)
	+ Optimised for area
	+ Over 100,000,000 test vectors (for each function)

Test
====

Dependencies
------------
To run the test suite, you will need the g++ compiler, and the icarus verilog
simulator.

Procedure
---------

For each arithmetic function, a test-bench is provided. The testbench consists
of a Python script run_test.py and a Simple C model used as the reference for
verification. The C reference model is contained in the c_test subfolder. To
recompile the C model run the following command::
	
	~$ cd c_test
	~$ g++ -o test test.cpp

The test suite consists of corner cases, edge cases, and 100,000,000
constrained random vectors. The test suite could take several days to run to
completion. To run the test suite, run the following command::

	~$ ./run_test.py

Interface
=========

Each arithmetic module accepts two 32-bit data streams a and b, and outputs a
data stream z.  The stream interface is decribed in the `chips manual
<http://dawsonjon.github.io/Chips-2.0/language_reference/index.html#physical-interface>`_
manual.
