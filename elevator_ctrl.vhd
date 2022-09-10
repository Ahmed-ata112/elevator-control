library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
entity elevator_ctrl is
    generic(
        N : integer := 10
    );
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        req_i     : in  std_logic_vector(integer(ceil(log2(real(N)))) downto 0);
        mv_up     : out std_logic;
        mv_down   : out std_logic;
        door_open : out std_logic;
        floor     : out std_logic_vector(integer(ceil(log2(real(N)))) downto 0)
        -- 4 bits is enough for 10 floors 
    );
end entity;

architecture rtl of elevator_ctrl is
    type state_type is (preparing_state, not_working_state, go_up_state, go_down_state, door_open_state);
    signal current_state : state_type;
    signal next_state    : state_type;

    --- timer  signals
    signal timer_reset  : std_logic;
    signal roll_s       : std_logic;
    signal add_or_sub_s : std_logic := ('0');
    signal counter      : unsigned(15 downto 0);

    -- registers for output
    signal mv_up_r   : std_logic := ('0');
    signal mv_down_r : std_logic := ('0');

    signal door_open_r : std_logic := ('0');

    -- signals before those regs
    signal mv_up_s     : std_logic;
    signal mv_down_s   : std_logic;
    signal door_open_s : std_logic;
    signal floor_s     : unsigned(integer(ceil(log2(real(N)))) downto 0) := (others => '0');

    component one_sec_timer
        port(
            fast_Clk     : in  std_logic;
            reset        : in  std_logic;
            -- roll_out     : out std_logic;
            slow_counter : out unsigned(15 downto 0)
        );
    end component;
    component floor_counter
        generic(
            n : natural;
            k : integer
        );
        port(
            clock      : in  std_logic;
            reset_n    : in  std_logic;
            clk_enable : in  std_logic;
            add_or_sub : in  std_logic;
            Q          : out unsigned(n - 1 downto 0)
        );
    end component;

begin
    -- clk process
    process(clk)
    begin
        if (rising_edge(clk)) then
            if (reset_n = '0') then
                --  i should put all the values in the state itself to avoid any multiple drivers
                current_state <= preparing_state; -- it goes to the ground floor

            else
                current_state <= next_state;

                -- register Output
                mv_up_r     <= mv_up_s;
                mv_down_r   <= mv_down_s;
                door_open_r <= door_open_s;
            end if;
        end if;
    end process;

    state_transitions_process : process(door_open_r, current_state, mv_up_r, mv_down_r, counter, req_i, floor_s, roll_s)
    begin
        --default values
        mv_up_s     <= mv_up_r;
        mv_down_s   <= mv_down_r;
        door_open_s <= door_open_r;
        timer_reset <= '1';
        next_state  <= current_state;
        roll_s      <= '0';
        case current_state is

            when preparing_state =>
                -- it should stay here untill a valid  floor is reached
                -- it won't listen to the resolver until then

                if counter /= to_unsigned(1, 16) then
                    -- we are in a safe place now
                    timer_reset <= '0';
                    next_state  <= not_working_state;
                end if;

            when not_working_state =>
                -- Put it into the output process
                -- timer_reset <= '0';
                mv_up_s     <= '0';
                mv_down_s   <= '0';
                door_open_s <= '0';

                --counter remains zero
                timer_reset <= '0';

                if (unsigned(req_i) = floor_s) then
                    door_open_s <= '1';
                    next_state  <= door_open_state;
                elsif (unsigned(req_i) > floor_s) then
                    mv_up_s    <= '1';
                    next_state <= go_up_state;
                elsif (unsigned(req_i) < floor_s) then
                    mv_down_s  <= '1';
                    next_state <= go_down_state;

                end if;

            when go_up_state =>
                mv_up_s     <= '1';
                mv_down_s   <= '0';
                door_open_s <= '0';

                if (counter = to_unsigned(2, 16)) then
                    --advanced a floor
                    roll_s       <= '1';
                    add_or_sub_s <= '1';
                    -- zerozise the counter
                    timer_reset  <= '0';
                end if;
                -- TODo: a request with another number  
                if (unsigned(req_i) = floor_s) then
                    timer_reset <= '0';
                    door_open_s <= '1';
                    next_state  <= door_open_state;
                end if;

            when go_down_state =>
                mv_up_s     <= '0';
                mv_down_s   <= '1';
                door_open_s <= '0';

                if (counter = to_unsigned(2, 16)) then
                    --advanced a floor
                    roll_s       <= '1';
                    add_or_sub_s <= '0';
                    -- zerozise the counter
                    timer_reset  <= '0';

                end if;

                if (unsigned(req_i) = floor_s) then

                    timer_reset <= '0';
                    door_open_s <= '1';
                    next_state  <= door_open_state;
                end if;

            when door_open_state =>
                mv_up_s     <= '0';
                mv_down_s   <= '0';
                door_open_s <= '1';
                -- we should stay here as long as the door is open then move to the not working
                if counter = to_unsigned(2, 16) then
                    door_open_s <= '0';

                    timer_reset <= '0';
                    next_state  <= not_working_state;

                end if;
        end case;

    end process;                        -- state_transitions_process

    U1 : one_sec_timer
        port map(
            fast_Clk     => clk,
            reset        => timer_reset,
            -- roll_out     => roll_s,
            slow_counter => counter
        );

    floor_counter_inst : component floor_counter
        generic map(
            n => integer(ceil(log2(real(N)))) + 1,
            k => N
        )
        port map(
            clock      => clk,
            reset_n    => reset_n,
            clk_enable => roll_s,
            add_or_sub => add_or_sub_s,
            Q          => floor_s
        );

    mv_up     <= mv_up_r;
    mv_down   <= mv_down_r;
    door_open <= door_open_r;
    floor     <= std_logic_vector(floor_s);
end architecture;
