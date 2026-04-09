// =============================================================================
// Module: bram_ctrl
// Description: BRAM Stall Controller.
//              Manages the 1-cycle synchronous read latency of Block RAM.
//              Generates stall_bram signal to freeze the pipeline for exactly
//              1 cycle during a LOAD instruction in the MEM stage.
// =============================================================================

`timescale 1ns / 1ps

module bram_ctrl (
    input  wire clk,
    input  wire rst,
    input  wire mem_read_mem,   // High when MEM stage has an active LOAD
    output wire stall_bram      // Stall pipeline for 1 cycle on BRAM read
);

    reg bram_done;

    // stall only when LOAD is in MEM and we haven't waited 1 cycle yet
    assign stall_bram = mem_read_mem & ~bram_done;

    // 1-bit FSM: SET during stall cycle, CLEAR the next cycle
    always @(posedge clk or posedge rst) begin
        if (rst) bram_done <= 1'b0;
        else     bram_done <= stall_bram;
    end

endmodule
