-- 2 modules should exist in here 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

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
            req       : out std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0)
        );
    end component;

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

    -- Ports
    signal clk       : std_logic;
    signal reset_n   : std_logic;
    signal ups       : std_logic_vector(N - 1 downto 0);
    signal downs     : std_logic_vector(N - 1 downto 0);
    signal buttons   : std_logic_vector(N - 1 downto 0);
    signal mv_up     : std_logic;
    signal mv_down   : std_logic;
    signal door_open : std_logic;
    signal floor     : std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0);
    signal req       : std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0);

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
            floor     => floor,
            req       => req
        );

    elevator_ctrl_inst : component elevator_ctrl
        generic map(
            N => N
        )
        port map(
            clk       => clk,
            reset_n   => reset_n,
            req_i     => req,
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

    p1 : process
    begin
        reset_n <= '0';
        ups     <= (others => '1');
        downs   <= (others => '1');
        buttons <= (others => '1');
        wait for clk_period;
        reset_n <= '1';
        wait for clk_period;
        wait;
    end process;                        -- p1
end;
