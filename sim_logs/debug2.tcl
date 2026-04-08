log_vcd /tb_top/uut/reg_write_wb
log_vcd /tb_top/uut/rd_addr_wb
log_vcd /tb_top/uut/wd_data_wb
log_vcd /tb_top/uut/alu_result_wb
log_vcd /tb_top/uut/mem_to_reg_wb
log_vcd /tb_top/uut/reg_write_mem
run 200ns
exit
