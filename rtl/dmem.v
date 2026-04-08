`timescale 1ns / 1ps

module dmem (
    input         clk,
    input         mem_read,
    input         mem_write,
    input  [2:0]  funct3,
    input  [31:0] addr,
    input  [31:0] wd,
    output reg [31:0] rd
);
    reg [31:0] mem [0:255];
    integer i;
    initial for (i = 0; i < 256; i = i+1) mem[i] = 0;

    wire [7:0]  byte_offset = addr[1:0];
    wire [29:0] word_addr   = addr[31:2];

    always @(posedge clk) begin
        if (mem_write) begin
            case (funct3[1:0])
                2'b10: mem[word_addr] <= wd; 
                2'b01: begin 
                    case (byte_offset[1])
                        1'b0: mem[word_addr][15:0]  <= wd[15:0];
                        1'b1: mem[word_addr][31:16] <= wd[15:0];
                    endcase
                end
                2'b00: begin 
                    case (byte_offset)
                        2'b00: mem[word_addr][7:0]   <= wd[7:0];
                        2'b01: mem[word_addr][15:8]  <= wd[7:0];
                        2'b10: mem[word_addr][23:16] <= wd[7:0];
                        2'b11: mem[word_addr][31:24] <= wd[7:0];
                    endcase
                end
                default: mem[word_addr] <= wd;
            endcase
        end
    end

    wire [31:0] word_data = mem[word_addr];

    always @(*) begin
        if (mem_read) begin
            case (funct3)
                3'b000: begin // LB
                    case (byte_offset)
                        2'b00: rd = {{24{word_data[7]}},  word_data[7:0]};
                        2'b01: rd = {{24{word_data[15]}}, word_data[15:8]};
                        2'b10: rd = {{24{word_data[23]}}, word_data[23:16]};
                        2'b11: rd = {{24{word_data[31]}}, word_data[31:24]};
                        default: rd = 32'd0;
                    endcase
                end
                3'b001: begin // LH
                    case (byte_offset[1])
                        1'b0: rd = {{16{word_data[15]}}, word_data[15:0]};
                        1'b1: rd = {{16{word_data[31]}}, word_data[31:16]};
                        default: rd = 32'd0;
                    endcase
                end
                3'b010: rd = word_data; // LW
                3'b100: begin // LBU
                    case (byte_offset)
                        2'b00: rd = {24'd0, word_data[7:0]};
                        2'b01: rd = {24'd0, word_data[15:8]};
                        2'b10: rd = {24'd0, word_data[23:16]};
                        2'b11: rd = {24'd0, word_data[31:24]};
                        default: rd = 32'd0;
                    endcase
                end
                3'b101: begin // LHU
                    case (byte_offset[1])
                        1'b0: rd = {16'd0, word_data[15:0]};
                        1'b1: rd = {16'd0, word_data[31:16]};
                        default: rd = 32'd0;
                    endcase
                end
                default: rd = word_data;
            endcase
        end else begin
            rd = 32'd0;
        end
    end
endmodule
