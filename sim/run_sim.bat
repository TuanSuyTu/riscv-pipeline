set VIVADO=C:\Xilinx\Vivado\2022.2\bin

:: Create and enter simulation directory
if not exist sim_logs mkdir sim_logs
cd sim_logs

:: Compile RTL source files
echo Compiling RTL...
call %VIVADO%\xvlog ../rtl/alu.v ../rtl/control.v ../rtl/dmem.v ../rtl/forward.v ../rtl/hazard.v ../rtl/id_ex_reg.v ../rtl/if_id_reg.v ../rtl/ex_mem_reg.v ../rtl/mem_wb_reg.v ../rtl/imem.v ../rtl/imm_gen.v ../rtl/pc_reg.v ../rtl/regfile.v ../rtl/top.v

:: Compile testbench
echo Compiling Testbench...
call %VIVADO%\xvlog ../tb/tb_top.v

:: Elaborate design
echo Elaborating Design...
call %VIVADO%\xelab -debug typical -top tb_top -snapshot tb_top_snapshot

:: Run Simulation
echo Running Simulation...
call %VIVADO%\xsim tb_top_snapshot -R > sim_result.log
type sim_result.log

cd ..
echo Done.
exit /b 0
