// =============================================================================
// Project: RISC-V 5-Stage Pipelined Processor
// Module: forward
// Description: Data Forwarding Unit (Bypass) to resolve RAW hazards.
//
// Features:
// - EX/MEM Stage Forwarding (Prioritized)
// - MEM/WB Stage Forwarding
// - Resolves Register dependency without stalling for arithmetic operations.
// =============================================================================

module forward (
    input  [4:0] id_ex_rs1,
    input  [4:0] id_ex_rs2,
    input        ex_mem_reg_write,
    input  [4:0] ex_mem_rd,
    input        mem_wb_reg_write,
    input  [4:0] mem_wb_rd,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

    // Forwarding Priority: EX/MEM (More recent) > MEM/WB (Older)
    // 2'b10 = Forward from EX/MEM (alu_result_mem)
    // 2'b01 = Forward from MEM/WB (wd_data_wb)
    // 2'b00 = Use original register value

    always @(*) begin
        // --- Forward A Path (rs1) ---
        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs1))
            forward_a = 2'b10;
        else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs1))
            forward_a = 2'b01;
        else
            forward_a = 2'b00;

        // --- Forward B Path (rs2) ---
        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs2))
            forward_b = 2'b10;
        else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs2))
            forward_b = 2'b01;
        else
            forward_b = 2'b00;
    end

endmodule
