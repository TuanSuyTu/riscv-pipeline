`timescale 1ns / 1ps

module tb_top;
    reg  clk, rst;
    top uut (.clk(clk), .rst(rst));

    always #5 clk = ~clk;

    integer pass_count, fail_count, test_num;

    // Standard check task
    task automatic CHECK;
        input [4:0]  reg_idx;
        input [31:0] expected;
        input [63:0] test_name;
        begin
            test_num = test_num + 1;
            if (uut.regfile_inst.regs[reg_idx] === expected) begin
                $display("[PASS] Test %0d: x%0d = 0x%08h", test_num, reg_idx, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] Test %0d: x%0d = 0x%08h (exp 0x%08h) *** FAIL ***", 
                         test_num, reg_idx, uut.regfile_inst.regs[reg_idx], expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task automatic RESET_CPU;
        begin
            rst = 1;
            repeat(3) @(posedge clk);
            rst = 0;
            @(posedge clk);
        end
    endtask

    task automatic RUN;
        input integer cycles;
        begin
            repeat(cycles) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_top);

        clk = 0; rst = 1;
        pass_count = 0; fail_count = 0; test_num = 0;

        // --- PHASE 1: ISA Coverage ---
        $display("=================================================");
        $display("  PHASE 1: ISA Coverage Test");
        $display("=================================================");

        $readmemh("E:/VSCode/Github/Gitpush/riscv_pipeline/tb/test_phase1_isa.hex", uut.imem_inst.mem);
        RESET_CPU();
        uut.dmem_inst.mem[0] = 32'd100;
        uut.dmem_inst.mem[1] = 32'd200;
        uut.dmem_inst.mem[2] = 32'hFFFFFFFF;

        RUN(75);   // 19 instrs × ~4 CPI + BRAM stalls cho 2 LW

        CHECK(1,  32'd5,         "ADDI");
        CHECK(2,  32'd3,         "ADDI");
        CHECK(3,  32'd8,         "ADD");
        CHECK(4,  32'd2,         "SUB");
        CHECK(5,  32'd1,         "AND");
        CHECK(6,  32'd7,         "OR");
        CHECK(7,  32'd6,         "XOR");
        CHECK(8,  32'd40,        "SLL");
        CHECK(9,  32'd0,         "SRL");
        CHECK(10, 32'd1,         "SLT");
        CHECK(11, 32'd0,         "SLTU");
        CHECK(12, 32'h00001000,  "LUI");
        CHECK(14, 32'd100,       "LW");
        CHECK(15, 32'd200,       "LW+4");

        // --- PHASE 2: Hazards ---
        $display("\n=================================================");
        $display("  PHASE 2: Hazard & Forwarding Tests");
        $display("=================================================");

        $readmemh("E:/VSCode/Github/Gitpush/riscv_pipeline/tb/test_phase2_hazard.hex", uut.imem_inst.mem);
        RESET_CPU();
        uut.dmem_inst.mem[0] = 32'd42;

        RUN(65);   // hazards + BRAM stalls cho LW

        CHECK(2,  32'd20, "EX-EX");
        CHECK(4,  32'd14, "MEM-EX");
        CHECK(6,  32'd84, "LoadUse");
        CHECK(9,  32'd0,  "BEQ-S");
        CHECK(10, 32'd77, "BEQ-T");

        // --- PHASE 3: Integration (Sum 1..10) ---
        $display("\n=================================================");
        $display("  PHASE 3: Integration Test — Sum 1..10");
        $display("=================================================");

        $readmemh("E:/VSCode/Github/Gitpush/riscv_pipeline/tb/test_phase3_sum.hex", uut.imem_inst.mem);
        RESET_CPU();
        RUN(150);  // loop 10 iterations + branch overhead + BRAM

        CHECK(1, 32'd55, "Sum");

        // --- PHASE 4: Full ISA Coverage ---
        $display("\n=================================================");
        $display("  PHASE 4: Full RV32I ISA Coverage");
        $display("  I-ALU, Shifts, SRA, AUIPC, All Branches,");
        $display("  JAL, JALR, LB/LH/LBU/LHU, SB/SH");
        $display("=================================================");

        $readmemh("E:/VSCode/Github/Gitpush/riscv_pipeline/tb/test_phase4_full.hex", uut.imem_inst.mem);
        RESET_CPU();
        // Clear dmem locations used by Phase 4
        uut.dmem_inst.mem[0] = 32'd0;
        uut.dmem_inst.mem[1] = 32'd0;
        uut.dmem_inst.mem[2] = 32'd0;

        RUN(120);  // 56 instrs + 14 branch-flush + 6 BRAM + drain ≈ 80 cycles; JAL x0,0 at [55] prevents wrap-around

        // === GROUP A: I-type ALU (missing from Phase 1) ===
        // x1=5, x2=-4 (0xFFFFFFFC)
        CHECK(3,  32'd5,          "ANDI x3=5&7");      // 5 & 7 = 5
        CHECK(4,  32'd7,          "ORI  x4=5|2");      // 5 | 2 = 7
        CHECK(5,  32'd6,          "XORI x5=5^3");      // 5 ^ 3 = 6
        CHECK(6,  32'd1,          "SLTI x6=-4<0");     // -4 < 0 signed = 1
        CHECK(7,  32'd1,          "SLTIU x7=5<10u");   // 5 < 10 unsigned = 1

        // === GROUP B: Shift Immediate ===
        CHECK(8,  32'd20,         "SLLI x8=5<<2");     // 5 << 2 = 20
        CHECK(9,  32'd10,         "SRLI x9=20>>1");    // 20 >> 1 = 10
        CHECK(10, 32'hFFFFFFFE,   "SRAI x10=-4>>>1");  // -4 >>> 1 = -2

        // === GROUP C: SRA R-type ===
        CHECK(11, 32'hFFFFFFFF,   "SRA x11=-4>>>5");   // -4 >>> 5 = -1

        // === GROUP D: AUIPC ===
        // PC at instr[11] = 44 = 0x2C, imm=1 → x12 = 0x2C + 0x1000 = 0x102C
        CHECK(12, 32'h0000102C,   "AUIPC x12");

        // === GROUP E: Branch Instructions ===
        // BNE: x1=5 != x2=-4 → TAKEN, skip ADDI x13=99 → x13=0+5=5
        CHECK(13, 32'd5,          "BNE taken");
        // BLT: x2=-4 < x1=5 signed → TAKEN, skip x14=99 → x14=0+7=7
        CHECK(14, 32'd7,          "BLT taken");
        // BGE: x1=5 >= x2=-4 signed → TAKEN, skip x15=99 → x15=0+9=9
        CHECK(15, 32'd9,          "BGE taken");
        // BLTU: x1=5 <u x2=0xFFFFFFFC → TAKEN, skip x16=99 → x16=0+11=11
        CHECK(16, 32'd11,         "BLTU taken");
        // BGEU: x2=0xFFFFFFFC >=u x1=5 → TAKEN, skip x17=99 → x17=0+13=13
        CHECK(17, 32'd13,         "BGEU taken");

        // === GROUP F: JAL ===
        // JAL x18, +12 at instr[33]: x18 = 33*4+4 = 136 = 0x88
        CHECK(18, 32'd136,        "JAL link addr");
        // x19 never written (JAL skipped instrs [34],[35]) → x19 stays 0
        CHECK(19, 32'd0,          "JAL skip check");

        // === GROUP G: JALR ===
        // JALR x20, x0, 164 at instr[37]: x20 = 37*4+4 = 152 = 0x98
        CHECK(20, 32'd152,        "JALR link addr");
        // Pre-set x21=7 at instr[36]; JALR skips instrs [38]-[40] → x21 stays 7
        CHECK(21, 32'd7,          "JALR jump check");

        // === GROUP H: Load Instructions (LB, LBU, LH, LHU) ===
        // mem[0] = 0xDEADB789 stored by SW
        // byte[0] = 0x89 → LB sign-ext = 0xFFFFFF89 (-119)
        CHECK(23, 32'hFFFFFF89,   "LB signed");
        // LBU zero-ext = 0x00000089 = 137
        CHECK(24, 32'd137,        "LBU unsigned");
        // halfword[0] = 0xB789 → LH sign-ext = 0xFFFFB789 (-18551)
        CHECK(25, 32'hFFFFB789,   "LH signed");
        // LHU zero-ext = 0x0000B789 = 46985
        CHECK(26, 32'd46985,      "LHU unsigned");

        // === GROUP I: SB / SH Store Instructions ===
        // SB x27=90=0x5A at addr 4 → LBU x28 = 0x5A = 90
        CHECK(28, 32'd90,         "SB/LBU check");
        // SH x29=127=0x7F at addr 8 → LH x30 = 0x007F = 127
        CHECK(30, 32'd127,        "SH/LH check");

        $display("\n=================================================");
        $display("  TOTAL: %0d/%0d tests PASSED", pass_count, pass_count+fail_count);
        $display("=================================================");

        $finish;
    end

    initial begin
        #100000;
        $display("[TIMEOUT] Simulation hanging!");
        $finish;
    end
endmodule
