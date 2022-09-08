library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elev_test is
    port(
        clk   : in  std_logic;
        b_in  : in  std_logic;
        b_out : out std_logic
    );
end entity;

architecture rtl of elev_test is
    signal b     : std_logic;
    signal count : unsigned(3 downto 0);
begin

    test : process(clk)
    begin
        if (rising_edge(clk)) then
            if (b_in = '1') then
                b <= '1';
            end if;
            count <= count + 1;
        end if;
    end process;

    p2 : process(count, b_in)
    begin
        if (count = "0101" and b_in = '0') then
            b <= '0';
        end if;

    end process;                        -- p2
    b_out <= b;
end architecture;
