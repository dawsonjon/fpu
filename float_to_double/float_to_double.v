//Integer to IEEE Floating Point Converter (Double Precision)
//Copyright (C) Jonathan P Dawson 2013
//2013-12-12
module float_to_double(
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

  input     [31:0] input_a;
  input     input_a_stb;
  output    input_a_ack;

  output    [63:0] output_z;
  output    output_z_stb;
  input     output_z_ack;

  reg       s_output_z_stb;
  reg       [63:0] s_output_z;
  reg       s_input_a_ack;
  reg       s_input_b_ack;

  reg       [1:0] state;
  parameter get_a         = 3'd0,
            convert_0     = 3'd1,
            normalise_0   = 3'd2,
            put_z         = 3'd3;

  reg [63:0] z;
  reg [10:0] z_e;
  reg [52:0] z_m;
  reg [31:0] a;

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
        z[63] <= a[31];
        z[62:52] <= (a[30:23] - 127) + 1023;
        z[51:0] <= {a[22:0], 29'd0};
        if (a[30:23] == 255) begin
            z[62:52] <= 2047;
        end
        state <= put_z;
        if (a[30:23] == 0) begin
            if (a[23:0]) begin
                state <= normalise_0;
                z_e <= 897;
                z_m <= {1'd0, a[22:0], 29'd0};
            end
            z[62:52] <= 0;
        end
      end

      normalise_0:
      begin
        if (z_m[52]) begin
          z[62:52] <= z_e;
          z[51:0] <= z_m[51:0];
          state <= put_z;
        end else begin
          z_m <= {z_m[51:0], 1'd0};
          z_e <= z_e - 1;
        end
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

