library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity floor_counter is
    generic(
        n : natural := 4;
        k : integer := 10
    );

    port(
        clock      : in  std_logic;
        reset_n    : in  std_logic;
        clk_enable : in  std_logic;
        add_or_sub : in  std_logic;
        Q          : out unsigned(n - 1 downto 0));

end entity;
architecture Behavior of floor_counter is
    signal value : unsigned(n - 1 downto 0) := (others => '0');
begin
    process(clock, reset_n)
    begin
        if (reset_n = '0') then
            value <= (others => '0');
        elsif (rising_edge(clock)) then

            if clk_enable = '1' then
                if (value = to_unsigned(k, value'length) - 1) then
                    value <= (others => '0');
                else
                    if (add_or_sub = '1') then
                        value <= value + 1;
                    else
                        value <= value - 1;

                    end if;
                end if;
            end if;

        end if;
    end process;

    Q <= value;

end Behavior;
