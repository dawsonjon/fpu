module test_bench(clk, rst);
  input  clk;
  input  rst;
  wire   [63:0] wire_39069600;
  wire   wire_39069600_stb;
  wire   wire_39069600_ack;
  wire   [63:0] wire_39795024;
  wire   wire_39795024_stb;
  wire   wire_39795024_ack;
  wire   [63:0] wire_39795168;
  wire   wire_39795168_stb;
  wire   wire_39795168_ack;
  file_reader_a file_reader_a_39796104(
    .clk(clk),
    .rst(rst),
    .output_z(wire_39069600),
    .output_z_stb(wire_39069600_stb),
    .output_z_ack(wire_39069600_ack));
  file_reader_b file_reader_b_39759816(
    .clk(clk),
    .rst(rst),
    .output_z(wire_39795024),
    .output_z_stb(wire_39795024_stb),
    .output_z_ack(wire_39795024_ack));
  file_writer file_writer_39028208(
    .clk(clk),
    .rst(rst),
    .input_a(wire_39795168),
    .input_a_stb(wire_39795168_stb),
    .input_a_ack(wire_39795168_ack));
  double_divider divider_39759952(
    .clk(clk),
    .rst(rst),
    .input_a(wire_39069600),
    .input_a_stb(wire_39069600_stb),
    .input_a_ack(wire_39069600_ack),
    .input_b(wire_39795024),
    .input_b_stb(wire_39795024_stb),
    .input_b_ack(wire_39795024_ack),
    .output_z(wire_39795168),
    .output_z_stb(wire_39795168_stb),
    .output_z_ack(wire_39795168_ack));
endmodule
