add wave -position insertpoint  \
sim:/elevator_ctrl/clk \
sim:/elevator_ctrl/door_open \
sim:/elevator_ctrl/floor \
sim:/elevator_ctrl/mv_down \
sim:/elevator_ctrl/mv_up \
sim:/elevator_ctrl/N \
sim:/elevator_ctrl/req_i \
sim:/elevator_ctrl/reset_n
add wave -position end  sim:/elevator_ctrl/counter
add wave -position end  sim:/elevator_ctrl/roll_s
add wave -position end  sim:/elevator_ctrl/current_state
force -freeze sim:/elevator_ctrl/clk 1 0, 0 {5 ns} -r 10
force -freeze sim:/elevator_ctrl/reset_n 0 0 -cancel 10
force -freeze sim:/elevator_ctrl/req_i 5'h04 0