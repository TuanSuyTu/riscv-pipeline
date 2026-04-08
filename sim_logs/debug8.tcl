run 55ns
puts "=== 55ns (RESET done, first instr fetched) ==="
puts "stall=[get_value /tb_top/uut/stall]"
puts "pc_if=[get_value /tb_top/uut/pc_if]"
puts "reg_write_id=[get_value /tb_top/uut/reg_write_id]"
run 60ns
puts "=== 115ns (ADDI should be near WB) ==="
puts "alu_result_wb=[get_value /tb_top/uut/alu_result_wb]"
puts "alu_result_m2=[get_value /tb_top/uut/alu_result_m2]"
puts "alu_result_mem=[get_value /tb_top/uut/alu_result_mem]"
puts "reg_write_wb=[get_value /tb_top/uut/reg_write_wb]"
puts "rd_addr_wb=[get_value /tb_top/uut/rd_addr_wb]"
puts "mem_to_reg_wb=[get_value /tb_top/uut/mem_to_reg_wb]"
exit
