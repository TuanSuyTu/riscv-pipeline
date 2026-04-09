// =============================================================================
// Module: ex_stage
// Description: EX Stage - Execute.
//              Encapsulates all combinational logic for the Execute stage:
//              - Forwarding MUXes (EX-EX and MEM-EX bypass paths)
//              - ALU Input MUXes (for LUI, AUIPC, immediate)
//              - ALU Control and ALU
//              - Branch comparators and taken logic
//              - Jump/Branch target address calculation
//              - pc_sel generation (feeds back to IF stage)
// =============================================================================

`timescale 1ns / 1ps

module ex_stage (
    // --- Inputs from ID/EX Register ---
    input  wire [31:0] rs1_data_ex,
    input  wire [31:0] rs2_data_ex,
    input  wire [31:0] imm_ex,
    input  wire [31:0] pc_ex,
    input  wire [1:0]  alu_op_ex,
    input  wire [2:0]  funct3_ex,
    input  wire        funct7_5_ex,
    input  wire        alu_src_ex,
    input  wire        branch_ex,
    input  wire        jump_ex,
    input  wire        lui_ex,
    input  wire        auipc_ex,

    // --- Forwarding control from Forwarding Unit ---
    input  wire [1:0]  forward_a,
    input  wire [1:0]  forward_b,

    // --- Forwarded data from later stages ---
    input  wire [31:0] alu_result_mem,  // EX-EX forward source (from EX/MEM reg)
    input  wire [31:0] wd_data_wb,      // MEM-EX forward source (from WB mux)

    // --- Outputs to EX/MEM Register ---
    output wire [31:0] alu_result_ex,
    output wire [31:0] forwarded_b_out, // forwarded rs2, needed for SW in MEM
    output wire [31:0] pc_plus4_ex,

    // --- Outputs to Global Control (IF stage) ---
    output wire        pc_sel,
    output wire [31:0] jump_tgt
);

    // -------------------------------------------------------------------------
    // Forwarding MUXes
    // 2'b10 = forward from EX/MEM (one instruction ago)
    // 2'b01 = forward from MEM/WB (two instructions ago)
    // 2'b00 = no hazard, use register file value
    // -------------------------------------------------------------------------
    wire [31:0] forwarded_a_raw = (forward_a == 2'b10) ? alu_result_mem :
                                  (forward_a == 2'b01) ? wd_data_wb     :
                                  rs1_data_ex;

    wire [31:0] forwarded_b     = (forward_b == 2'b10) ? alu_result_mem :
                                  (forward_b == 2'b01) ? wd_data_wb     :
                                  rs2_data_ex;

    assign forwarded_b_out = forwarded_b; // pass rs2 forward for SW store data

    // -------------------------------------------------------------------------
    // ALU Input MUXes
    // alu_in_a: LUI forces 0, AUIPC uses PC, otherwise use forwarded rs1
    // alu_in_b: immediate or forwarded rs2
    // -------------------------------------------------------------------------
    wire [31:0] alu_in_a = lui_ex   ? 32'd0  :
                           auipc_ex ? pc_ex   :
                           forwarded_a_raw;

    wire [31:0] alu_in_b = alu_src_ex ? imm_ex : forwarded_b;

    // -------------------------------------------------------------------------
    // ALU Control + ALU
    // -------------------------------------------------------------------------
    wire [3:0] alu_ctrl;
    alu_control alu_control_inst (
        .alu_op  (alu_op_ex),
        .funct3  (funct3_ex),
        .funct7_5(funct7_5_ex),
        .lui     (lui_ex),
        .alu_ctrl(alu_ctrl)
    );

    wire alu_zero;
    alu alu_inst (
        .a       (alu_in_a),
        .b       (alu_in_b),
        .alu_ctrl(alu_ctrl),
        .result  (alu_result_ex),
        .zero    (alu_zero)
    );

    // -------------------------------------------------------------------------
    // Branch Comparators (RV32I B-type)
    // Signed and unsigned comparisons done combinationally outside the ALU
    // to avoid routing alu_zero through extra mux logic for non-BEQ cases.
    // -------------------------------------------------------------------------
    wire signed_lt   = ($signed(forwarded_a_raw) < $signed(forwarded_b));
    wire unsigned_lt = (forwarded_a_raw < forwarded_b);

    wire branch_taken =
        (funct3_ex == 3'b000) ?  alu_zero    : // BEQ
        (funct3_ex == 3'b001) ? ~alu_zero    : // BNE
        (funct3_ex == 3'b100) ?  signed_lt   : // BLT
        (funct3_ex == 3'b101) ? ~signed_lt   : // BGE
        (funct3_ex == 3'b110) ?  unsigned_lt : // BLTU
        (funct3_ex == 3'b111) ? ~unsigned_lt : // BGEU
        1'b0;

    // -------------------------------------------------------------------------
    // Jump/Branch Target Calculation
    // JAL  : PC + imm
    // JALR : (rs1 + imm)[31:1] concatenated with 0 (LSB cleared)
    // Branch: PC + imm (same as JAL target)
    // -------------------------------------------------------------------------
    assign pc_plus4_ex = pc_ex + 32'd4;
    wire [31:0] jal_tgt  = pc_ex + imm_ex;
    wire [31:0] jalr_tgt = {alu_result_ex[31:1], 1'b0};

    wire is_jalr = jump_ex & alu_src_ex; // JALR uses immediate -> alu_src=1

    assign pc_sel  = jump_ex | (branch_ex & branch_taken);
    assign jump_tgt = is_jalr ? jalr_tgt : jal_tgt;

endmodule
