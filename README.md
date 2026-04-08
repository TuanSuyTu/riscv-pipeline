# 5-Stage Pipelined RISC-V Processor (RV32I Subset)

> This project implements a cycle-accurate, 5-stage pipelined RISC-V processor in Verilog. It is optimized for FPGA deployment with synchronous BRAM data memory and robust hazard handling.

## Key Features

- **5-stage Pipeline**: `IF` (Fetch) → `ID` (Decode) → `EX` (Execute) → `MEM` (Memory) → `WB` (Write-Back).
- **Synchronous BRAM Integration**: Data Memory (4KB) is inferred as Xilinx Block RAM for high-frequency performance.
- **BRAM Stall Logic**: Automatically manages the 1-cycle synchronous read latency by injecting a controlled 1-cycle stall during Memory operations.
- **Full Forwarding (Bypassing)**: Resolves RAW (Read-After-Write) hazards via EX-EX and MEM-EX bypassing, maintaining a CPI close to 1 for arithmetic code.
- **Hazard Detection Unit**: Supports interlocking for "Load-Use" dependencies, ensuring data integrity when a LOAD result is consumed immediately.
- **Branch Resolution**: Branches and jumps are resolved in the EX stage with pipeline flushing on taken/mispredicted paths.

## Instruction Set Support (RV32I)

| Type | Instructions |
|------|--------------|
| **R-type** | `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND` |
| **I-type** | `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI`, `LW`, `LB`, `LH`, `LBU`, `LHU`, `JALR` |
| **S-type** | `SW`, `SB`, `SH` |
| **B-type** | `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU` |
| **U-type** | `LUI`, `AUIPC` |
| **J-type** | `JAL` |

## Hardware Synthesis Results

The project has been synthesized and implemented on the **Xilinx Kria K26 SOM** (Zynq UltraScale+).

### Resource Utilization
| Resource | Utilization |
|----------|-------------|
| **CLB LUTs** | 1115 |
| **CLB Registers** | 474 |
| **Block RAM (Tile)** | 1 |
| **CARRY8** | 28 |
| **F7 Muxes** | 1 |

### Timing & Power
- **Critical Path Delay**: ~8.32 ns.
- **Target Frequency (Fmax)**: ~120 MHz (Synthesized on Zynq UltraScale+ Kria K26).
- **Setup Slack (at 100 MHz)**: +2.176 ns (WNS, All timing constraints met).

## Verification

The processor is verified via a self-checking testbench (`tb_top.v`) that runs a 3-phase regression suite:
1. **ISA Coverage**: Tests every supported instruction bit-accurately.
2. **Hazard Stress Test**: Forces complicated EX-EX and MEM-EX forwarding scenarios and Load-Use stalls.
3. **Integration**: Executes a "Sum 1 to 10" assembly program.

**Result: 20/20 Checks PASSED.**

## Architecture Overview

```mermaid
graph LR
    IF[IF: Fetch] --> ID[ID: Decode]
    ID --> EX[EX: Execute]
    EX --> MEM[MEM: Memory]
    MEM --> WB[WB: Write-Back]
    
    subgraph "Hazard Management"
    FWD[Forwarding Unit] -.-> EX
    HAZ[Hazard Detection] -.-> IF & ID
    BRAM_STALL[BRAM Stall Logic] -.-> IF & ID & EX
    end
```

## How to Run

### Simulation (Vivado CLI)
```bash
mkdir sim_logs
cd sim_logs
xvlog -sv ../rtl/*.v ../tb/*.v
xelab --timescale 1ns/1ps -top tb_top -snapshot snapshot
xsim snapshot -R
```

### Synthesis
Open Vivado and add files in `rtl/`. Targeting Kria K26 or similar Zynq UltraScale+ boards is recommended for best BRAM utilization.
