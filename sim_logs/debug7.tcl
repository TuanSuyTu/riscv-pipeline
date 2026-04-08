run 200ns
puts "=== SNAPSHOT AT 200ns ==="
for {set i 1} { <= 15} {incr i} {
  puts "x=[get_value /tb_top/uut/regfile_inst/regs()]"
}
exit
