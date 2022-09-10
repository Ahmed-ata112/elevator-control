force -freeze sim:/elevator_ctrl/clk 1 0, 0 {5 ns} -r 10
force -freeze sim:/elevator_ctrl/reset_n 0 0 -cancel 10
force -freeze sim:/elevator_ctrl/req_i 5'h0f 0