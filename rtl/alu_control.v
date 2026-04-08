// =============================================================================
// Project: RISC-V 5-Stage Pipelined Processor
// Module: alu_control
// Description: ALU Control unit. Decodes alu_op and funct fields into ALU control signals.
// =============================================================================

`timescale 1ns / 1ps

module alu_control (
    input  [1:0] alu_op,
    input  [2:0] funct3,
    input        funct7_5,
    input        lui,
    output reg [3:0] alu_ctrl
);
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = lui ? 4'b1010 : 4'b0000; // LW/SW/AUIPC -> ADD; LUI -> PASS_B
            2'b01: alu_ctrl = 4'b0001;                 // Branch -> SUB
            
            2'b10: begin // R-type
                case (funct3)
                    3'b000: alu_ctrl = funct7_5 ? 4'b0001 : 4'b0000;
                    3'b001: alu_ctrl = 4'b0101;
                    3'b010: alu_ctrl = 4'b1000;
                    3'b011: alu_ctrl = 4'b1001;
                    3'b100: alu_ctrl = 4'b0100;
                    3'b101: alu_ctrl = funct7_5 ? 4'b0111 : 4'b0110;
                    3'b110: alu_ctrl = 4'b0011;
                    3'b111: alu_ctrl = 4'b0010;
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            2'b11: begin // I-type ALU
                case (funct3)
                    3'b000: alu_ctrl = 4'b0000;
                    3'b001: alu_ctrl = 4'b0101;
                    3'b010: alu_ctrl = 4'b1000;
                    3'b011: alu_ctrl = 4'b1001;
                    3'b100: alu_ctrl = 4'b0100;
                    3'b101: alu_ctrl = funct7_5 ? 4'b0111 : 4'b0110;
                    3'b110: alu_ctrl = 4'b0011;
                    3'b111: alu_ctrl = 4'b0010;
                    default: alu_ctrl = 4'b0000;
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end
endmodule
