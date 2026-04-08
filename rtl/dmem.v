// =============================================================================
// Project: RISC-V 5-Stage Pipelined Processor
// Module: dmem
// Description: Data Memory unit with synchronous read/write.
//              Optimized for Xilinx BRAM inference.
//
// Size: 1024 words x 32-bit (4 KB)
// Features: 
// - Byte-addressable access via word alignment.
// - Supports RV32I load/store types (LB, LH, LW, LBU, LHU, SB, SH, SW).
// - Synchronous output (word_data_r) to ensure BRAM inference.
// =============================================================================

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
    // BRAM instance hint for Vivado
    (* ram_style = "block" *)
    reg [31:0] mem [0:1023];

    // Initialization (Optional for hardware, useful for simulation)
    integer i;
    initial for (i = 0; i < 1024; i = i+1) mem[i] = 32'd0;

    // Address decoding: Translate byte address to word index
    wire [1:0]  byte_offset = addr[1:0];
    wire [9:0]  word_addr   = addr[11:2];

    // -------------------------------------------------------------------------
    // WRITE PORT (Synchronous)
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (mem_write) begin
            case (funct3[1:0])
                2'b10: mem[word_addr] <= wd; // SW: Store Word
                2'b01: begin                 // SH: Store Halfword
                    case (byte_offset[1])
                        1'b0: mem[word_addr][15:0]  <= wd[15:0];
                        1'b1: mem[word_addr][31:16] <= wd[15:0];
                    endcase
                end
                2'b00: begin                 // SB: Store Byte
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

    // -------------------------------------------------------------------------
    // READ PORT (Synchronous BRAM Inference)
    // -------------------------------------------------------------------------
    // Pipeline control registers for the 1-cycle latency output
    reg [2:0] funct3_r;
    reg [1:0] byte_offset_r;
    reg       mem_read_r;

    always @(posedge clk) begin
        funct3_r      <= funct3;
        byte_offset_r <= byte_offset;
        mem_read_r    <= mem_read;
    end

    // BRAM Output Data Register (Ensures inference of block RAM)
    reg [31:0] word_data_r;
    always @(posedge clk) begin
        if (mem_read)
            word_data_r <= mem[word_addr];
    end

    // -------------------------------------------------------------------------
    // DATA UNPACKING (Combinational post-read)
    // -------------------------------------------------------------------------
    always @(*) begin
        if (mem_read_r) begin
            case (funct3_r)
                3'b000: begin // LB: Load Byte (Sign-extend)
                    case (byte_offset_r)
                        2'b00: rd = {{24{word_data_r[7]}},  word_data_r[7:0]};
                        2'b01: rd = {{24{word_data_r[15]}}, word_data_r[15:8]};
                        2'b10: rd = {{24{word_data_r[23]}}, word_data_r[23:16]};
                        2'b11: rd = {{24{word_data_r[31]}}, word_data_r[31:24]};
                        default: rd = 32'd0;
                    endcase
                end
                3'b001: begin // LH: Load Halfword (Sign-extend)
                    case (byte_offset_r[1])
                        1'b0: rd = {{16{word_data_r[15]}}, word_data_r[15:0]};
                        1'b1: rd = {{16{word_data_r[31]}}, word_data_r[31:16]};
                        default: rd = 32'd0;
                    endcase
                end
                3'b010: rd = word_data_r; // LW: Load Word
                3'b100: begin             // LBU: Load Byte Unsigned (Zero-extend)
                    case (byte_offset_r)
                        2'b00: rd = {24'd0, word_data_r[7:0]};
                        2'b01: rd = {24'd0, word_data_r[15:8]};
                        2'b10: rd = {24'd0, word_data_r[23:16]};
                        2'b11: rd = {24'd0, word_data_r[31:24]};
                        default: rd = 32'd0;
                    endcase
                end
                3'b101: begin             // LHU: Load Halfword Unsigned (Zero-extend)
                    case (byte_offset_r[1])
                        1'b0: rd = {16'd0, word_data_r[15:0]};
                        1'b1: rd = {16'd0, word_data_r[31:16]};
                        default: rd = 32'd0;
                    endcase
                end
                default: rd = word_data_r;
            endcase
        end else begin
            rd = 32'd0;
        end
    end

endmodule
