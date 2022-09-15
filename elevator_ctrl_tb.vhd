library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
use work.testbench_pack.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use std.env.stop;
entity elevator_ctrl_tb is
end;

architecture bench of elevator_ctrl_tb is

    component resolver_fsm
        generic(
            N : integer
        );
        port(
            clk       : in  std_logic;
            reset_n   : in  std_logic;
            ups       : in  std_logic_vector(N - 1 downto 0);
            downs     : in  std_logic_vector(N - 1 downto 0);
            buttons   : in  std_logic_vector(N - 1 downto 0);
            mv_up     : in  std_logic;
            mv_down   : in  std_logic;
            door_open : in  std_logic;
            floor     : in  std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0);
            req       : out std_logic_vector(integer(ceil(log2(real(N)))) downto 0)
        );
    end component;

    component unit_control
        generic(
            N        : integer;
            clk_freq : integer
        );
        port(
            clk       : in  std_logic;
            reset_n   : in  std_logic;
            req_i     : in  std_logic_vector(integer(ceil(log2(real(N)))) downto 0);
            mv_up     : out std_logic;
            mv_down   : out std_logic;
            door_open : out std_logic;
            floor     : out std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0)
        );
    end component;

    -- Clock period
    -- 10 ns => 1 sec in real time
    constant clk_period : time    := 10 ns;
    constant clk_freq   : integer := 100;

    -- Generics
    constant N : integer := 10;

    -- Ports
    signal clk       : std_logic;
    signal reset_n   : std_logic;
    signal ups       : std_logic_vector(N - 1 downto 0);
    signal downs     : std_logic_vector(N - 1 downto 0);
    signal buttons   : std_logic_vector(N - 1 downto 0);
    signal mv_up     : std_logic;
    signal mv_down   : std_logic;
    signal door_open : std_logic;
    signal floor_s   : std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0);
    signal req_s     : std_logic_vector(integer(ceil(log2(real(N)))) downto 0);

    type state_type is (going_to_valid_place_state, not_working_state, go_up_state, go_down_state, door_open_state);
    alias state_out is << signal .elevator_ctrl_tb.control_unit_inst.current_state : state_type >>;

