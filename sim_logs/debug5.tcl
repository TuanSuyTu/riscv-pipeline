run 850ns
puts "=== AT 850ns (after RESET+80cyc) ==="
puts "reg_write_wb=[get_value /tb_top/uut/reg_write_wb]"
puts "rd_addr_wb=[get_value /tb_top/uut/rd_addr_wb]"
puts "wd_data_wb=[get_value /tb_top/uut/wd_data_wb]"
puts "alu_result_wb=[get_value /tb_top/uut/alu_result_wb]"
puts "mem_to_reg_wb=[get_value /tb_top/uut/mem_to_reg_wb]"
puts "regs_x1=[get_value /tb_top/uut/regfile_inst/regs(1)]"
puts "regs_x2=[get_value /tb_top/uut/regfile_inst/regs(2)]"
puts "regs_x3=[get_value /tb_top/uut/regfile_inst/regs(3)]"
exit
