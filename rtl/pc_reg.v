// =============================================================================
// Project: RISC-V 5-Stage Pipelined Processor
// Module: pc_reg
// Description: Program Counter (PC) storage register.
// =============================================================================

`timescale 1ns / 1ps

module pc_reg (
    input         clk,
    input         rst,
    input         stall,      // Freeze PC during hazards or BRAM wait
    input         pc_sel,      // Source select (PC+4 vs Target)
    input  [31:0] branch_tgt,
    output reg [31:0] pc
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'h0;
        else if (!stall) begin
            if (pc_sel)
                pc <= branch_tgt;
            else
                pc <= pc + 4;
        end
    end
endmodule
