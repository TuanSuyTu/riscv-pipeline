`timescale 1ns / 1ps

module alu (
    input  [31:0] a,
    input  [31:0] b,
    input  [4:0]  alu_ctrl,
    output reg [31:0] result,
    output zero
);
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

    assign zero = (result == 32'd0);
endmodule

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
