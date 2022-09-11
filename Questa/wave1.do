onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /resolver_fsm_tb/reset_n
add wave -noupdate /resolver_fsm_tb/buttons
add wave -noupdate /resolver_fsm_tb/clk
add wave -noupdate /resolver_fsm_tb/door_open
add wave -noupdate /resolver_fsm_tb/floor
add wave -noupdate /resolver_fsm_tb/mv_down
add wave -noupdate /resolver_fsm_tb/mv_up
add wave -noupdate /resolver_fsm_tb/ups
add wave -noupdate /resolver_fsm_tb/downs
add wave -noupdate /resolver_fsm_tb/req
add wave -noupdate /resolver_fsm_tb/resolver_fsm_inst/current_state
add wave -noupdate /resolver_fsm_tb/elevator_ctrl_inst/current_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10458 ns} 0} {{Cursor 2} {4538 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 218
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
WaveRestoreZoom {0 ns} {94 ns}
