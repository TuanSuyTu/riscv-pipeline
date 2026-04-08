# synth.tcl
set outputDir ./synth_output
file mkdir $outputDir

# Read all RTL sources from the project
read_verilog ../rtl/alu.v
read_verilog ../rtl/control.v
read_verilog ../rtl/dmem.v
read_verilog ../rtl/forward.v
read_verilog ../rtl/hazard.v
read_verilog ../rtl/id_ex_reg.v
read_verilog ../rtl/if_id_reg.v
read_verilog ../rtl/ex_mem_reg.v
read_verilog ../rtl/mem_wb_reg.v
read_verilog ../rtl/imem.v
read_verilog ../rtl/imm_gen.v
read_verilog ../rtl/pc_reg.v
read_verilog ../rtl/regfile.v
read_verilog ../rtl/top.v

# Run Synthesis
# Target: Kria KV260 (xck26-sfvc784-2LV-c)
# Mode: Out-of-Context (since this is just the processor core without external wrapper constraints)
synth_design -top top -part xck26-sfvc784-2LV-c -mode out_of_context

# Save Checkpoint
write_checkpoint -force $outputDir/top_synth.dcp

# Export vital reports
report_utilization -file $outputDir/utilization.rpt
report_timing_summary -file $outputDir/timing.rpt

exit
