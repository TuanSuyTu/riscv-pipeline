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
