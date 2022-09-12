onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /resolver_fsm_tb/reset_n
add wave -noupdate /resolver_fsm_tb/clk
add wave -noupdate -divider OUT
add wave -noupdate /resolver_fsm_tb/req
add wave -noupdate /resolver_fsm_tb/door_open
add wave -noupdate /resolver_fsm_tb/floor
add wave -noupdate /resolver_fsm_tb/mv_down
add wave -noupdate /resolver_fsm_tb/mv_up
add wave -noupdate -divider buttons
add wave -noupdate -radix binary /resolver_fsm_tb/ups
add wave -noupdate -radix binary /resolver_fsm_tb/buttons
add wave -noupdate -radix binary /resolver_fsm_tb/downs
add wave -noupdate -divider STATES
add wave -noupdate /resolver_fsm_tb/resolver_fsm_inst/current_state
add wave -noupdate /resolver_fsm_tb/elevator_ctrl_inst/current_state
add wave -noupdate -divider {REG OF BUTTONS}
add wave -noupdate -radix binary /resolver_fsm_tb/resolver_fsm_inst/buttons_r
add wave -noupdate -radix binary /resolver_fsm_tb/resolver_fsm_inst/ups_r
add wave -noupdate -radix binary /resolver_fsm_tb/resolver_fsm_inst/downs_r
add wave -noupdate /resolver_fsm_tb/resolver_fsm_inst/highest_dest_s
add wave -noupdate /resolver_fsm_tb/resolver_fsm_inst/lowest_dest_s
add wave -noupdate /resolver_fsm_tb/resolver_fsm_inst/none_is_pressed_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3132 ns} 0} {{Cursor 2} {18920 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 310
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {3034 ns} {3209 ns}
