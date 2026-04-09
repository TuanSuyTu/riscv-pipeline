// =============================================================================
// Project: RISC-V 5-Stage Pipelined Processor
// Module:  top
// Description: Structural top-level. Instantiates and connects all pipeline
//              stages and pipeline registers. Contains no datapath logic.
//
// Pipeline Stages:
//   IF  -> IF/ID Reg -> ID -> ID/EX Reg -> EX -> EX/MEM Reg -> MEM -> MEM/WB Reg -> WB
//
// Support Modules:
//   bram_ctrl : Manages BRAM 1-cycle read latency stall
//   hazard    : Detects Load-Use data hazards
//   forward   : Resolves RAW hazards via bypass (EX-EX, MEM-EX)
//   ex_stage  : Encapsulates all EX combinational logic
// =============================================================================

`timescale 1ns / 1ps

module top (
    input clk,
    input rst
);

    // =========================================================================
    // Global Control Signals
    // =========================================================================
    wire stall_loaduse;  // From hazard unit: stall on Load-Use dependency
    wire stall_bram;     // From bram_ctrl:   stall on BRAM read latency
    wire pc_sel;         // From ex_stage:    redirect PC on branch/jump
    wire [1:0] forward_a, forward_b; // From forward unit

    wire stall       = stall_loaduse | stall_bram;
    wire flush_if_id = pc_sel;
    wire flush_id_ex = stall_loaduse | pc_sel; // NOTE: Never flush ID/EX on BRAM stall

    // =========================================================================
    // IF Stage: Instruction Fetch
    // =========================================================================
    wire [31:0] jump_tgt;
    wire [31:0] pc_if;

    pc_reg pc_reg_inst (
        .clk(clk), .rst(rst),
        .stall(stall),
        .pc_sel(pc_sel),
        .branch_tgt(jump_tgt),
        .pc(pc_if)
    );

    wire [31:0] instr_if;
    imem imem_inst (
        .addr(pc_if),
        .instr(instr_if)
    );

    // =========================================================================
    // IF/ID Pipeline Register
    // =========================================================================
    wire [31:0] pc_id, instr_id;
    if_id_reg if_id_reg_inst (
        .clk(clk), .rst(rst),
        .stall(stall), .flush(flush_if_id),
        .pc_in(pc_if),       .pc_out(pc_id),
        .instr_in(instr_if), .instr_out(instr_id)
    );

    // =========================================================================
    // ID Stage: Instruction Decode & Register Read
    // =========================================================================
    wire [6:0] opcode      = instr_id[6:0];
    wire [4:0] rs1_addr_id = instr_id[19:15];
    wire [4:0] rs2_addr_id = instr_id[24:20];
    wire [4:0] rd_addr_id  = instr_id[11:7];
    wire [2:0] funct3_id   = instr_id[14:12];
    wire       funct7_5_id = instr_id[30];

    wire reg_write_id, mem_read_id, mem_write_id, mem_to_reg_id;
    wire alu_src_id, branch_id, jump_id, lui_id, auipc_id;
    wire [1:0] alu_op_id;

    control control_inst (
        .opcode(opcode),
        .reg_write(reg_write_id), .mem_read(mem_read_id),
        .mem_write(mem_write_id), .mem_to_reg(mem_to_reg_id),
        .alu_src(alu_src_id),     .branch(branch_id),
        .jump(jump_id),           .lui(lui_id),
        .auipc(auipc_id),         .alu_op(alu_op_id)
    );

    wire [31:0] imm_id;
    imm_gen imm_gen_inst (
        .instr(instr_id), .imm_out(imm_id)
    );

    // Write-back feedback path (WB -> ID)
    wire        reg_write_wb;
    wire [4:0]  rd_addr_wb;
    wire [31:0] wd_data_wb;

    wire [31:0] rs1_data_id, rs2_data_id;
    regfile regfile_inst (
        .clk(clk),
        .we(reg_write_wb), .wd_addr(rd_addr_wb), .wd_data(wd_data_wb),
        .rs1_addr(rs1_addr_id), .rs2_addr(rs2_addr_id),
        .rs1_data(rs1_data_id), .rs2_data(rs2_data_id)
    );

    // =========================================================================
    // ID/EX Pipeline Register
    // =========================================================================
    wire        reg_write_ex, mem_read_ex, mem_write_ex, mem_to_reg_ex;
    wire        alu_src_ex, branch_ex, jump_ex, lui_ex, auipc_ex;
    wire [1:0]  alu_op_ex;
    wire [31:0] pc_ex, rs1_data_ex, rs2_data_ex, imm_ex;
    wire [4:0]  rs1_addr_ex, rs2_addr_ex, rd_addr_ex;
    wire [2:0]  funct3_ex;
    wire        funct7_5_ex;

    id_ex_reg id_ex_reg_inst (
        .clk(clk), .rst(rst),
        .flush(flush_id_ex),
        .stall(stall_bram),
        .reg_write_in(reg_write_id),   .reg_write_out(reg_write_ex),
        .mem_read_in(mem_read_id),     .mem_read_out(mem_read_ex),
        .mem_write_in(mem_write_id),   .mem_write_out(mem_write_ex),
        .mem_to_reg_in(mem_to_reg_id), .mem_to_reg_out(mem_to_reg_ex),
        .alu_src_in(alu_src_id),       .alu_src_out(alu_src_ex),
        .branch_in(branch_id),         .branch_out(branch_ex),
        .jump_in(jump_id),             .jump_out(jump_ex),
        .lui_in(lui_id),               .lui_out(lui_ex),
        .auipc_in(auipc_id),           .auipc_out(auipc_ex),
        .alu_op_in(alu_op_id),         .alu_op_out(alu_op_ex),
        .pc_in(pc_id),                 .pc_out(pc_ex),
        .rs1_data_in(rs1_data_id),     .rs1_data_out(rs1_data_ex),
        .rs2_data_in(rs2_data_id),     .rs2_data_out(rs2_data_ex),
        .imm_in(imm_id),               .imm_out(imm_ex),
        .rs1_addr_in(rs1_addr_id),     .rs1_addr_out(rs1_addr_ex),
        .rs2_addr_in(rs2_addr_id),     .rs2_addr_out(rs2_addr_ex),
        .rd_addr_in(rd_addr_id),       .rd_addr_out(rd_addr_ex),
        .funct3_in(funct3_id),         .funct3_out(funct3_ex),
        .funct7_5_in(funct7_5_id),     .funct7_5_out(funct7_5_ex)
    );

    // =========================================================================
    // EX Stage (Encapsulated)
    // =========================================================================
    wire [31:0] alu_result_ex, forwarded_b_ex, pc_plus4_ex;
    wire [31:0] alu_result_mem; // fed back from EX/MEM register

    ex_stage ex_stage_inst (
        // Inputs from ID/EX
        .rs1_data_ex  (rs1_data_ex),
        .rs2_data_ex  (rs2_data_ex),
        .imm_ex       (imm_ex),
        .pc_ex        (pc_ex),
        .alu_op_ex    (alu_op_ex),
        .funct3_ex    (funct3_ex),
        .funct7_5_ex  (funct7_5_ex),
        .alu_src_ex   (alu_src_ex),
        .branch_ex    (branch_ex),
        .jump_ex      (jump_ex),
        .lui_ex       (lui_ex),
        .auipc_ex     (auipc_ex),
        // Forwarding
        .forward_a    (forward_a),
        .forward_b    (forward_b),
        .alu_result_mem(alu_result_mem),
        .wd_data_wb   (wd_data_wb),
        // Outputs
        .alu_result_ex  (alu_result_ex),
        .forwarded_b_out(forwarded_b_ex),
        .pc_plus4_ex    (pc_plus4_ex),
        .pc_sel         (pc_sel),
        .jump_tgt       (jump_tgt)
    );

    // =========================================================================
    // EX/MEM Pipeline Register
    // =========================================================================
    wire        reg_write_mem, mem_write_mem, mem_to_reg_mem, jump_mem;
    wire [2:0]  funct3_mem;
    wire [31:0] rs2_data_mem, pc_plus4_mem;
    wire [4:0]  rd_addr_mem;

    ex_mem_reg ex_mem_reg_inst (
        .clk(clk), .rst(rst),
        .stall(stall_bram),
        .reg_write_in(reg_write_ex),   .reg_write_out(reg_write_mem),
        .mem_read_in(mem_read_ex),     .mem_read_out(mem_read_mem),
        .mem_write_in(mem_write_ex),   .mem_write_out(mem_write_mem),
        .mem_to_reg_in(mem_to_reg_ex), .mem_to_reg_out(mem_to_reg_mem),
        .jump_in(jump_ex),             .jump_out(jump_mem),
        .funct3_in(funct3_ex),         .funct3_out(funct3_mem),
        .alu_result_in(alu_result_ex), .alu_result_out(alu_result_mem),
        .rs2_data_in(forwarded_b_ex),  .rs2_data_out(rs2_data_mem),
        .pc_plus4_in(pc_plus4_ex),     .pc_plus4_out(pc_plus4_mem),
        .rd_addr_in(rd_addr_ex),       .rd_addr_out(rd_addr_mem)
    );

    // =========================================================================
    // MEM Stage: Data Memory Access
    // =========================================================================
    wire [31:0] read_data_mem;

    dmem dmem_inst (
        .clk(clk),
        .mem_read(mem_read_mem),
        .mem_write(mem_write_mem),
        .funct3(funct3_mem),
        .addr(alu_result_mem),
        .wd(rs2_data_mem),
        .rd(read_data_mem)
    );

    // =========================================================================
    // MEM/WB Pipeline Register
    // =========================================================================
    wire        mem_to_reg_wb, jump_wb;
    wire [31:0] read_data_wb, alu_result_wb, pc_plus4_wb;

    mem_wb_reg mem_wb_reg_inst (
        .clk(clk), .rst(rst),
        .flush(stall_bram),
        .reg_write_in(reg_write_mem),   .reg_write_out(reg_write_wb),
        .mem_to_reg_in(mem_to_reg_mem), .mem_to_reg_out(mem_to_reg_wb),
        .jump_in(jump_mem),             .jump_out(jump_wb),
        .read_data_in(read_data_mem),   .read_data_out(read_data_wb),
        .alu_result_in(alu_result_mem), .alu_result_out(alu_result_wb),
        .pc_plus4_in(pc_plus4_mem),     .pc_plus4_out(pc_plus4_wb),
        .rd_addr_in(rd_addr_mem),       .rd_addr_out(rd_addr_wb)
    );

    // =========================================================================
    // WB Stage: Write-Back MUX
    // =========================================================================
    assign wd_data_wb = jump_wb       ? pc_plus4_wb  :
                        mem_to_reg_wb ? read_data_wb  :
                        alu_result_wb;

    // =========================================================================
    // Support Units: BRAM Controller, Hazard, Forwarding
    // =========================================================================
    bram_ctrl bram_ctrl_inst (
        .clk        (clk),
        .rst        (rst),
        .mem_read_mem(mem_read_mem),
        .stall_bram (stall_bram)
    );

    hazard hazard_inst (
        .id_ex_mem_read(mem_read_ex),
        .id_ex_rd      (rd_addr_ex),
        .if_id_rs1     (rs1_addr_id),
        .if_id_rs2     (rs2_addr_id),
        .stall         (stall_loaduse)
    );

    forward forward_inst (
        .id_ex_rs1       (rs1_addr_ex),
        .id_ex_rs2       (rs2_addr_ex),
        .ex_mem_reg_write(reg_write_mem),
        .ex_mem_rd       (rd_addr_mem),
        .mem_wb_reg_write(reg_write_wb),
        .mem_wb_rd       (rd_addr_wb),
        .forward_a       (forward_a),
        .forward_b       (forward_b)
    );

endmodule
