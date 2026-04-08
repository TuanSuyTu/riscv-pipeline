run 50ns
puts "=== 50ns ==="
puts "imm_ex=[get_value /tb_top/uut/imm_ex]"
puts "alu_src_ex=[get_value /tb_top/uut/alu_src_ex]"
puts "rd_addr_ex=[get_value /tb_top/uut/rd_addr_ex]"
puts "alu_result_ex=[get_value /tb_top/uut/alu_result_ex]"
run 5ns
puts "=== 55ns ==="
puts "imm_ex=[get_value /tb_top/uut/imm_ex]"
puts "alu_src_ex=[get_value /tb_top/uut/alu_src_ex]"
puts "rd_addr_ex=[get_value /tb_top/uut/rd_addr_ex]"
puts "alu_result_ex=[get_value /tb_top/uut/alu_result_ex]"
run 5ns
puts "=== 60ns ==="
puts "imm_ex=[get_value /tb_top/uut/imm_ex]"
puts "alu_src_ex=[get_value /tb_top/uut/alu_src_ex]"
puts "rd_addr_ex=[get_value /tb_top/uut/rd_addr_ex]"
puts "alu_result_ex=[get_value /tb_top/uut/alu_result_ex]"
puts "alu_in_a=[get_value /tb_top/uut/alu_in_a]"
puts "alu_in_b=[get_value /tb_top/uut/alu_in_b]"
exit
