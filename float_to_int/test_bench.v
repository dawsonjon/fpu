module test_bench(clk, rst);
  input  clk;
  input  rst;
  wire   [31:0] wire_39069600;
  wire   wire_39069600_stb;
  wire   wire_39069600_ack;
  wire   [31:0] wire_39795168;
  wire   wire_39795168_stb;
  wire   wire_39795168_ack;
  file_reader_a file_reader_a_39796104(
    .clk(clk),
    .rst(rst),
    .output_z(wire_39069600),
    .output_z_stb(wire_39069600_stb),
    .output_z_ack(wire_39069600_ack));
  file_writer file_writer_39028208(
    .clk(clk),
    .rst(rst),
    .input_a(wire_39795168),
    .input_a_stb(wire_39795168_stb),
    .input_a_ack(wire_39795168_ack));
  float_to_int float_to_int_39759952(
    .clk(clk),
    .rst(rst),
    .input_a(wire_39069600),
    .input_a_stb(wire_39069600_stb),
    .input_a_ack(wire_39069600_ack),
    .output_z(wire_39795168),
    .output_z_stb(wire_39795168_stb),
    .output_z_ack(wire_39795168_ack));
endmodule
