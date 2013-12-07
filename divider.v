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

  input     [15:0] input_a;
  input     [15:0] input_b;
  input     input_a_stb;
  input     input_b_stb;
  input     output_z_ack;
  input     clk;
  input     rst;
  output    [15:0] output_z;
  output    output_z_stb;
  output    input_a_ack;
  output    input_b_ack;

  reg       [15:0] s_output_z_stb;
  reg       [15:0] s_output_z;
  reg       [15:0] s_input_a_ack;
  reg       [15:0] s_input_b_ack;
  reg [38:0] instructions [10:0];
  reg [31:0] registers [3:0];

  always @(posedge clk)
  begin

      case(state)

        get_a:
        begin
          s_input_a_ack <= 1;
	  if (s_input_a_ack and input_a_stb) begin
		a <= input_a;
		s_input_a_ack <= 0;
		state <= get_a;
	  end
        end

        get_b:
        begin
          s_input_b_ack <= 1;
	  if (s_input_b_ack and input_b_stb) begin
		a <= input_a;
		s_input_a_ack <= 0;
		state <= unpack;
	  end
        end

        unpack:
        begin
          a_m <= {1, a[22 : 0]};
          b_m <= {1, b[22 : 0]};
          a_e <= a[30 : 21] - 127;
          b_e <= b[30 : 21] - 127;
          a_s <= a[31];
          b_s <= b[31];
	  state <= special_cases;
        end

	special_cases:
	begin
	  //if a is NaN or b is NaN return NaN 
	  if (a_e == 128 && a_m != 0) || (b_e == 128 && a_m != 0) begin
	    z[31] <= 0;
            z[30:23] <= 255;
            z[22:0] <= 1;
            state <= put_z;
	  //if a is inf and b is inf return NaN 
	  end else if (a_e == 128) && (b_e == 128) begin
	    z[31] <= 0;
            z[30:23] <= 255;
            z[22:0] <= 1;
            state <= put_z;
	  //if a is inf return inf
	  end else if (a_e == 128) begin
	    z[31] <= a_s ^ b_s;
            z[30:23] <= 255;
            z[22:0] <= 0;
            state <= put_z;
 	    //if b is zero return NaN
	    if (b_e == -127) && (b_m == 0) begin
	      z[31] <= 0;
              z[30:23] <= 255;
              z[22:0] <= 1;
              state <= put_z;
	    end
	  //if b is inf return zero
	  end else if (b_e == 128) begin
	    z[31] <= a_s ^ b_s;
            z[30:23] <= 0;
            z[22:0] <= 0;
            state <= put_z;
	  //if a is zero return zero
	  end else if (a_e == -127) && (a_m == 0) begin
	    z[31] <= a_s ^ b_s;
            z[30:23] <= 0;
            z[22:0] <= 0;
            state <= put_z;
 	    //if b is zero return NaN
	    if (b_e == -127) && (b_m == 0) begin
	      z[31] <= 0;
              z[30:23] <= 255;
              z[22:0] <= 1;
              state <= put_z;
	    end
	  //if b is zero return inf
	  end else if (b_e == -127) && (b_m == 0) begin
	    z[31] <= a_s ^ b_s;
            z[30:23] <= 255;
            z[22:0] <= 0;
            state <= put_z;
	  end
	  //Denormalised Number
	  if (a_e == -127) begin
            a_e <= -126;
	  end
	  //Denormalised Number
	  if (b_e == -127) begin
	    b_e <= -126;
	  end
	  state <= noramlise_a;
	end

	normalise_a:
	begin
	  if (a_m[23]) begin
	    state <= noramlise_b;
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
	  z_e <= a_e - b_1;
	  quotient <= a_m << 27;
	  divisor <= b_m;
	  state <= divide_1;
        end

        divide_1:
        begin
	  //change this to a serial division later
	  dividend <= quotient / divisor;
	  state <= divide_2;
        end

        divide_2:
        begin
	  z_m <= dividend[26:3];
	  guard <= dividend[2];
	  round <= dividend[1];
	  sticky <= dividend[0];
	  state <= normalise;
        end

        normalise:
        begin
	  if (z_e < -126) begin
	    z_e <= z_e + 1;
	    z_m <= z_m >> 1;
	    guard <= z_m[0];
	    round <= guard;
	    sticky <= sticky | sticky;
	  end else begin
	    state <= round;
	  end
        end

        round:
        begin
	  if (guard && (round | sticky | z_m[0])) begin
	    z_m <= z_m + 1;
	  end
        end

        pack:
        begin
	  z[22 : 0] <= z_m[22:0];
	  z[30 : 23] <= z_e + 127;
	  if (z_e == -126 && z_m[23] == 0) begin
	    z[30 : 23] <= 0;
	  end
	  state <= put_z;
        end

        put_z:
        begin
	  s_output_z_stb <= 1;
	  if (s_output_z_stb && output_z_ack) begin
	    s_output_z_stb <= 1;
	    state <= get_a;
	  end
        end

       endcase
    end

    if (rst == 1'b1) begin
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
