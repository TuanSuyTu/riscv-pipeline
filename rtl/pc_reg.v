`timescale 1ns / 1ps

module pc_reg (
    input         clk,
    input         rst,
    input         stall,
    input         pc_sel,
    input  [31:0] branch_tgt,
    output reg [31:0] pc
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'h0;
        else if (!stall) begin
            if (pc_sel)
                pc <= branch_tgt;
            else
                pc <= pc + 4;
        end
    end
endmodule
