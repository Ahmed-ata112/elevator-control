library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity elevator_ctrl_tb is
end;

architecture bench of elevator_ctrl_tb is

    component elevator_ctrl
        generic(
            N : integer
        );
        port(
            clk       : in  std_logic;
            reset_n   : in  std_logic;
            req_i     : in  std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0);
            mv_up     : out std_logic;
            mv_down   : out std_logic;
            door_open : out std_logic;
            floor     : out std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0)
        );
    end component;

    -- Clock period
    constant clk_period : time    := 10 ns;
    -- Generics
    constant N          : integer := 10;
    constant FREQUENCY  : integer := 20;

    -- Ports
    signal clk       : std_logic;
    signal reset_n   : std_logic;
    signal req_i     : std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0);
    signal mv_up     : std_logic;
    signal mv_down   : std_logic;
    signal door_open : std_logic;
    signal floor     : std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0);

    type state_type is (preparing_state, not_working_state, go_up_state, go_down_state, door_open_state);
    alias state_out is << signal .elevator_ctrl_tb.elevator_ctrl_inst.current_state : state_type >>;
    alias counter_out is << signal .elevator_ctrl_tb.elevator_ctrl_inst.counter   : unsigned(15 downto 0) >>;
begin

    elevator_ctrl_inst : elevator_ctrl
        generic map(
            N => N
        )
        port map(
            clk       => clk,
            reset_n   => reset_n,
            req_i     => req_i,
            mv_up     => mv_up,
            mv_down   => mv_down,
            door_open => door_open,
            floor     => floor
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process clk_process;

    teest_it : process
    begin
        reset_n <= '0';
        req_i   <= ((others => '0'));
        wait for clk_period;
        reset_n <= '1';
        req_i   <= X"4";
        wait for clk_period * FREQUENCY * 2.5; -- 2.5 secs
        assert mv_up = '1' report "NO mov_up = " & to_string(mv_up) & LF;
        assert mv_down = '0' report "NO mov_down = " & to_string(mv_down) & LF;
        assert floor = "0001" report "NO floor = " & to_string(floor) & LF;
        assert state_out = go_up_state report "NO State = " & to_string(state_out) & LF;

        wait for clk_period * FREQUENCY * 6.5; -- 6.5 secs
        assert door_open = '1' report "NO door_open = " & to_string(door_open) & LF;

        wait;

    end process;                        -- teest_it

end;
