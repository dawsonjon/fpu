//name : file_reader_b
//tag : c components
//output : output_z:16
//source_file : file_reader_b.c
///=============
///
///*Created by C2CHIP*

//////////////////////////////////////////////////////////////////////////////
// Register Allocation
// ===================
//         Register                 Name                   Size          
//            0             file_reader_b return address            2            
//            1                variable temp                2            
//            2              temporary_register             2            
  
`timescale 1ns/1ps
module file_reader_b(output_z_ack,clk,rst,output_z,output_z_stb);
  integer file_count;
  integer input_file_0;
  input     output_z_ack;
  input     clk;
  input     rst;
  output    [31:0] output_z;
  output    output_z_stb;
  reg       [31:0] timer;
  reg       timer_enable;
  reg       stage_0_enable;
  reg       stage_1_enable;
  reg       stage_2_enable;
  reg       [3:0] program_counter;
  reg       [3:0] program_counter_0;
  reg       [39:0] instruction_0;
  reg       [3:0] opcode_0;
  reg       [1:0] dest_0;
  reg       [1:0] src_0;
  reg       [1:0] srcb_0;
  reg       [31:0] literal_0;
  reg       [3:0] program_counter_1;
  reg       [3:0] opcode_1;
  reg       [1:0] dest_1;
  reg       [31:0] register_1;
  reg       [31:0] registerb_1;
  reg       [31:0] literal_1;
  reg       [1:0] dest_2;
  reg       [31:0] result_2;
  reg       write_enable_2;
  reg       [31:0] address_2;
  reg       [31:0] data_out_2;
  reg       [31:0] data_in_2;
  reg       memory_enable_2;
  reg       [31:0] address_4;
  reg       [31:0] data_out_4;
  reg       [31:0] data_in_4;
  reg       memory_enable_4;
  reg       [31:0] s_output_z_stb;
  reg       [31:0] s_output_z;
  reg [39:0] instructions [14:0];
  reg [31:0] registers [2:0];

  //////////////////////////////////////////////////////////////////////////////
  // INSTRUCTION INITIALIZATION                                                 
  //                                                                            
  // Initialise the contents of the instruction memory                          
  //
  // Intruction Set
  // ==============
  // 0 {'literal': True, 'right': False, 'unsigned': False, 'op': 'jmp_and_link'}
  // 1 {'literal': False, 'right': False, 'unsigned': False, 'op': 'stop'}
  // 2 {'literal': True, 'right': False, 'unsigned': False, 'op': 'literal'}
  // 3 {'file_name': 'stim_b', 'literal': False, 'right': False, 'unsigned': False, 'op': 'file_read'}
  // 4 {'literal': False, 'right': False, 'unsigned': False, 'op': 'nop'}
  // 5 {'literal': False, 'right': False, 'unsigned': False, 'op': 'move'}
  // 6 {'output': 'z', 'literal': False, 'right': False, 'unsigned': False, 'op': 'write'}
  // 7 {'literal': True, 'right': False, 'unsigned': False, 'op': 'goto'}
  // 8 {'literal': False, 'right': False, 'unsigned': False, 'op': 'jmp_to_reg'}
  // Intructions
  // ===========
  
  initial
  begin
    instructions[0] = {4'd0, 2'd0, 2'd0, 32'd2};//{'dest': 0, 'label': 2, 'op': 'jmp_and_link'}
    instructions[1] = {4'd1, 2'd0, 2'd0, 32'd0};//{'op': 'stop'}
    instructions[2] = {4'd2, 2'd1, 2'd0, 32'd0};//{'dest': 1, 'literal': 0, 'op': 'literal'}
    instructions[3] = {4'd3, 2'd2, 2'd0, 32'd0};//{'dest': 2, 'file_name': 'stim_b', 'op': 'file_read'}
    instructions[4] = {4'd4, 2'd0, 2'd0, 32'd0};//{'op': 'nop'}
    instructions[5] = {4'd4, 2'd0, 2'd0, 32'd0};//{'op': 'nop'}
    instructions[6] = {4'd5, 2'd1, 2'd2, 32'd0};//{'dest': 1, 'src': 2, 'op': 'move'}
    instructions[7] = {4'd4, 2'd0, 2'd0, 32'd0};//{'op': 'nop'}
    instructions[8] = {4'd4, 2'd0, 2'd0, 32'd0};//{'op': 'nop'}
    instructions[9] = {4'd5, 2'd2, 2'd1, 32'd0};//{'dest': 2, 'src': 1, 'op': 'move'}
    instructions[10] = {4'd4, 2'd0, 2'd0, 32'd0};//{'op': 'nop'}
    instructions[11] = {4'd4, 2'd0, 2'd0, 32'd0};//{'op': 'nop'}
    instructions[12] = {4'd6, 2'd0, 2'd2, 32'd0};//{'src': 2, 'output': 'z', 'op': 'write'}
    instructions[13] = {4'd7, 2'd0, 2'd0, 32'd3};//{'label': 3, 'op': 'goto'}
    instructions[14] = {4'd8, 2'd0, 2'd0, 32'd0};//{'src': 0, 'op': 'jmp_to_reg'}
  end


  //////////////////////////////////////////////////////////////////////////////
  // OPEN FILES                                                                 
  //                                                                            
  // Open all files used at the start of the process                            
  
  initial
  begin
    input_file_0 = $fopenr("stim_b");
  end


  //////////////////////////////////////////////////////////////////////////////
  // CPU IMPLEMENTAION OF C PROCESS                                             
  //                                                                            
  // This section of the file contains a CPU implementing the C process.        
  
  always @(posedge clk)
  begin

    write_enable_2 <= 0;
    //stage 0 instruction fetch
    if (stage_0_enable) begin
      stage_1_enable <= 1;
      instruction_0 <= instructions[program_counter];
      opcode_0 = instruction_0[39:36];
      dest_0 = instruction_0[35:34];
      src_0 = instruction_0[33:32];
      srcb_0 = instruction_0[1:0];
      literal_0 = instruction_0[31:0];
      if(write_enable_2) begin
        registers[dest_2] <= result_2;
      end
      program_counter_0 <= program_counter;
      program_counter <= program_counter + 1;
    end

    //stage 1 opcode fetch
    if (stage_1_enable) begin
      stage_2_enable <= 1;
      register_1 <= registers[src_0];
      registerb_1 <= registers[srcb_0];
      dest_1 <= dest_0;
      literal_1 <= literal_0;
      opcode_1 <= opcode_0;
      program_counter_1 <= program_counter_0;
    end

    //stage 2 opcode fetch
    if (stage_2_enable) begin
      dest_2 <= dest_1;
      case(opcode_1)

        16'd0:
        begin
          program_counter <= literal_1;
          result_2 <= program_counter_1 + 1;
          write_enable_2 <= 1;
          stage_0_enable <= 1;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

        16'd1:
        begin
          $fclose(input_file_0);
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

        16'd2:
        begin
          result_2 <= literal_1;
          write_enable_2 <= 1;
        end

        16'd3:
        begin
          file_count = $fscanf(input_file_0, "%d\n", result_2);
          write_enable_2 <= 1;
        end

        16'd5:
        begin
          result_2 <= register_1;
          write_enable_2 <= 1;
        end

        16'd6:
        begin
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
          s_output_z_stb <= 1'b1;
          s_output_z <= register_1;
        end

        16'd7:
        begin
          program_counter <= literal_1;
          stage_0_enable <= 1;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

        16'd8:
        begin
          program_counter <= register_1;
          stage_0_enable <= 1;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

       endcase
    end
     if (s_output_z_stb == 1'b1 && output_z_ack == 1'b1) begin
       s_output_z_stb <= 1'b0;
       stage_0_enable <= 1;
       stage_1_enable <= 1;
       stage_2_enable <= 1;
     end

    if (timer == 0) begin
      if (timer_enable) begin
         stage_0_enable <= 1;
         stage_1_enable <= 1;
         stage_2_enable <= 1;
         timer_enable <= 0;
      end
    end else begin
      timer <= timer - 1;
    end

    if (rst == 1'b1) begin
      stage_0_enable <= 1;
      stage_1_enable <= 0;
      stage_2_enable <= 0;
      timer <= 0;
      timer_enable <= 0;
      program_counter <= 0;
      s_output_z_stb <= 0;
    end
  end
  assign output_z_stb = s_output_z_stb;
  assign output_z = s_output_z;

endmodule
