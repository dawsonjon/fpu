//name : file_reader_a
//tag : c components
//output : output_z:16
//source_file : file_reader_a.c
///=============
///
///*Created by C2CHIP*

`timescale 1ns/1ps
module file_reader_a(output_z_ack,clk,rst,output_z,output_z_stb);

  integer file_count;
  integer input_file_0;

  input     clk;
  input     rst;

  output    [31:0] output_z;
  output    output_z_stb;
  input     output_z_ack;

  reg       [31:0] s_output_z;
  reg       s_output_z_stb;

  reg       [31:0] low;
  reg       [1:0]  state;

  initial
  begin
    input_file_0 = $fopenr("stim_a");
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
      file_count = $fscanf(input_file_0, "%d\n", low);
      state <= 2;
    end

    2:
    begin
      s_output_z_stb <= 1;
      s_output_z <= low;
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
