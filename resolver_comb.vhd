

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity resolver_comb is
    generic(
        N : integer := 10
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
end resolver_comb;

architecture arch of resolver_comb is
    constant ALL_ONES : std_logic_vector(N - 1 downto 0) := (others => '1');

begin

    result_process : process(clk)
    begin
        if (rising_edge(clk)) then
            if (reset_n = '0') then
                none_is_pressed <= '1';
                highest_dest    <= (others => '0');
                lowest_dest     <= (others => '0');
            else
                if (buttons and downs and ups) = ALL_ONES then
                    none_is_pressed <= '1';
                else
                    none_is_pressed <= '0';
                end if;

                high_lp : for k in N - 1 downto 0 loop
                    if (buttons(k) = '0' or (buttons = ALL_ONES and (downs(k) = '0' or ups(k) = '0'))) then
                        highest_dest <= to_unsigned(k, highest_dest'length);
                        exit;
                    end if;
                end loop high_lp;

                low_lp : for k in 0 to N - 1 loop
                    if (buttons(k) = '0' or (buttons = ALL_ONES and (downs(k) = '0' or ups(k) = '0'))) then
                        lowest_dest <= to_unsigned(k, highest_dest'length);
                        exit;
                    end if;
                end loop low_lp;
            end if;
        end if;
    end process;                        -- result_process

end architecture;                       -- arch