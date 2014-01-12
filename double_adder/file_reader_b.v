//name : file_reader_a
//tag : c components
//output : output_z:16
//source_file : file_reader_a.c
///=============
///
///*Created by C2CHIP*

`timescale 1ns/1ps
module file_reader_b(output_z_ack,clk,rst,output_z,output_z_stb);

  integer file_count;
  integer input_file_0;

  input     clk;
  input     rst;

  output    [63:0] output_z;
  output    output_z_stb;
  input     output_z_ack;

  reg       [63:0] s_output_z;
  reg       s_output_z_stb;

  reg       [31:0] low;
  reg       [31:0] high;
  reg       [1:0] state;

  initial
  begin
    input_file_0 = $fopenr("stim_b");
  end


  always @(posedge clk)
  begin

  case(state)

    0:
    begin
      state <= 1;
    end

    1:
    begin
      file_count = $fscanf(input_file_0, "%d", high);
      state <= 2;
    end

    2:
    begin
      file_count = $fscanf(input_file_0, "%d", low);
      state <= 3;
    end

    3:
    begin
      s_output_z_stb <= 1;
      s_output_z[63:32] <= high;
      s_output_z[31:0]  <= low;
      if(s_output_z_stb && output_z_ack) begin
          s_output_z_stb <= 0;
          state <= 0;
      end
    end

   endcase
   if (rst == 1'b1) begin
     state <= 0;
     s_output_z_stb <= 0;
   end
  end
  assign output_z_stb = s_output_z_stb;
  assign output_z = s_output_z;

endmodule
