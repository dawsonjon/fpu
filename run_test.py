from chips.api.api import *

tb = Chip("test_bench")
file_reader = Component("file_reader")
file_writer = Component("file_writer")
divider = VerilogComponent("divider", ["a", "b"], ["z"], "")

a = Wire(Chip)
b = Wire(Chip)
z = Wire(Chip)

file_reader(tb, {}, {"z":a})
file_reader(tb, {}, {"z":b})
file_writer(tb, {"a": z}, {})
divider(tb, {"a":a, "b":b}, {"z":z})

tb.generate_verilog(10000)
tb.compile_verilog(True)
