`timescale 1ns/1ps
module divider(
	input_a,
	input_b,
	input_a_stb,
	input_b_stb,
	output_z_ack,
	clk,
	rst,
	output_z,
	output_z_stb,
	input_a_ack,
	input_b_ack);

  input     clk;
  input     rst;

  input     [15:0] input_a;
  input     input_a_stb;
  output    input_a_ack;

  input     [15:0] input_b;
  input     input_b_stb;
  output    input_b_ack;

  output    [15:0] output_z;
  output    output_z_stb;
  input     output_z_ack;

  reg       [15:0] s_output_z_stb;
  reg       [15:0] s_output_z;
  reg       [15:0] s_input_a_ack;
  reg       [15:0] s_input_b_ack;

  reg       [4:0] state;
  parameter get_a         = 5'd0,
	    get_a_lo      = 5'd1,
            get_b         = 5'd2,
            get_b_lo      = 5'd3,
            unpack        = 5'd4,
	    special_cases = 5'd5,
	    normalise_a   = 5'd6,
	    normalise_b   = 5'd7,
            divide_0      = 5'd8,
            divide_1      = 5'd9,
            divide_2      = 5'd10,
            normalise_1   = 5'd11,
            normalise_2   = 5'd12,
            round         = 5'd13,
            pack          = 5'd14,
            put_z         = 5'd15,
            put_z_lo      = 5'd16;

  reg       [31:0] a, b, z;
  reg       [23:0] a_m, b_m, z_m;
  reg       [8:0] a_e, b_e, z_e;
  reg       a_s, b_s, z_s;
  reg       guard, round_bit, sticky;
  reg       [50:0] quotient, divisor, dividend, remainder;

  always @(posedge clk)
  begin

    case(state)

      get_a:
      begin
        s_input_a_ack <= 1;
        if (s_input_a_ack && input_a_stb) begin
          a[31:16] <= input_a;
          s_input_a_ack <= 0;
          state <= get_a_lo;
        end
      end

      get_a_lo:
      begin
        s_input_a_ack <= 1;
        if (s_input_a_ack && input_a_stb) begin
          a[15:0] <= input_a;
          s_input_a_ack <= 0;
          state <= get_b;
        end
      end

      get_b:
      begin
        s_input_b_ack <= 1;
        if (s_input_b_ack && input_b_stb) begin
          b[31:16] <= input_b;
          s_input_b_ack <= 0;
          state <= get_b_lo;
	end
      end

      get_b_lo:
      begin
        s_input_b_ack <= 1;
        if (s_input_b_ack && input_b_stb) begin
          b[15:0] <= input_b;
          s_input_b_ack <= 0;
          state <= unpack;
	end
      end

      unpack:
      begin
        a_m <= a[22 : 0];
        b_m <= b[22 : 0];
        a_e <= a[30 : 23] - 127;
        b_e <= b[30 : 23] - 127;
        a_s <= a[31];
        b_s <= b[31];
        state <= special_cases;
      end

      special_cases:
      begin
        //if a is NaN or b is NaN return NaN 
        if ((a_e == 128 && a_m != 0) || (b_e == 128 && a_m != 0)) begin
          z[31] <= 1;
          z[30:23] <= 255;
	  z[22] <= 1;
          z[21:0] <= 0;
          state <= put_z;
	  //if a is inf and b is inf return NaN 
	end else if ((a_e == 128) && (b_e == 128)) begin
	  z[31] <= 1;
          z[30:23] <= 255;
	  z[22] <= 1;
          z[21:0] <= 0;
          state <= put_z;
	//if a is inf return inf
	end else if (a_e == 128) begin
	  z[31] <= a_s ^ b_s;
          z[30:23] <= 255;
          z[22:0] <= 0;
          state <= put_z;
 	  //if b is zero return NaN
	  if ($signed(b_e == -127) && (b_m == 0)) begin
	    z[31] <= 1;
            z[30:23] <= 255;
	    z[22] <= 1;
            z[21:0] <= 0;
            state <= put_z;
	  end
	//if b is inf return zero
        end else if (b_e == 128) begin
          z[31] <= a_s ^ b_s;
          z[30:23] <= 0;
          z[22:0] <= 0;
          state <= put_z;
        //if a is zero return zero
        end else if (($signed(a_e) == -127) && (a_m == 0)) begin
          z[31] <= a_s ^ b_s;
          z[30:23] <= 0;
          z[22:0] <= 0;
          state <= put_z;
 	  //if b is zero return NaN
	  if (($signed(b_e) == -127) && (b_m == 0)) begin
	    z[31] <= 1;
            z[30:23] <= 255;
	    z[22] <= 1;
            z[21:0] <= 0;
            state <= put_z;
	  end
	//if b is zero return inf
	end else if (($signed(b_e) == -127) && (b_m == 0)) begin
	  z[31] <= a_s ^ b_s;
          z[30:23] <= 255;
          z[22:0] <= 0;
          state <= put_z;
        end else begin
          //Denormalised Number
	  if ($signed(a_e) == -127) begin
            a_e <= -126;
          end else begin
	    a_m[23] <= 1;
	  end
	  //Denormalised Number
	  if ($signed(b_e) == -127) begin
	    b_e <= -126;
	  end else begin
	    b_m[23] <= 1;
	  end
	  state <= normalise_a;
	end
      end

      normalise_a:
      begin
        if (a_m[23]) begin
          state <= normalise_b;
        end else begin
          a_m <= a_m << 1;
          a_e <= a_e - 1;
        end
      end

      normalise_b:
      begin
        if (b_m[23]) begin
          state <= divide_0;
        end else begin
          b_m <= b_m << 1;
          b_e <= b_e - 1;
        end
      end

      divide_0:
      begin
        z_s <= a_s ^ b_s;
        z_e <= a_e - b_e;
        quotient <= a_m << 26;
        divisor <= b_m;
        state <= divide_1;
      end

      divide_1:
      begin
        //change this to a serial division later
        dividend <= quotient / divisor;
        remainder <= quotient % divisor;
        state <= divide_2;
      end

      divide_2:
      begin
        z_m <= dividend[26:3];
        guard <= dividend[2];
        round_bit <= dividend[1];
        sticky <= dividend[0] | (remainder != 0);
        state <= normalise_1;
      end

      normalise_1:
      begin
        if (z_m[23] == 0) begin
          z_e <= z_e - 1;
          z_m <= z_m << 1;
	  z_m[0] <= guard;
          guard <= round_bit;
	  round_bit <= 0;
        end else begin
          state <= normalise_2;
        end
      end

      normalise_2:
      begin
        if ($signed(z_e) < -126) begin
          z_e <= z_e + 1;
          z_m <= z_m >> 1;
          guard <= z_m[0];
          round_bit <= guard;
          sticky <= sticky | round_bit;
        end else begin
          state <= round;
        end
      end

      round:
      begin
        if (guard && (round_bit | sticky | z_m[0])) begin
          z_m <= z_m + 1;
	end
	state <= pack;
      end

      pack:
      begin
        z[22 : 0] <= z_m[22:0];
        z[30 : 23] <= z_e[7:0] + 127;
	z[31] <= z_s;
        if ($signed(z_e) == -126 && z_m[23] == 0) begin
          z[30 : 23] <= 0;
        end
	//if overflow occurs, return inf
        if ($signed(z_e) > 127) begin
          z[22 : 0] <= 0;
          z[30 : 23] <= 255;
	  z[31] <= z_s;
        end
        state <= put_z;
      end

      put_z:
      begin
        s_output_z_stb <= 1;
	s_output_z <= z[31:16];
        if (s_output_z_stb && output_z_ack) begin
          s_output_z_stb <= 0;
          state <= put_z_lo;
        end
      end

      put_z_lo:
      begin
        s_output_z_stb <= 1;
	s_output_z <= z[15:0];
        if (s_output_z_stb && output_z_ack) begin
          s_output_z_stb <= 0;
          state <= get_a;
        end
      end

    endcase

    if (rst == 1) begin
      state <= get_a;
      s_input_a_ack <= 0;
      s_input_b_ack <= 0;
      s_output_z_stb <= 0;
    end

  end
  assign input_a_ack = s_input_a_ack;
  assign input_b_ack = s_input_b_ack;
  assign output_z_stb = s_output_z_stb;
  assign output_z = s_output_z;

endmodule

