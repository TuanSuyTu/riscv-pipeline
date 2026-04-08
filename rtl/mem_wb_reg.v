// =============================================================================
// Project: RISC-V 5-Stage Pipelined Processor
// Module: mem_wb_reg
// Description: Pipeline stage register between Memory (MEM) and Write-Back (WB).
// =============================================================================

module mem_wb_reg (
    input clk, rst,
    input flush,      // Injects NOP during BRAM stall to avoid double write-back

    input        reg_write_in, mem_to_reg_in, jump_in,
    input [31:0] read_data_in, alu_result_in, pc_plus4_in,
    input [4:0]  rd_addr_in,

    output reg        reg_write_out, mem_to_reg_out, jump_out,
    output reg [31:0] read_data_out, alu_result_out, pc_plus4_out,
    output reg [4:0]  rd_addr_out
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            {reg_write_out, mem_to_reg_out, jump_out,
             read_data_out, alu_result_out, pc_plus4_out,
             rd_addr_out} <= 0;
        end else begin
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            jump_out       <= jump_in;
            read_data_out  <= read_data_in;
            alu_result_out <= alu_result_in;
            pc_plus4_out   <= pc_plus4_in;
            rd_addr_out    <= rd_addr_in;
        end
    end
endmodule
