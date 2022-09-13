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
        req       : out std_logic_vector(integer(ceil(log2(real(N)))) downto 0)
    );
end entity resolver_fsm;

architecture rtl of resolver_fsm is
    type state_type is (none_state, upping_state, downing_state, reached_a_floor);
    signal current_state : state_type;
    signal next_state    : state_type;
    constant NONE_REQ    : std_logic_vector(integer(ceil(log2(real(N)))) downto 0) := (others => '1');

    type came_from_type is (none, up, down);
    signal came_from_s : came_from_type;
    signal came_from_r : came_from_type;

    signal none_is_pressed_s : std_logic;
    signal highest_dest_s    : unsigned(integer(ceil(log2(real(N)))) - 1 downto 0);
    signal lowest_dest_s     : unsigned(integer(ceil(log2(real(N)))) - 1 downto 0);
    signal req_s             : std_logic_vector(integer(ceil(log2(real(N)))) downto 0) := NONE_REQ;
    signal ups_s             : std_logic_vector(N - 1 downto 0)                        := (others => '1');
    signal downs_s           : std_logic_vector(N - 1 downto 0)                        := (others => '1');
    signal buttons_s         : std_logic_vector(N - 1 downto 0)                        := (others => '1');
    signal req_r             : std_logic_vector(integer(ceil(log2(real(N)))) downto 0) := NONE_REQ;
    signal ups_r             : std_logic_vector(N - 1 downto 0)                        := (others => '1');
    signal downs_r           : std_logic_vector(N - 1 downto 0)                        := (others => '1');
    signal buttons_r         : std_logic_vector(N - 1 downto 0)                        := (others => '1');

    component resolver_comb
        generic(
            N : integer
        );
        port(
            clk             : in  std_logic;
            reset_n         : in  std_logic;
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
                current_state <= none_state; -- it goes to the ground floor

            else
                current_state <= next_state;
                came_from_r   <= came_from_s;
                req_r         <= req_s;
                ups_r         <= ups_s;
                downs_r       <= downs_s;
                buttons_r     <= buttons_s;
            end if;
        end if;
    end process;                        -- clk_p

    state_p : process(door_open, lowest_dest_s, current_state, downs, ups, floor, highest_dest_s, none_is_pressed_s, buttons, req_r, came_from_r, buttons_r, downs_r, ups_r)
    begin
        next_state  <= current_state;
        came_from_s <= came_from_r;
        req_s       <= req_r;

        ups_s     <= ups_r and ups;
        downs_s   <= downs_r and downs;
        buttons_s <= buttons_r and buttons;

        case current_state is
            when none_state =>
                req_s <= NONE_REQ;      -- NONE VALUE FOR REQ 

                -- when something is pressed and the door is closed
                -- TODO : make it more smart when deciding which direction to go
                -- NOTE: the current design enures than no starvation occurs and with no fairness
                if (none_is_pressed_s = '0' and door_open = '0') then
                    if (highest_dest_s > unsigned(floor)) then
                        next_state <= upping_state;
                    elsif (lowest_dest_s < unsigned(floor)) then
                        next_state <= downing_state;
                    else
                        next_state <= reached_a_floor;
                    end if;
                end if;

            when upping_state =>

                req_s <= '0' & std_logic_vector(highest_dest_s);
                if (std_logic_vector(highest_dest_s) = floor) then
                    came_from_s <= none; -- this is the end of the upping state
                    next_state  <= reached_a_floor;
                elsif (buttons_r(to_integer(unsigned(floor))) = '0' or ups_r(to_integer(unsigned(floor))) = '0') then
                    came_from_s <= up;  -- You should return to the downing state
                    next_state  <= reached_a_floor;
                end if;

            when downing_state =>

                req_s <= '0' & std_logic_vector(lowest_dest_s);

                if (std_logic_vector(lowest_dest_s) = floor) then
                    came_from_s <= none; -- this is the end of the downing state
                    next_state  <= reached_a_floor;
                elsif (buttons_r(to_integer(unsigned(floor))) = '0' or downs_r(to_integer(unsigned(floor))) = '0') then
                    came_from_s <= down; -- You should return to the downing state
                    next_state  <= reached_a_floor;
                end if;

            when reached_a_floor =>
                -- to see it the buttons are still pressed even after its reached the floor
                buttons_s(to_integer(unsigned(floor))) <= buttons(to_integer(unsigned(floor)));
                ups_s(to_integer(unsigned(floor)))     <= ups(to_integer(unsigned(floor)));
                downs_s(to_integer(unsigned(floor)))   <= downs(to_integer(unsigned(floor)));

                req_s <= '0' & floor;
                -- wait untill he opens the door then change the req to an appropriate value OR go to none_state
                if (door_open = '1') then
                    if (came_from_r = up) then
                        next_state <= upping_state;
                    elsif (came_from_r = down) then
                        next_state <= downing_state;
                    else                -- came_from_s = none
                        next_state <= none_state;
                    end if;
                end if;

        end case;
    end process;                        -- state_p

    U1 : resolver_comb
        generic map(
            N => N
        )
        port map(
            clk             => clk,
            reset_n         => reset_n,
            ups             => ups_r,
            downs           => downs_r,
            buttons         => buttons_r,
            none_is_pressed => none_is_pressed_s,
            highest_dest    => highest_dest_s,
            lowest_dest     => lowest_dest_s
        );

    req <= req_r;

end architecture;

