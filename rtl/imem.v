// =============================================================================
// Project: RISC-V 5-Stage Pipelined Processor
// Module: imem
// Description: Instruction Memory (ROM).
//              Currently implemented as an asynchronous memory for 1-cycle fetch.
// =============================================================================

`timescale 1ns / 1ps

module imem (
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] mem [0:255]; // 256 words (1 KB)

    initial begin
        // Loads program binary into memory for simulation
        $readmemh("E:/VSCode/Github/Gitpush/riscv_pipeline/tb/test_prog.hex", mem);
    end

    // Word-aligned instruction fetch (Mask bottom 2 bits)
    assign instr = mem[addr[9:2]];

endmodule
