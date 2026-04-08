// =============================================================================
// Project: RISC-V 5-Stage Pipelined Processor
// Module: ex_mem_reg
// Description: Pipeline stage register between Execute (EX) and Memory (MEM).
// =============================================================================

module ex_mem_reg (
    input clk, rst,
    input stall,      // HOLD LOAD instruction in MEM during BRAM wait

    input        reg_write_in, mem_read_in, mem_write_in, mem_to_reg_in,
    input        jump_in,
    input [2:0]  funct3_in,
    input [31:0] alu_result_in, rs2_data_in, pc_plus4_in,
    input [4:0]  rd_addr_in,

    output reg        reg_write_out, mem_read_out, mem_write_out, mem_to_reg_out,
    output reg        jump_out,
    output reg [2:0]  funct3_out,
    output reg [31:0] alu_result_out, rs2_data_out, pc_plus4_out,
    output reg [4:0]  rd_addr_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            {reg_write_out, mem_read_out, mem_write_out,
             mem_to_reg_out, jump_out, funct3_out,
             alu_result_out, rs2_data_out, pc_plus4_out,
             rd_addr_out} <= 0;
        end else if (stall) begin
            // HOLD state
        end else begin
            reg_write_out  <= reg_write_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            jump_out       <= jump_in;
            funct3_out     <= funct3_in;
            alu_result_out <= alu_result_in;
            rs2_data_out   <= rs2_data_in;
            pc_plus4_out   <= pc_plus4_in;
            rd_addr_out    <= rd_addr_in;
        end
    end
endmodule
