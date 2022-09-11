-- 2 modules should exist in here 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity top_module is
    generic(
        N : integer := 10
    );
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        ups     : in  std_logic_vector(N - 1 downto 0);
        downs   : in  std_logic_vector(N - 1 downto 0);
        buttons : in  std_logic_vector(N - 1 downto 0);
        up      : out std_logic;
        down    : out std_logic;
        door     : out std_logic;
        floor   : out std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0)
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

    -- Ports
    -- signal clk       : std_logic;
    -- signal reset_n   : std_logic;
    -- signal ups       : std_logic_vector(N - 1 downto 0);
    -- signal downs     : std_logic_vector(N - 1 downto 0);
    -- signal buttons   : std_logic_vector(N - 1 downto 0);
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
        buttons   => buttons,
        mv_up     => mv_up_s,
        mv_down   => mv_down_s,
        door_open => door_open_s,
        floor     => floor_s,
        req       => req_s
    );

elevator_ctrl_inst : component elevator_ctrl
    generic map(
        N => N
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
    up    <= mv_up_s;
    down  <= mv_down_s;
    door   <= door_open_s;    
    floor <=  floor_s;  
    
end bench;
