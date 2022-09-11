-- 2 modules should exist in here 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity top_module is
    generic(
        N : integer := 4
    );
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        ups       : in  std_logic_vector(N - 1 downto 0);
        downs     : in  std_logic_vector(N - 1 downto 0);
        bn        : in  std_logic_vector(N - 1 downto 0);
        mv_up     : out std_logic;
        mv_dn     : out std_logic;
        door_open : out std_logic;
        floor     : out std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0);
        HEX0      : out std_logic_vector(6 downto 0)
    );
end;

architecture bench of top_module is

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
            N        : integer;
            clk_freq : integer
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
    component ssd
        port(
            in_decoder  : in  std_logic_vector(4 - 1 downto 0);
            out_decoder : out std_logic_vector(7 - 1 downto 0)
        );
    end component;

    signal mv_up_s     : std_logic;
    signal mv_down_s   : std_logic;
    signal door_open_s : std_logic;
    signal floor_s     : std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0);
    signal req_s       : std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0);

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
            buttons   => bn,
            mv_up     => mv_up_s,
            mv_down   => mv_down_s,
            door_open => door_open_s,
            floor     => floor_s,
            req       => req_s
        );

    elevator_ctrl_inst : component elevator_ctrl
        generic map(
            N        => N,
            clk_freq => 50_000_000
        )
        port map(
            clk       => clk,
            reset_n   => reset_n,
            req_i     => req_s,
            mv_up     => mv_up_s,
            mv_down   => mv_down_s,
            door_open => door_open_s,
            floor     => floor_s
        );
    mv_up     <= mv_up_s;
    mv_dn     <= mv_down_s;
    door_open <= door_open_s;
    floor     <= floor_s;

    ssd_inst : ssd
        port map(
            in_decoder  => "00" & floor_s,
            out_decoder => HEX0
        );
end bench;
