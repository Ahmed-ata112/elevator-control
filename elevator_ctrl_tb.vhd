-- 2 modules should exist in here 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
use std.env.stop;
entity resolver_fsm_tb is
end;

architecture bench of resolver_fsm_tb is

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

    component elevator_ctrl
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
    -- 1 ms => 1 sec in real time
    constant clk_period : time    := 10 ns;
    constant clk_freq   : integer := 100;
    -- constant clk_period : time    := 20 ns;
    -- constant clk_freq   : integer := 50_000_000;

    -- Generics
    constant N : integer := 4;

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
    signal req       : std_logic_vector(integer(ceil(log2(real(N)))) downto 0);

    type state_type is (preparing_state, not_working_state, go_up_state, go_down_state, door_open_state);
    alias state_out is << signal .resolver_fsm_tb.elevator_ctrl_inst.current_state : state_type >>;

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
            req       => req
        );

    elevator_ctrl_inst : component elevator_ctrl
        generic map(
            N        => N,
            clk_freq => clk_freq
        )
        port map(
            clk       => clk,
            reset_n   => reset_n,
            req_i     => req,
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

        ups <= (2 => '0', others => '1'); -- request floor 2

        --run for 4.5 Seconds
        -- 
        wait for clk_period * clk_freq * 4.5;
        report "BLOCK 1, CHECK time is " & time'image(now);

        -- assert floor_s = x"2" report "At Time: " & time'image(now) & " ,floor should be 2 but was found " & to_hstring(floor_s) severity error;
        assert door_open = '1' report "At Time: " & time'image(now) & " ,door should be open but was found closed" severity error;

        wait for clk_period * clk_freq * 2.5;
        -- the ups are still pressed so it stayed at floor 2 
        report "BLOCK 2, CHECK time is " & time'image(now);
        -- assert floor_s = x"2" report "At Time: " & time'image(now) & " ,floor should be 2 but was found " & to_hstring(floor_s) severity error;
        assert door_open = '1' report "At Time: " & time'image(now) & " ,foor should have stayed OPEN" severity error;
        ups <= (others => '1');         -- clear the buttons

        wait for clk_period * clk_freq * 4;
        report "BLOCK 3, CHECK time is " & time'image(now);

        -- assert floor_s = x"2" report "At Time: " & time'image(now) & " ,floor should be 2 but was found " & to_hstring(floor_s) severity error;
        assert door_open = '0' report "At Time: " & time'image(now) & " ,Door should have stayed Closed" severity error;
        ups <= (others => '1');         -- clear requests

        wait for clk_period * clk_freq * 4; -- wait in the not working state for a couple of seconds

        report "BLOCK 4, CHECK time is " & time'image(now);
        -- assert floor_s = x"2" report "At Time: " & time'image(now) & " ,floor should be 2 but was found " & to_hstring(floor_s) severity error;
        assert door_open = '0' report "At Time: " & time'image(now) & " ,Door should have stayed Closed" severity error;
        assert mv_up = '0' report "At Time: " & time'image(now) & " ,mv_up should have stayed 0" severity error;
        assert mv_down = '0' report "At Time: " & time'image(now) & " ,mv_down should have stayed 0" severity error;
        assert state_out = not_working_state report "At Time: " & time'image(now) & " ,state should have stayed not_working_state but was found " & to_string(state_out) severity error;
        wait;
    end process;                        -- p1
end;
