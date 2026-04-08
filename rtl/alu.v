// =============================================================================
// Project: RISC-V 5-Stage Pipelined Processor
// Module: alu
// Description: Arithmetic Logic Unit for RV32I.
// =============================================================================

`timescale 1ns / 1ps

module alu (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  alu_ctrl, // 4-bit Control interface
    output reg [31:0] result,
    output zero
);
    // Operation encodings
    localparam ADD    = 4'b0000;
    localparam SUB    = 4'b0001;
    localparam AND    = 4'b0010;
    localparam OR     = 4'b0011;
    localparam XOR    = 4'b0100;
    localparam SLL    = 4'b0101;
    localparam SRL    = 4'b0110;
    localparam SRA    = 4'b0111;
    localparam SLT    = 4'b1000;
    localparam SLTU   = 4'b1001;
    localparam PASS_B = 4'b1010;

    always @(*) begin
        case (alu_ctrl)
            ADD:    result = a + b;
            SUB:    result = a - b;
            AND:    result = a & b;
            OR:     result = a | b;
            XOR:    result = a ^ b;
            SLL:    result = a << b[4:0];
            SRL:    result = a >> b[4:0];
            SRA:    result = $signed(a) >>> b[4:0];
            SLT:    result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            SLTU:   result = (a < b) ? 32'd1 : 32'd0;
            PASS_B: result = b;
            default: result = 32'd0;
        endcase
    end

    // Zero flag used for conditional branches
    assign zero = (result == 32'd0);

endmodule
