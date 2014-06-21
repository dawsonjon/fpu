//name : file_writer
//tag : c components
//input : input_a:16
//source_file : file_writer.c
///===========
///
///*Created by C2CHIP*

`timescale 1ns/1ps
module file_writer(input_a,input_a_stb,clk,rst,input_a_ack);
  integer file_count;
  integer output_file_0;

  input     clk;
  input     rst;

  input     [63:0] input_a;
  input     input_a_stb;
  output    input_a_ack;

  reg       s_input_a_ack;
  reg       state;
  reg       [63:0] value;

  initial
  begin
    output_file_0 = $fopen("resp_z");
    $fclose(output_file_0);
  end


  always @(posedge clk)
  begin

    case(state)

        0:
        begin
            s_input_a_ack <= 1'b1;
            if (s_input_a_ack && input_a_stb) begin
               value <= input_a;
               s_input_a_ack <= 1'b0;
               state <= 1;
            end
        end

        1:
        begin
          output_file_0 = $fopena("resp_z");
          $fdisplay(output_file_0, "%d", value[63:32]);
          $fdisplay(output_file_0, "%d", value[31:0]);
          $fclose(output_file_0);
          state <= 0;
        end

    endcase
    if (rst == 1'b1) begin
      state <= 0;
      s_input_a_ack <= 0;
    end
  end
  assign input_a_ack = s_input_a_ack;

endmodule
