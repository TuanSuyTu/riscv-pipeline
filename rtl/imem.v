`timescale 1ns / 1ps

module imem (
    input  [31:0] addr,
    output [31:0] instr
);
    reg [31:0] mem [0:255]; 

    initial begin
        $readmemh("E:/VSCode/Github/Gitpush/riscv_pipeline/tb/test_prog.hex", mem);
    end

    // Word-aligned instruction fetch
    assign instr = mem[addr[9:2]];
endmodule
