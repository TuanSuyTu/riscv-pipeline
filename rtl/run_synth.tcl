create_project -in_memory -part xc7z020clg400-1
read_verilog [glob *.v]
read_xdc timing.xdc
synth_design -top top -part xc7z020clg400-1
report_timing_summary -file timing.rpt
report_utilization -file util.rpt
