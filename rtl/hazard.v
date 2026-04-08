// =============================================================================
// Project: RISC-V 5-Stage Pipelined Processor
// Module: hazard
// Description: Hazard Detection Unit responsible for pipeline stalls.
// 
// Logic:
// - Detects "Load-Use" data hazards: when a LOAD instruction in EX stage 
//   has a destination register (rd) that is needed by the instruction 
//   currently in ID stage (rs1 or rs2).
// - Actions: Asserts 'stall' to freeze PC/IF-ID registers and injects NOP to EX.
// =============================================================================

module hazard (
    input        id_ex_mem_read,
    input  [4:0] id_ex_rd,
    input  [4:0] if_id_rs1,
    input  [4:0] if_id_rs2,
    output       stall
);
    // RAW Hazard detection logic
    assign stall = id_ex_mem_read && (id_ex_rd != 5'd0) &&
                   ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2));

endmodule
