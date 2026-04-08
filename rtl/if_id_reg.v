// =============================================================================
// Project: RISC-V 5-Stage Pipelined Processor
// Module: if_id_reg
// Description: Pipeline stage register between Fetch (IF) and Decode (ID).
// =============================================================================

module if_id_reg (
    input         clk,
    input         rst,
    input         stall,      // Freeze during hazards or BRAM wait
    input         flush,      // Clear on branch mispredict
    input  [31:0] pc_in,
    input  [31:0] instr_in,
    output reg [31:0] pc_out,
    output reg [31:0] instr_out
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            pc_out <= 32'b0;
            instr_out <= 32'b0;
        end else if (!stall) begin
            pc_out <= pc_in;
            instr_out <= instr_in;
        end
    end
endmodule
