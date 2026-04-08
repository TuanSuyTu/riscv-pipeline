run 51ns
puts "=== 51ns (1ns after posedge, combo settled) ==="
puts "imm_ex=[get_value /tb_top/uut/imm_ex]"
puts "alu_src_ex=[get_value /tb_top/uut/alu_src_ex]"
puts "alu_in_a=[get_value /tb_top/uut/alu_in_a]"
puts "alu_in_b=[get_value /tb_top/uut/alu_in_b]"
puts "alu_ctrl=[get_value /tb_top/uut/alu_ctrl]"
puts "alu_result_ex=[get_value /tb_top/uut/alu_result_ex]"
puts "rd_addr_ex=[get_value /tb_top/uut/rd_addr_ex]"
puts "forward_a=[get_value /tb_top/uut/forward_a]"
puts "forward_b=[get_value /tb_top/uut/forward_b]"
puts "lui_ex=[get_value /tb_top/uut/lui_ex]"
puts "auipc_ex=[get_value /tb_top/uut/auipc_ex]"
exit
