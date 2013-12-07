module test_bench(clk, rst);
  input  clk;
  input  rst;
  wire   [15:0] wire_20477928;
  wire   wire_20477928_stb;
  wire   wire_20477928_ack;
  wire   [15:0] wire_21236120;
  wire   wire_21236120_stb;
  wire   wire_21236120_ack;
  wire   [15:0] wire_21236264;
  wire   wire_21236264_stb;
  wire   wire_21236264_ack;
  file_reader_a file_reader_a_21237200(
    .clk(clk),
    .rst(rst),
    .output_z(wire_20477928),
    .output_z_stb(wire_20477928_stb),
    .output_z_ack(wire_20477928_ack));
  file_reader_b file_reader_b_20440632(
    .clk(clk),
    .rst(rst),
    .output_z(wire_21236120),
    .output_z_stb(wire_21236120_stb),
    .output_z_ack(wire_21236120_ack));
  file_writer file_writer_21201048(
    .clk(clk),
    .rst(rst),
    .input_a(wire_21236264),
    .input_a_stb(wire_21236264_stb),
    .input_a_ack(wire_21236264_ack));
  divider divider_21200976(
    .clk(clk),
    .rst(rst),
    .input_a(wire_20477928),
    .input_a_stb(wire_20477928_stb),
    .input_a_ack(wire_20477928_ack),
    .input_b(wire_21236120),
    .input_b_stb(wire_21236120_stb),
    .input_b_ack(wire_21236120_ack),
    .output_z(wire_21236264),
    .output_z_stb(wire_21236264_stb),
    .output_z_ack(wire_21236264_ack));
endmodule
