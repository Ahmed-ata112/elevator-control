library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity b_reg_test is
    generic(
        N : integer := 10
    );
    port(
        clk   : in  std_logic;
        b_in  : in  std_logic_vector(N - 1 downto 0);
        b_out : out std_logic_vector(N - 1 downto 0)
    );
end entity;

architecture rtl of b_reg_test is
    signal b_next  : std_logic_vector(N - 1 downto 0);
    signal b_out_s : std_logic_vector(N - 1 downto 0);
    signal count   : unsigned(3 downto 0);
begin

    test : process(clk)
    begin
        if (rising_edge(clk)) then
            b_out_s <= b_next;
            count   <= count + 1;
        end if;
    end process;

    p2 : process(count, b_in, b_out_s)
    begin                               -- 0 => x
        -- 1 => 10
        b_next <= (others => '0');

        for i in 0 to N - 1 loop
            if (b_in(i) = '1') then
                b_next(i) <= '1';
            elsif count /= "0101" then
                b_next(i) <= b_out_s(i);
            end if;
        end loop;

    end process;                        -- p2
    b_out <= b_out_s;
end architecture;
