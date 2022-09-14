library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
entity elevator_ctrl is
    generic(
        N        : integer := 10;
        clk_freq : integer := 50_000_000
    );
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        req_i     : in  std_logic_vector(integer(ceil(log2(real(N)))) downto 0);
        mv_up     : out std_logic;
        mv_down   : out std_logic;
        door_open : out std_logic;
        floor     : out std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0)
        -- 4 bits is enough for 10 floors 
    );
end entity;

architecture rtl of elevator_ctrl is
    type state_type is (going_to_valid_place_state, not_working_state, go_up_state, go_down_state, door_open_state);
    signal current_state : state_type;
    signal next_state    : state_type;

    --- timer  signals
    signal timer_reset          : std_logic;
    signal floor_counter_enable : std_logic;
    signal roll_s               : std_logic;
    signal add_or_sub_s         : std_logic := ('0');

    -- registers for output
    signal mv_up_r     : std_logic := ('0');
    signal mv_down_r   : std_logic := ('0');
    signal door_open_r : std_logic := ('0');

    -- signals before those regs
    signal mv_up_s     : std_logic;
    signal mv_down_s   : std_logic;
    signal door_open_s : std_logic;
    signal floor_s     : unsigned(integer(ceil(log2(real(N)))) - 1 downto 0)     := (others => '0');
    constant NONE_REQ  : std_logic_vector(integer(ceil(log2(real(N)))) downto 0) := (others => '1');

    component one_sec_timer
        generic(
            clk_freq : integer
        );
        port(
            fast_Clk : in  std_logic;
            reset    : in  std_logic;
            roll_out : out std_logic
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
                if (mv_up_s = '1' or mv_down_s = '1' or door_open_s = '1') then
                    current_state <= going_to_valid_place_state; -- it goes to the ground floor
                else
                    current_state <= not_working_state; -- it goes to the ground floor
                    mv_up_r       <= '0';
                    mv_down_r     <= '0';
                    door_open_r   <= '0';
                end if;
            else
                current_state <= next_state;

                -- register Output
                mv_up_r     <= mv_up_s;
                mv_down_r   <= mv_down_s;
                door_open_r <= door_open_s;
            end if;
        end if;
    end process;

    state_transitions_process : process(door_open_r, current_state, mv_up_r, mv_down_r, req_i, floor_s, roll_s)
    begin
        --default values
        mv_up_s              <= mv_up_r;
        mv_down_s            <= mv_down_r;
        door_open_s          <= door_open_r;
        timer_reset          <= '1';
        next_state           <= current_state;
        floor_counter_enable <= '0';
        add_or_sub_s         <= '0';
        case current_state is

            when going_to_valid_place_state =>

                -- we are in a safe place now
                -- timer_reset <= '0';

                -- it should stay here untill a valid  floor is reached
                -- it won't listen to the resolver until then
                if roll_s = '1' then
                    next_state <= not_working_state;
                    if mv_up_r = '1' then
                        --add the floor
                        floor_counter_enable <= '1';
                        add_or_sub_s         <= '1';
                        mv_up_s              <= '0';
                    elsif mv_down_r = '1' then
                        -- decrease the floor
                        floor_counter_enable <= '1';
                        add_or_sub_s         <= '0';
                        mv_down_s            <= '0';
                    elsif door_open_r = '1' then
                        -- close the door
                        door_open_s <= '0';
                    end if;
                end if;

            when not_working_state =>
                -- Put it into the output process
                mv_up_s     <= '0';
                mv_down_s   <= '0';
                door_open_s <= '0';

                --counter remains zero
                timer_reset <= '0';

                if (req_i /= NONE_REQ) then
                    if (unsigned(req_i) = ('0' & floor_s)) then
                        next_state <= door_open_state;
                    elsif (unsigned(req_i) > ('0' & floor_s)) then
                        next_state <= go_up_state;
                    elsif (unsigned(req_i) < ('0' & floor_s)) then
                        next_state <= go_down_state;
                    end if;
                end if;

            when go_up_state =>
                mv_up_s     <= '1';
                mv_down_s   <= '0';
                door_open_s <= '0';

                if (roll_s = '1') then  -- 2 sec passed
                    --advanced a floor
                    floor_counter_enable <= '1';
                    add_or_sub_s         <= '1';

                    if (unsigned(req_i) < ('0' & floor_s)) then
                        next_state <= go_down_state;
                    end if;
                end if;

                -- TODO : it will the resolver duty to ensure that no req changes on the edges 
                if (unsigned(req_i) = ('0' & floor_s)) then
                    next_state <= door_open_state;
                end if;

            when go_down_state =>
                mv_up_s     <= '0';
                mv_down_s   <= '1';
                door_open_s <= '0';
                -- at the edge of a time step
                if (roll_s = '1') then
                    --advanced a floor
                    floor_counter_enable <= '1';
                    add_or_sub_s         <= '0';

                    if (unsigned(req_i) > (('0' & floor_s))) then

                        next_state <= go_up_state;

                    end if;
                end if;

                if (unsigned(req_i) = (('0' & floor_s))) then
                    next_state <= door_open_state;
                end if;

            when door_open_state =>
                mv_up_s     <= '0';
                mv_down_s   <= '0';
                door_open_s <= '1';
                -- we should stay here as long as the door is open then move to the not working
                if roll_s = '1' then
                    next_state <= not_working_state;

                end if;
        end case;

    end process;                        -- state_transitions_process

    U1 : one_sec_timer
        generic map(
            clk_freq => clk_freq
        )
        port map(
            fast_Clk => clk,
            reset    => timer_reset,
            roll_out => roll_s
        );

    floor_counter_inst : component floor_counter
        generic map(
            n => integer(ceil(log2(real(N)))),
            k => N
        )
        port map(
            clock      => clk,
            reset_n    => '1',          --its always working
            clk_enable => floor_counter_enable,
            add_or_sub => add_or_sub_s,
            Q          => floor_s
        );

    mv_up     <= mv_up_r;
    mv_down   <= mv_down_r;
    door_open <= door_open_r;
    floor     <= std_logic_vector(floor_s);
end architecture;
