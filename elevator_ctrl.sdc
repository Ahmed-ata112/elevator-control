# onlt one Constraint on the clk to be 50MHz
set_time_format -unit ns -decimal_places 3
create_clock -name {clk} -period 20.000 [get_ports {clk}]

