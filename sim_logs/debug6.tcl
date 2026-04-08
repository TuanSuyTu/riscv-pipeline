run 100ns
puts "=== AT 100ns ==="
puts "reg_write_id=[get_value /tb_top/uut/reg_write_id]"
puts "reg_write_ex=[get_value /tb_top/uut/reg_write_ex]"
puts "reg_write_mem=[get_value /tb_top/uut/reg_write_mem]"
puts "reg_write_m2=[get_value /tb_top/uut/reg_write_m2]"
puts "reg_write_wb=[get_value /tb_top/uut/reg_write_wb]"
puts "stall=[get_value /tb_top/uut/stall]"
puts "pc_if=[get_value /tb_top/uut/pc_if]"
run 10ns
puts "=== AT 110ns ==="
puts "reg_write_id=[get_value /tb_top/uut/reg_write_id]"
puts "reg_write_ex=[get_value /tb_top/uut/reg_write_ex]"
puts "reg_write_mem=[get_value /tb_top/uut/reg_write_mem]"
puts "reg_write_m2=[get_value /tb_top/uut/reg_write_m2]"
puts "reg_write_wb=[get_value /tb_top/uut/reg_write_wb]"
puts "stall=[get_value /tb_top/uut/stall]"
puts "pc_if=[get_value /tb_top/uut/pc_if]"
exit
