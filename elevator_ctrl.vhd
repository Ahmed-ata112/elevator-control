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
    type state_type is (preparing_state, reset_state, not_working_state, go_up_state, go_down_state, door_open_state);
    signal current_state : state_type;
    signal next_state    : state_type;

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
            end if;
        end if;
    end process;

    state_transitions_process : process(current_state)
    begin
        case current_state is
            when preparing_state =>
                -- it should stay here untill a valid  floor is reached
                -- it won't listen to the resolver until then
                
            when reset_state =>
                null;
            when not_working_state =>
                null;
            when go_up_state =>
                null;
            when go_down_state =>
                null;
            when door_open_state =>
                null;
        end case;

    end process;                        -- state_transitions_process

end architecture;
