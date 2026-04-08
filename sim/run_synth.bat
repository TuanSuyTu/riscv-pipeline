@echo off
set VIVADO=C:\Xilinx\Vivado\2022.2\bin\vivado.bat

echo Starting RTL Synthesis using Vivado CLI...
call %VIVADO% -mode batch -source synth.tcl -log synth.log -journal synth.jou

echo Synthesis attempt finished. Check synth_output/utilization.rpt and synth.log.
