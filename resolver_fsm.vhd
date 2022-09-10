library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity resolver_fsm is
    generic(
        N : integer := 10
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
end entity resolver_fsm;

architecture rtl of resolver_fsm is
    type state_type is (none_state, upping_state, downing_state, urgent_in_upping_state, urgent_out_downing_state, reached_state);
    signal current_state : state_type;
    signal next_state    : state_type;

    signal none_is_pressed_s : std_logic;
    signal highest_dest_s    : unsigned(integer(ceil(log2(real(N)))) - 1 downto 0);
    signal lowest_dest_s     : unsigned(integer(ceil(log2(real(N)))) - 1 downto 0);

    component resolver_comb
        generic(
            N : integer
        );
        port(
            clk             : in  std_logic;
            ups             : in  std_logic_vector(N - 1 downto 0);
            downs           : in  std_logic_vector(N - 1 downto 0);
            buttons         : in  std_logic_vector(N - 1 downto 0);
            none_is_pressed : out std_logic;
            highest_dest    : out unsigned(integer(ceil(log2(real(N)))) - 1 downto 0);
            lowest_dest     : out unsigned(integer(ceil(log2(real(N)))) - 1 downto 0)
        );
    end component;

begin

    -- clk process
    clk_p : process(clk)
    begin
        if (rising_edge(clk)) then
            if (reset_n = '0') then
                --  i should put all the values in the state itself to avoid any multiple drivers
                current_state <= none_state; -- it goes to the ground floor

            else
                current_state <= next_state;

            end if;
        end if;
    end process;                        -- clk_p

    state_p : process(clk)
    begin
        case current_state is
            when none_state =>
                req <= (others => '1'); -- NONE VALUE FOR REQ 

                if (none_is_pressed_s <= '0') then
                    if (highest_dest_s > unsigned(floor)) then
                        next_state <= upping_state;
                    elsif (lowest_dest_s < unsigned(floor)) then
                        next_state <= downing_state;
                    end if;
                end if;

            when upping_state =>

                req <= std_logic_vector(highest_dest_s);
                if (buttons(to_integer(unsigned(floor))) = '0' or ups(to_integer(unsigned(floor))) = '0') then
                    next_state <= urgent_in_upping_state;
                end if;

            when urgent_in_upping_state =>
                req <= floor;
                -- wait untill he opens the dooe then change the req
                if (door_open = '1') then
                    next_state <= upping_state;
                end if;

            when downing_state =>
                req <= std_logic_vector(lowest_dest_s);
                if (buttons(to_integer(unsigned(floor))) = '0' or downs(to_integer(unsigned(floor))) = '0') then
                    next_state <= urgent_out_downing_state;
                end if;
            when urgent_out_downing_state =>
                req <= floor;
                -- wait untill he opens the dooe then change the req
                if (door_open = '1') then
                    next_state <= downing_state;
                end if;

            when reached_state =>
                null;
        end case;
    end process;                        -- state_p

    U1 : resolver_comb
        generic map(
            N => N
        )
        port map(
            clk             => clk,
            ups             => ups,
            downs           => downs,
            buttons         => buttons,
            none_is_pressed => none_is_pressed_s,
            highest_dest    => highest_dest_s,
            lowest_dest     => lowest_dest_s
        );

end architecture;
