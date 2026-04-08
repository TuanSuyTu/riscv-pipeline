// =============================================================================
// Project: RISC-V 5-Stage Pipelined Processor
// Module: top
// Description: Top-level module integrating the Datapath and Control units.
//              Implements a 5-stage pipeline (IF, ID, EX, MEM, WB).
//
// Features:
// - Data Forwarding (EX->EX, MEM->EX)
// - Hazard Detection (Load-Use Stall)
// - BRAM Latency Management (1-cycle Pipeline Stall for Memory Reads)
// =============================================================================

`timescale 1ns / 1ps

module top (
    input clk,
    input rst
);

    // -------------------------------------------------------------------------
    // BRAM Stall Logic
    // -------------------------------------------------------------------------
    // Data memory (BRAM) has a 1-cycle synchronous read latency. 
    // We handle this by stalling the pipeline for 1 cycle when a LOAD instruction
    // reaches the MEM stage.
    
    wire mem_read_mem;   // Asserted if instruction in MEM stage is a LOAD
    reg  bram_done;      // Internal state to track if BRAM access is completed
    wire stall_bram = mem_read_mem && !bram_done;

    always @(posedge clk or posedge rst) begin
        if (rst) bram_done <= 1'b0;
        else     bram_done <= stall_bram; // SET bram_done during the stall cycle
    end

    // -------------------------------------------------------------------------
    // Global Control Signals
    // -------------------------------------------------------------------------
    wire stall_loaduse;                              // From Hazard Unit
    wire pc_sel;                                     // From EX stage (Branch/Jump target select)
    
    // Combined stall for Fetch/Decode stages
    wire stall = stall_loaduse | stall_bram;         
    
    // Flush signals for mispredicted branches or load-use bubbles
    wire flush_if_id = pc_sel;
    wire flush_id_ex = stall_loaduse | pc_sel;       // NOTE: Never flush ID/EX during BRAM stall

    // -------------------------------------------------------------------------
    // IF Stage: Instruction Fetch
    // -------------------------------------------------------------------------
    wire [31:0] jump_tgt;
    (* DONT_TOUCH = "yes" *) wire [31:0] pc_if;

    (* DONT_TOUCH = "yes" *) pc_reg pc_reg_inst (
        .clk(clk), .rst(rst),
        .stall(stall),
        .pc_sel(pc_sel),
        .branch_tgt(jump_tgt),
        .pc(pc_if)
    );

    wire [31:0] instr_if;
    (* DONT_TOUCH = "yes" *) imem imem_inst (
        .addr(pc_if),
        .instr(instr_if)
    );

    // -------------------------------------------------------------------------
    // IF/ID Pipeline Register
    // -------------------------------------------------------------------------
    wire [31:0] pc_id, instr_id;

    (* DONT_TOUCH = "yes" *) if_id_reg if_id_reg_inst (
        .clk(clk), .rst(rst),
        .stall(stall), .flush(flush_if_id),
        .pc_in(pc_if),      .pc_out(pc_id),
        .instr_in(instr_if),.instr_out(instr_id)
    );

    // -------------------------------------------------------------------------
    // ID Stage: Instruction Decode & Register Read
    // -------------------------------------------------------------------------
    wire [6:0] opcode      = instr_id[6:0];
    wire [4:0] rs1_addr_id = instr_id[19:15];
    wire [4:0] rs2_addr_id = instr_id[24:20];
    wire [4:0] rd_addr_id  = instr_id[11:7];
    wire [2:0] funct3_id   = instr_id[14:12];
    wire       funct7_5_id = instr_id[30];

    wire reg_write_id, mem_read_id, mem_write_id, mem_to_reg_id;
    wire alu_src_id, branch_id, jump_id, lui_id, auipc_id;
    wire [1:0] alu_op_id;

    (* DONT_TOUCH = "yes" *) control control_inst (
        .opcode(opcode),
        .reg_write(reg_write_id), .mem_read(mem_read_id),
        .mem_write(mem_write_id), .mem_to_reg(mem_to_reg_id),
        .alu_src(alu_src_id),     .branch(branch_id),
        .jump(jump_id),           .lui(lui_id),
        .auipc(auipc_id),         .alu_op(alu_op_id)
    );

    wire [31:0] imm_id;
    (* DONT_TOUCH = "yes" *) imm_gen imm_gen_inst (
        .instr(instr_id), .imm_out(imm_id)
    );

    // Write-back signals (Feedback path)
    wire        reg_write_wb;
    wire [4:0]  rd_addr_wb;
    (* DONT_TOUCH = "yes" *) wire [31:0] wd_data_wb;

    wire [31:0] rs1_data_id, rs2_data_id;
    (* DONT_TOUCH = "yes" *) regfile regfile_inst (
        .clk(clk),
        .we(reg_write_wb),     .wd_addr(rd_addr_wb), .wd_data(wd_data_wb),
        .rs1_addr(rs1_addr_id),.rs2_addr(rs2_addr_id),
        .rs1_data(rs1_data_id),.rs2_data(rs2_data_id)
    );

    // -------------------------------------------------------------------------
    // ID/EX Pipeline Register
    // -------------------------------------------------------------------------
    wire        reg_write_ex, mem_read_ex, mem_write_ex, mem_to_reg_ex;
    wire        alu_src_ex, branch_ex, jump_ex, lui_ex, auipc_ex;
    wire [1:0]  alu_op_ex;
    wire [31:0] pc_ex, rs1_data_ex, rs2_data_ex, imm_ex;
    wire [4:0]  rs1_addr_ex, rs2_addr_ex, rd_addr_ex;
    wire [2:0]  funct3_ex;
    wire        funct7_5_ex;

    (* DONT_TOUCH = "yes" *) id_ex_reg id_ex_reg_inst (
        .clk(clk), .rst(rst),
        .flush(flush_id_ex),
        .stall(stall_bram),      // FREEZE ID/EX during BRAM stall
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

    // -------------------------------------------------------------------------
    // EX Stage: Execution & ALU
    // -------------------------------------------------------------------------
    wire [1:0]  forward_a, forward_b;
    wire [31:0] alu_result_mem;

    // ALU Input MUXes with Forwarding (Bypass) logic
    wire [31:0] forwarded_a_raw = (forward_a == 2'b10) ? alu_result_mem :
                                  (forward_a == 2'b01) ? wd_data_wb :
                                  rs1_data_ex;

    wire [31:0] forwarded_b = (forward_b == 2'b10) ? alu_result_mem :
                              (forward_b == 2'b01) ? wd_data_wb :
                              rs2_data_ex;

    wire [31:0] alu_in_a = lui_ex   ? 32'd0    :
                           auipc_ex ? pc_ex     :
                           forwarded_a_raw;

    wire [31:0] alu_in_b = alu_src_ex ? imm_ex : forwarded_b;

    wire [3:0] alu_ctrl;
    (* DONT_TOUCH = "yes" *) alu_control alu_control_inst (
        .alu_op(alu_op_ex), .funct3(funct3_ex),
        .funct7_5(funct7_5_ex), .lui(lui_ex),
        .alu_ctrl(alu_ctrl)
    );

    wire [31:0] alu_result_ex;
    wire        alu_zero;
    (* DONT_TOUCH = "yes" *) alu alu_inst (
        .a(alu_in_a), .b(alu_in_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result_ex), .zero(alu_zero)
    );

    // Branch/Jump Target Calculation
    wire [31:0] pc_plus4_ex = pc_ex + 32'd4;
    wire [31:0] jal_tgt     = pc_ex + imm_ex;
    wire [31:0] jalr_tgt    = {alu_result_ex[31:1], 1'b0};

    // Conditional Branch Login (RV32I)
    wire signed_lt   = ($signed(forwarded_a_raw) < $signed(forwarded_b));
    wire unsigned_lt = (forwarded_a_raw < forwarded_b);

    wire branch_taken_wire =
        (funct3_ex == 3'b000) ?  alu_zero    : // BEQ
        (funct3_ex == 3'b001) ? ~alu_zero    : // BNE
        (funct3_ex == 3'b100) ?  signed_lt   : // BLT
        (funct3_ex == 3'b101) ? ~signed_lt   : // BGE
        (funct3_ex == 3'b110) ?  unsigned_lt : // BLTU
        (funct3_ex == 3'b111) ? ~unsigned_lt : // BGEU
        1'b0;

    wire opcode_ex_is_jalr = jump_ex && alu_src_ex;
    assign pc_sel   = jump_ex || (branch_ex && branch_taken_wire);
    assign jump_tgt = jump_ex ? (opcode_ex_is_jalr ? jalr_tgt : jal_tgt) : jal_tgt;

    // -------------------------------------------------------------------------
    // EX/MEM Pipeline Register
    // -------------------------------------------------------------------------
    wire        reg_write_mem, mem_write_mem, mem_to_reg_mem, jump_mem;
    wire [2:0]  funct3_mem;
    wire [31:0] rs2_data_mem, pc_plus4_mem;
    wire [4:0]  rd_addr_mem;

    (* DONT_TOUCH = "yes" *) ex_mem_reg ex_mem_reg_inst (
        .clk(clk), .rst(rst),
        .stall(stall_bram),             // FREEZE EX/MEM during BRAM stall
        .reg_write_in(reg_write_ex),   .reg_write_out(reg_write_mem),
        .mem_read_in(mem_read_ex),     .mem_read_out(mem_read_mem),
        .mem_write_in(mem_write_ex),   .mem_write_out(mem_write_mem),
        .mem_to_reg_in(mem_to_reg_ex), .mem_to_reg_out(mem_to_reg_mem),
        .jump_in(jump_ex),             .jump_out(jump_mem),
        .funct3_in(funct3_ex),         .funct3_out(funct3_mem),
        .alu_result_in(alu_result_ex), .alu_result_out(alu_result_mem),
        .rs2_data_in(forwarded_b),     .rs2_data_out(rs2_data_mem),
        .pc_plus4_in(pc_plus4_ex),     .pc_plus4_out(pc_plus4_mem),
        .rd_addr_in(rd_addr_ex),       .rd_addr_out(rd_addr_mem)
    );

    // -------------------------------------------------------------------------
    // MEM Stage: Data Memory (Synchronous BRAM)
    // -------------------------------------------------------------------------
    wire [31:0] read_data_mem;

    (* DONT_TOUCH = "yes" *) dmem dmem_inst (
        .clk(clk),
        .mem_read(mem_read_mem),
        .mem_write(mem_write_mem),
        .funct3(funct3_mem),
        .addr(alu_result_mem),
        .wd(rs2_data_mem),
        .rd(read_data_mem)
    );

    // -------------------------------------------------------------------------
    // MEM/WB Pipeline Register
    // -------------------------------------------------------------------------
    wire        mem_to_reg_wb, jump_wb;
    wire [31:0] read_data_wb, alu_result_wb, pc_plus4_wb;

    (* DONT_TOUCH = "yes" *) mem_wb_reg mem_wb_reg_inst (
        .clk(clk), .rst(rst),
        .flush(stall_bram),            // INSERT BUBBLE into WB stage during BRAM stall
        .reg_write_in(reg_write_mem),   .reg_write_out(reg_write_wb),
        .mem_to_reg_in(mem_to_reg_mem), .mem_to_reg_out(mem_to_reg_wb),
        .jump_in(jump_mem),             .jump_out(jump_wb),
        .read_data_in(read_data_mem),   .read_data_out(read_data_wb),
        .alu_result_in(alu_result_mem), .alu_result_out(alu_result_wb),
        .pc_plus4_in(pc_plus4_mem),     .pc_plus4_out(pc_plus4_wb),
        .rd_addr_in(rd_addr_mem),       .rd_addr_out(rd_addr_wb)
    );

    // -------------------------------------------------------------------------
    // Support Units: Hazard & Forwarding
    // -------------------------------------------------------------------------
    
    // Hazard Detection - Injects 1 NOP bubble for Load-Use dependencies
    (* DONT_TOUCH = "yes" *) hazard hazard_inst (
        .id_ex_mem_read(mem_read_ex),
        .id_ex_rd(rd_addr_ex),
        .if_id_rs1(rs1_addr_id),
        .if_id_rs2(rs2_addr_id),
        .stall(stall_loaduse)
    );

    // Forwarding Unit - Resolves Data Hazards (RAW) via bypass paths
    (* DONT_TOUCH = "yes" *) forward forward_inst (
        .id_ex_rs1(rs1_addr_ex),
        .id_ex_rs2(rs2_addr_ex),
        .ex_mem_reg_write(reg_write_mem),
        .ex_mem_rd(rd_addr_mem),
        .mem_wb_reg_write(reg_write_wb),
        .mem_wb_rd(rd_addr_wb),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    // -------------------------------------------------------------------------
    // WB Stage: Write-Back MUX
    // -------------------------------------------------------------------------
    assign wd_data_wb = jump_wb       ? pc_plus4_wb  :
                        mem_to_reg_wb ? read_data_wb :
                        alu_result_wb;

endmodule
