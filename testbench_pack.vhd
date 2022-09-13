library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package testbench_pack is

    procedure assert_floor_and_door(floor_s     : std_logic_vector;
                                    door_s      : std_logic;
                                    floor_value : std_logic_vector;
                                    door_value  : std_logic);
end package;

package body testbench_pack is
    procedure assert_floor_and_door(floor_s     : std_logic_vector;
                                    door_s      : std_logic;
                                    floor_value : std_logic_vector;
                                    door_value  : std_logic) is
    begin
        assert door_s = door_value report "At Time: " & time'image(now) & " ,door_open should have been " & to_string(door_value) severity error;
        assert floor_s = floor_value report "At Time: " & time'image(now) & " ,floor should be " & to_hstring(floor_value) & " but was found " & to_hstring(floor_s) severity error;

    end assert_floor_and_door;
end package body;