begin

    resolver_fsm_inst : resolver_fsm
        generic map(
            N => N
        )
        port map(
            clk       => clk,
            reset_n   => reset_n,
            ups       => ups,
            downs     => downs,
            buttons   => buttons,
            mv_up     => mv_up,
            mv_down   => mv_down,
            door_open => door_open,
            floor     => floor_s,
            req       => req_s
        );

    control_unit_inst : component unit_control
        generic map(
            N        => N,
            clk_freq => clk_freq
        )
        port map(
            clk       => clk,
            reset_n   => reset_n,
            req_i     => req_s,
            mv_up     => mv_up,
            mv_down   => mv_down,
            door_open => door_open,
            floor     => floor_s
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process clk_process;

    floor_log_io : process
        File floor_log_file   : text open write_mode is "floorLog.txt";
        alias ups_r is << signal .elevator_ctrl_tb.resolver_fsm_inst.ups_r : std_logic_vector(N - 1 downto 0)  >>;
        alias downs_r is << signal .elevator_ctrl_tb.resolver_fsm_inst.downs_r : std_logic_vector(N - 1 downto 0)  >>;
        alias buttons_r is << signal .elevator_ctrl_tb.resolver_fsm_inst.buttons_r : std_logic_vector(N - 1 downto 0)  >>;
        variable current_REGS : std_logic_vector(N - 1 downto 0);
    begin
        wait on floor_s;
        current_REGS := ups_r and downs_r and buttons_r;
        write(floor_log_file, to_string(now, ns) & " : " & "combined requests are " & to_string(current_REGS) & LF);
        write(floor_log_file, to_string(now, ns) & " : " & "ups requests are " & to_string(ups) & LF);
        write(floor_log_file, to_string(now, ns) & " : " & "downs requests are " & to_string(downs) & LF);
        write(floor_log_file, to_string(now, ns) & " : " & "buttons requests are " & to_string(buttons_r) & LF);

        if mv_up then
            write(floor_log_file, "elevator is moving up to floor " & to_hstring(floor_s) & LF);
        elsif mv_down then
            write(floor_log_file, "elevator is moving down to floor " & to_hstring(floor_s) & LF);
        end if;

        write(floor_log_file, "===================-------------===================" & LF);

    end process;                        -- floor_log_io

    p1 : process
    begin
        report to_string(clk_freq);
        reset_n <= '0';
        ups     <= (others => '1');
        downs   <= (others => '1');
        buttons <= (others => '1');

        wait for clk_period;
        -- this happens at the falling edge of the clock
        reset_n <= '1';
        wait for clk_period * clk_freq * 3; --simulates a 3 sec
        ups     <= (2 => '0', others => '1'); -- request floor 2

        --run for 4.5 Seconds
        wait for clk_period * clk_freq * 4.5;
        report "BLOCK 1, CHECK time is " & to_string(now, ns);
        assert_floor_and_door(floor_s, door_open, x"2", '1');

        wait for clk_period * clk_freq * 2.5;
        -- the ups are still pressed so it stayed at floor 2 
        report "BLOCK 2, CHECK time is " & to_string(now, ns);
        assert_floor_and_door(floor_s, door_open, x"2", '1');
        ups <= (others => '1');         -- clear the buttons

        wait for clk_period * clk_freq * 4;
        report "BLOCK 3, CHECK time is " & to_string(now, ns);
        assert_floor_and_door(floor_s, door_open, x"2", '0');
        ups <= (others => '1');         -- clear requests

        wait for clk_period * clk_freq * 4; -- wait in the not working state for a couple of seconds
        report "BLOCK 4, CHECK time is " & to_string(now, ns);
        assert_floor_and_door(floor_s, door_open, x"2", '0');
        assert mv_up = '0' report "At Time: " & to_string(now, ns) & " ,mv_up should have stayed 0" severity error;
        assert mv_down = '0' report "At Time: " & to_string(now, ns) & " ,mv_down should have stayed 0" severity error;
        assert state_out = not_working_state report "At Time: " & to_string(now, ns) & " ,state should have stayed not_working_state but was found " & to_string(state_out) severity error;

        wait for clk_period * clk_freq; -- after 1 second
        ups <= (4 => '0', 8 => '0', others => '1'); -- pressed floor 4 and 8

        wait for clk_period * clk_freq; -- after 1 seconds
        ups <= (others => '1');         -- release all ups

        -- after 4.5 seconds , it should have reached the 4th floor and opend the door
        wait for clk_period * clk_freq * 3.5;
        report "BLOCK 5, CHECK time is " & to_string(now, ns);
        assert_floor_and_door(floor_s, door_open, x"4", '1');
        buttons <= (9 => '0', 0 => '0', others => '1'); -- pressed the buttons and request floor 9 and 0 

        -- NOTE: IT WONT change its direction until it reaches the 9th floor
        -- within 6 seconds , DOOR closed and then it should have reached the 8th floor and opend the door
        wait for clk_period * clk_freq * 10;
        buttons <= (others => '1');
        report "BLOCK 6, CHECK time is " & to_string(now, ns);
        assert_floor_and_door(floor_s, door_open, x"8", '1');

        -- within 6 seconds , DOOR closed and then it should have reached the 8th floor and opend the door
        wait for clk_period * clk_freq * 4;
        report "BLOCK 7, CHECK time is " & to_string(now, ns);
        assert_floor_and_door(floor_s, door_open, x"9", '1');
        -- TEST: gowing down with buttons pressed 
        ups   <= (1 => '0', others => '1');
        downs <= (7 => '0', others => '1');

        wait for clk_period * clk_freq * 1; -- pressed 1 sec
        ups   <= (others => '1');
        downs <= (others => '1');

        wait for clk_period * clk_freq * 5;
        report "BLOCK 8, CHECK time is " & to_string(now, ns);
        assert_floor_and_door(floor_s, door_open, x"7", '1');

        wait for clk_period * clk_freq * 16;
        report "BLOCK 9, CHECK time is " & to_string(now, ns);
        assert_floor_and_door(floor_s, door_open, x"0", '1');

        wait for clk_period * clk_freq * 4; -- changed direction and went to the floor 1  and opened its Door
        report "BLOCK 10, CHECK time is " & to_string(now, ns);
        assert_floor_and_door(floor_s, door_open, x"1", '1');
        wait for clk_period * clk_freq * 10; -- 5 SECs

        report "BLOCK 11, CHECK time is " & to_string(now, ns);
        downs <= (7 => '0', others => '1');

        wait for clk_period * clk_freq * 1.5;
        report "BLOCK 12, CHECK time is " & to_string(now, ns);
        downs   <= (others => '1');
        reset_n <= '0';

        wait for clk_period * clk_freq * 6;
        report "BLOCK 13, CHECK time is " & to_string(now, ns);
        assert_floor_and_door(floor_s, door_open, x"2", '0');
        reset_n <= '1';

        wait for clk_period * clk_freq * 10.5;
        report "BLOCK 14, CHECK time is " & to_string(now, ns);
        assert_floor_and_door(floor_s, door_open, x"2", '0');
        downs <= (7 => '0', others => '1');
        wait for clk_period * clk_freq * 2; -- so the door closes
        downs <= (others => '1');

        wait for clk_period * clk_freq * 8.5; -- so the door closes
        report "BLOCK 15, CHECK time is " & to_string(now, ns);
        assert_floor_and_door(floor_s, door_open, x"7", '1');
        reset_n <= '0';
        wait for clk_period * clk_freq * 0.5;
        reset_n <= '1';
        wait for clk_period * clk_freq * 3;

        stop;
    end process;                        -- p1

end;
