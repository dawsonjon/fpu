module test_bench(clk, rst);
  input  clk;
  input  rst;
  wire   [15:0] wire_140412587310328;
  wire   wire_140412587310328_stb;
  wire   wire_140412587310328_ack;
  wire   [15:0] wire_140412558007400;
  wire   wire_140412558007400_stb;
  wire   wire_140412558007400_ack;
  wire   [15:0] wire_140412558006608;
  wire   wire_140412558006608_stb;
  wire   wire_140412558006608_ack;
  file_reader_a file_reader_a_140412558008400(
    .clk(clk),
    .rst(rst),
    .output_z(wire_140412587310328),
    .output_z_stb(wire_140412587310328_stb),
    .output_z_ack(wire_140412587310328_ack));
  file_reader_b file_reader_b_140412587357464(
    .clk(clk),
    .rst(rst),
    .output_z(wire_140412558007400),
    .output_z_stb(wire_140412558007400_stb),
    .output_z_ack(wire_140412558007400_ack));
  file_writer file_writer_140412587333896(
    .clk(clk),
    .rst(rst),
    .input_a(wire_140412558006608),
    .input_a_stb(wire_140412558006608_stb),
    .input_a_ack(wire_140412558006608_ack));
  divider divider_140412587258728(
    .clk(clk),
    .rst(rst),
    .input_a(wire_140412587310328),
    .input_a_stb(wire_140412587310328_stb),
    .input_a_ack(wire_140412587310328_ack),
    .input_b(wire_140412558007400),
    .input_b_stb(wire_140412558007400_stb),
    .input_b_ack(wire_140412558007400_ack),
    .output_z(wire_140412558006608),
    .output_z_stb(wire_140412558006608_stb),
    .output_z_ack(wire_140412558006608_ack));
endmodule
