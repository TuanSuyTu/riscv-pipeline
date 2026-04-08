module control (
    input  [6:0] opcode,
    output reg   reg_write,
    output reg   mem_read,
    output reg   mem_write,
    output reg   mem_to_reg,
    output reg   alu_src,
    output reg   branch,
    output reg   jump,
    output reg   lui,
    output reg   auipc,
    output reg [1:0] alu_op
);
    localparam R_TYPE  = 7'b0110011; // ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
    localparam I_LOAD  = 7'b0000011; // LW, LH, LB, LHU, LBU
    localparam I_ALU   = 7'b0010011; // ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI
    localparam S_TYPE  = 7'b0100011; // SW, SH, SB
    localparam B_TYPE  = 7'b1100011; // BEQ, BNE, BLT, BGE, BLTU, BGEU
    localparam U_LUI   = 7'b0110111; // LUI
    localparam U_AUIPC = 7'b0010111; // AUIPC
    localparam J_JAL   = 7'b1101111; // JAL
    localparam J_JALR  = 7'b1100111; // JALR

    always @(*) begin
        // Default: all signals de-asserted
        {reg_write, mem_read, mem_write, mem_to_reg,
         alu_src, branch, jump, lui, auipc} = 9'b0;
        alu_op = 2'b00;

        case (opcode)
            R_TYPE: begin
                reg_write = 1;
                alu_op    = 2'b10;
            end

            I_LOAD: begin
                reg_write  = 1;
                mem_read   = 1;
                mem_to_reg = 1;
                alu_src    = 1;
                alu_op     = 2'b00;
            end

            I_ALU: begin
                reg_write = 1;
                alu_src   = 1;
                alu_op    = 2'b11;
            end

            S_TYPE: begin
                mem_write = 1;
                alu_src   = 1;
                alu_op    = 2'b00;
            end

            B_TYPE: begin
                branch = 1;
                alu_op = 2'b01;
            end

            U_LUI: begin
                reg_write = 1;
                alu_src   = 1;
                lui       = 1;
                alu_op    = 2'b00;
            end

            U_AUIPC: begin
                reg_write = 1;
                alu_src   = 1;
                auipc     = 1;
                alu_op    = 2'b00;
            end

            J_JAL: begin
                reg_write = 1;
                jump      = 1;
                alu_src   = 1;
                alu_op    = 2'b00;
            end

            J_JALR: begin
                reg_write = 1;
                jump      = 1;
                alu_src   = 1;
                alu_op    = 2'b00;
            end
        endcase
    end
endmodule
