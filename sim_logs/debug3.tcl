run 50ns
for {set i 0} { < 20} {incr i} {
  puts [format "t=%0t rw_wb=%b rd_wb=%02d wd=%08h | rw_m2=%b rd_m2=%02d | rw_mem=%b rd_mem=%02d alu_mem=%08h" \
    [current_time] \
    [get_value /tb_top/uut/reg_write_wb] \
    [get_value /tb_top/uut/rd_addr_wb] \
    [get_value /tb_top/uut/wd_data_wb] \
    [get_value /tb_top/uut/reg_write_m2] \
    [get_value /tb_top/uut/rd_addr_m2] \
    [get_value /tb_top/uut/reg_write_mem] \
    [get_value /tb_top/uut/rd_addr_mem] \
    [get_value /tb_top/uut/alu_result_mem] ]
  run 10ns
}
exit
