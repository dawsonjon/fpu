module test_bench(clk, rst);
  input  clk;
  input  rst;
  wire   [15:0] wire_140082755103848;
  wire   wire_140082755103848_stb;
  wire   wire_140082755103848_ack;
  wire   [15:0] wire_19340104;
  wire   wire_19340104_stb;
  wire   wire_19340104_ack;
  wire   [15:0] wire_19340248;
  wire   wire_19340248_stb;
  wire   wire_19340248_ack;
  file_reader_a file_reader_a_19341184(
    .clk(clk),
    .rst(rst),
    .output_z(wire_140082755103848),
    .output_z_stb(wire_140082755103848_stb),
    .output_z_ack(wire_140082755103848_ack));
  file_reader_b file_reader_b_140082755127416(
    .clk(clk),
    .rst(rst),
    .output_z(wire_19340104),
    .output_z_stb(wire_19340104_stb),
    .output_z_ack(wire_19340104_ack));
  file_writer file_writer_140082755052248(
    .clk(clk),
    .rst(rst),
    .input_a(wire_19340248),
    .input_a_stb(wire_19340248_stb),
    .input_a_ack(wire_19340248_ack));
  divider divider_140082755052176(
    .clk(clk),
    .rst(rst),
    .input_a(wire_140082755103848),
    .input_a_stb(wire_140082755103848_stb),
    .input_a_ack(wire_140082755103848_ack),
    .input_b(wire_19340104),
    .input_b_stb(wire_19340104_stb),
    .input_b_ack(wire_19340104_ack),
    .output_z(wire_19340248),
    .output_z_stb(wire_19340248_stb),
    .output_z_ack(wire_19340248_ack));
endmodule
