//name : file_writer
//tag : c components
//input : input_a:16
//source_file : file_writer.c
///===========
///
///*Created by C2CHIP*

//////////////////////////////////////////////////////////////////////////////
// Register Allocation
// ===================
//         Register                 Name                   Size          
//            0             file_writer return address            2            
//            1              temporary_register             2            
  
`timescale 1ns/1ps
module file_writer(input_a,input_a_stb,clk,rst,input_a_ack);
  integer file_count;
  integer output_file_0;
  input     [31:0] input_a;
  input     input_a_stb;
  input     clk;
  input     rst;
  output    input_a_ack;
  reg       [31:0] timer;
  reg       timer_enable;
  reg       stage_0_enable;
  reg       stage_1_enable;
  reg       stage_2_enable;
  reg       [2:0] program_counter;
  reg       [2:0] program_counter_0;
  reg       [36:0] instruction_0;
  reg       [2:0] opcode_0;
  reg       dest_0;
  reg       src_0;
  reg       srcb_0;
  reg       [31:0] literal_0;
  reg       [2:0] program_counter_1;
  reg       [2:0] opcode_1;
  reg       dest_1;
  reg       [31:0] register_1;
  reg       [31:0] registerb_1;
  reg       [31:0] literal_1;
  reg       dest_2;
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
  reg       [31:0] s_input_a_ack;
  reg [36:0] instructions [7:0];
  reg [31:0] registers [1:0];

  //////////////////////////////////////////////////////////////////////////////
  // INSTRUCTION INITIALIZATION                                                 
  //                                                                            
  // Initialise the contents of the instruction memory                          
  //
  // Intruction Set
  // ==============
  // 0 {'literal': True, 'right': False, 'unsigned': False, 'op': 'jmp_and_link'}
  // 1 {'literal': False, 'right': False, 'unsigned': False, 'op': 'stop'}
  // 2 {'input': 'a', 'literal': False, 'right': False, 'unsigned': False, 'op': 'read'}
  // 3 {'literal': False, 'right': False, 'unsigned': False, 'op': 'nop'}
  // 4 {'file_name': 'resp_z', 'literal': False, 'right': False, 'unsigned': False, 'op': 'file_write'}
  // 5 {'literal': True, 'right': False, 'unsigned': False, 'op': 'goto'}
  // 6 {'literal': False, 'right': False, 'unsigned': False, 'op': 'jmp_to_reg'}
  // Intructions
  // ===========
  
  initial
  begin
    instructions[0] = {3'd0, 1'd0, 1'd0, 32'd2};//{'dest': 0, 'label': 2, 'op': 'jmp_and_link'}
    instructions[1] = {3'd1, 1'd0, 1'd0, 32'd0};//{'op': 'stop'}
    instructions[2] = {3'd2, 1'd1, 1'd0, 32'd0};//{'dest': 1, 'input': 'a', 'op': 'read'}
    instructions[3] = {3'd3, 1'd0, 1'd0, 32'd0};//{'op': 'nop'}
    instructions[4] = {3'd3, 1'd0, 1'd0, 32'd0};//{'op': 'nop'}
    instructions[5] = {3'd4, 1'd0, 1'd1, 32'd0};//{'file_name': 'resp_z', 'src': 1, 'op': 'file_write'}
    instructions[6] = {3'd5, 1'd0, 1'd0, 32'd2};//{'label': 2, 'op': 'goto'}
    instructions[7] = {3'd6, 1'd0, 1'd0, 32'd0};//{'src': 0, 'op': 'jmp_to_reg'}
  end


  //////////////////////////////////////////////////////////////////////////////
  // OPEN FILES                                                                 
  //                                                                            
  // Open all files used at the start of the process                            
  
  initial
  begin
    output_file_0 = $fopen("resp_z");
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
      opcode_0 = instruction_0[36:34];
      dest_0 = instruction_0[33:33];
      src_0 = instruction_0[32:32];
      srcb_0 = instruction_0[0:0];
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
          $fclose(output_file_0);
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

        16'd2:
        begin
          stage_0_enable <= 0;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
          s_input_a_ack <= 1'b1;
        end

        16'd4:
        begin
          $fdisplay(output_file_0, "%d", register_1);
        end

        16'd5:
        begin
          program_counter <= literal_1;
          stage_0_enable <= 1;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

        16'd6:
        begin
          program_counter <= register_1;
          stage_0_enable <= 1;
          stage_1_enable <= 0;
          stage_2_enable <= 0;
        end

       endcase
    end
    if (s_input_a_ack == 1'b1 && input_a_stb == 1'b1) begin
       result_2 <= input_a;
       write_enable_2 <= 1;
       s_input_a_ack <= 1'b0;
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
      s_input_a_ack <= 0;
    end
  end
  assign input_a_ack = s_input_a_ack;

endmodule
