module test_bench(clk, rst);
  input  clk;
  input  rst;
  wire   [15:0] wire_140125095824560;
  wire   wire_140125095824560_stb;
  wire   wire_140125095824560_ack;
  wire   [15:0] wire_31177760;
  wire   wire_31177760_stb;
  wire   wire_31177760_ack;
  wire   [15:0] wire_31176968;
  wire   wire_31176968_stb;
  wire   wire_31176968_ack;
  file_reader_a file_reader_a_31178696(
    .clk(clk),
    .rst(rst),
    .output_z(wire_140125095824560),
    .output_z_stb(wire_140125095824560_stb),
    .output_z_ack(wire_140125095824560_ack));
  file_reader_b file_reader_b_140125095874000(
    .clk(clk),
    .rst(rst),
    .output_z(wire_31177760),
    .output_z_stb(wire_31177760_stb),
    .output_z_ack(wire_31177760_ack));
  file_writer file_writer_140125095848128(
    .clk(clk),
    .rst(rst),
    .input_a(wire_31176968),
    .input_a_stb(wire_31176968_stb),
    .input_a_ack(wire_31176968_ack));
  divider divider_140125095772960(
    .clk(clk),
    .rst(rst),
    .input_a(wire_140125095824560),
    .input_a_stb(wire_140125095824560_stb),
    .input_a_ack(wire_140125095824560_ack),
    .input_b(wire_31177760),
    .input_b_stb(wire_31177760_stb),
    .input_b_ack(wire_31177760_ack),
    .output_z(wire_31176968),
    .output_z_stb(wire_31176968_stb),
    .output_z_ack(wire_31176968_ack));
endmodule
