module id_ex_reg (
    input        clk, rst,
    input        flush,

    // Control in
    input        reg_write_in, mem_read_in, mem_write_in,
    input        mem_to_reg_in, alu_src_in, branch_in,
    input        jump_in, lui_in, auipc_in,
    input [1:0]  alu_op_in,

    // Data in
    input [31:0] pc_in, rs1_data_in, rs2_data_in, imm_in,
    input [4:0]  rs1_addr_in, rs2_addr_in, rd_addr_in,
    input [2:0]  funct3_in,
    input        funct7_5_in,

    // Control out
    output reg        reg_write_out, mem_read_out, mem_write_out,
    output reg        mem_to_reg_out, alu_src_out, branch_out,
    output reg        jump_out, lui_out, auipc_out,
    output reg [1:0]  alu_op_out,

    // Data out
    output reg [31:0] pc_out, rs1_data_out, rs2_data_out, imm_out,
    output reg [4:0]  rs1_addr_out, rs2_addr_out, rd_addr_out,
    output reg [2:0]  funct3_out,
    output reg        funct7_5_out
);
    always @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            {reg_write_out, mem_read_out, mem_write_out,
             mem_to_reg_out, alu_src_out, branch_out,
             jump_out, lui_out, auipc_out} <= 0;
            alu_op_out <= 0;
            {pc_out, rs1_data_out, rs2_data_out, imm_out} <= 0;
            {rs1_addr_out, rs2_addr_out, rd_addr_out} <= 0;
            {funct3_out, funct7_5_out} <= 0;
        end else begin
            reg_write_out  <= reg_write_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            alu_src_out    <= alu_src_in;
            branch_out     <= branch_in;
            jump_out       <= jump_in;
            lui_out        <= lui_in;
            auipc_out      <= auipc_in;
            alu_op_out     <= alu_op_in;
            pc_out         <= pc_in;
            rs1_data_out   <= rs1_data_in;
            rs2_data_out   <= rs2_data_in;
            imm_out        <= imm_in;
            rs1_addr_out   <= rs1_addr_in;
            rs2_addr_out   <= rs2_addr_in;
            rd_addr_out    <= rd_addr_in;
            funct3_out     <= funct3_in;
            funct7_5_out   <= funct7_5_in;
        end
    end
endmodule
