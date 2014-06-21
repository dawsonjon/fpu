//Integer to IEEE Floating Point Converter (Double Precision)
//Copyright (C) Jonathan P Dawson 2013
//2013-12-12
module long_to_double(
        input_a,
        input_a_stb,
        output_z_ack,
        clk,
        rst,
        output_z,
        output_z_stb,
        input_a_ack);

  input     clk;
  input     rst;

  input     [63:0] input_a;
  input     input_a_stb;
  output    input_a_ack;

  output    [63:0] output_z;
  output    output_z_stb;
  input     output_z_ack;

  reg       s_output_z_stb;
  reg       [63:0] s_output_z;
  reg       s_input_a_ack;
  reg       s_input_b_ack;

  reg       [2:0] state;
  parameter get_a         = 3'd0,
            convert_0     = 3'd1,
            convert_1     = 3'd2,
            convert_2     = 3'd3,
            round         = 3'd4,
            pack          = 3'd5,
            put_z         = 3'd6;

  reg [63:0] a, z, value;
  reg [52:0] z_m;
  reg [10:0] z_r;
  reg [10:0] z_e;
  reg z_s;
  reg guard, round_bit, sticky;

  always @(posedge clk)
  begin

    case(state)

      get_a:
      begin
        s_input_a_ack <= 1;
        if (s_input_a_ack && input_a_stb) begin
          a <= input_a;
          s_input_a_ack <= 0;
          state <= convert_0;
        end
      end

      convert_0:
      begin
        if ( a == 0 ) begin
          z_s <= 0;
          z_m <= 0;
          z_e <= -1023;
          state <= pack;
        end else begin
          value <= a[63] ? -a : a;
          z_s <= a[63];
          state <= convert_1;
        end
      end

      convert_1:
      begin
        z_e <= 63;
        z_m <= value[63:11];
        z_r <= value[10:0];
        state <= convert_2;
      end

      convert_2:
      begin
        if (!z_m[52]) begin
          z_e <= z_e - 1;
          z_m <= z_m << 1;
          z_m[0] <= z_r[10];
          z_r <= z_r << 1;
        end else begin
          guard <= z_r[10];
          round_bit <= z_r[9];
          sticky <= z_r[8:0] != 0;
          state <= round;
        end
      end

      round:
      begin
        if (guard && (round_bit || sticky || z_m[0])) begin
          z_m <= z_m + 1;
          if (z_m == 53'h1fffffffffffff) begin
            z_e <=z_e + 1;
          end
        end
        state <= pack;
      end

      pack:
      begin
        z[51 : 0] <= z_m[51:0];
        z[62 : 52] <= z_e + 1023;
        z[63] <= z_s;
        state <= put_z;
      end

      put_z:
      begin
        s_output_z_stb <= 1;
        s_output_z <= z;
        if (s_output_z_stb && output_z_ack) begin
          s_output_z_stb <= 0;
          state <= get_a;
        end
      end

    endcase

    if (rst == 1) begin
      state <= get_a;
      s_input_a_ack <= 0;
      s_output_z_stb <= 0;
    end

  end
  assign input_a_ack = s_input_a_ack;
  assign output_z_stb = s_output_z_stb;
  assign output_z = s_output_z;

endmodule

