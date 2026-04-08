module regfile (
    input         clk,
    input         we,
    input  [4:0]  wd_addr,
    input  [31:0] wd_data,
    input  [4:0]  rs1_addr,
    input  [4:0]  rs2_addr,
    output [31:0] rs1_data,
    output [31:0] rs2_data
);
    reg [31:0] regs [0:31];
    integer i;

    initial for (i = 0; i < 32; i = i+1) regs[i] = 0;

    always @(posedge clk) begin
        if (we && wd_addr != 5'd0)
            regs[wd_addr] <= wd_data;
    end

    // Internal write-bypass logic
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 :
                      (we && (wd_addr == rs1_addr)) ? wd_data : regs[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 :
                      (we && (wd_addr == rs2_addr)) ? wd_data : regs[rs2_addr];
endmodule
