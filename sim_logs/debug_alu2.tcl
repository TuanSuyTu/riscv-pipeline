run 51ns
puts "=== Inside ALU at 51ns ==="
puts "alu.a=[get_value /tb_top/uut/alu_inst/a]"
puts "alu.b=[get_value /tb_top/uut/alu_inst/b]"
puts "alu.alu_ctrl=[get_value /tb_top/uut/alu_inst/alu_ctrl]"
puts "alu.result=[get_value /tb_top/uut/alu_inst/result]"
puts "alu.zero=[get_value /tb_top/uut/alu_inst/zero]"
exit
