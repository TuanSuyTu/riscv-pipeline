// =============================================================================
// Project: RISC-V 5-Stage Pipelined Processor
// Module: control
// Description: Instruction Decoder / Main Control Unit.
//              Generates control signals for the datapath based on Opcode.
// =============================================================================

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
    // RV32I Opcode Encodings
    localparam R_TYPE  = 7'b0110011; 
    localparam I_LOAD  = 7'b0000011; 
    localparam I_ALU   = 7'b0010011; 
    localparam S_TYPE  = 7'b0100011; 
    localparam B_TYPE  = 7'b1100011; 
    localparam U_LUI   = 7'b0110111; 
    localparam U_AUIPC = 7'b0010111; 
    localparam J_JAL   = 7'b1101111; 
    localparam J_JALR  = 7'b1100111; 

    always @(*) begin
        // Default: No-op / de-assert all signals
        {reg_write, mem_read, mem_write, mem_to_reg,
         alu_src, branch, jump, lui, auipc} = 9'b0;
        alu_op = 2'b00;

        case (opcode)
            R_TYPE: begin
                reg_write = 1;
                alu_op    = 2'b10; // Use funct3/funct7
            end

            I_LOAD: begin
                reg_write  = 1;
                mem_read   = 1;
                mem_to_reg = 1;
                alu_src    = 1;
                alu_op     = 2'b00; // ADD (base + offset)
            end

            I_ALU: begin
                reg_write = 1;
                alu_src   = 1;
                alu_op    = 2'b11; // Use funct3
            end

            S_TYPE: begin
                mem_write = 1;
                alu_src   = 1;
                alu_op    = 2'b00; // ADD (base + offset)
            end

            B_TYPE: begin
                branch = 1;
                alu_op = 2'b01; // Comparison
            end

            U_LUI: begin
                reg_write = 1;
                alu_src   = 1;
                lui       = 1;
                alu_op    = 0;
            end

            U_AUIPC: begin
                reg_write = 1;
                alu_src   = 1;
                auipc     = 1;
                alu_op    = 0;
            end

            J_JAL, J_JALR: begin
                reg_write = 1;
                jump      = 1;
                alu_src   = 1;
                alu_op    = 0;
            end
        endcase
    end
endmodule
