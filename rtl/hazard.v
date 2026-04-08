`timescale 1ns / 1ps
module hazard (
    input        id_ex_mem_read,
    input  [4:0] id_ex_rd,
    input  [4:0] if_id_rs1,
    input  [4:0] if_id_rs2,
    output       stall
);
    assign stall = (id_ex_mem_read && (id_ex_rd != 5'd0) &&
                   ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) ? 1'b1 : 1'b0;
endmodule
