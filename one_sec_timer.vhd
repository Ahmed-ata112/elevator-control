library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity one_sec_timer is
    generic(
        clk_freq : integer := 50_000_000
    );
    port(
        fast_Clk : in  std_logic;
        reset    : in  std_logic;
        roll_out : out std_logic
    );
end entity;
architecture rtl of one_sec_timer is

    signal fast_count        : unsigned(31 downto 0) := (others => '0');
    signal slow_count_signal : unsigned(3 downto 0)  := (others => '0');
begin
    process(fast_Clk)
    begin
        if rising_edge(fast_Clk) then
            roll_out <= '0';
            if (reset = '0') then
                fast_count        <= (others => '0');
                slow_count_signal <= (others => '0');

            elsif fast_count = clk_freq - 1 then

                fast_count <= (others => '0');
                if (slow_count_signal = to_unsigned(1, 4)) then
                    slow_count_signal <= (others => '0');
                    roll_out          <= '1';
                else
                    slow_count_signal <= slow_count_signal + 1;
                end if;
            else
                fast_count <= fast_count + 1;
            end if;

        end if;
    end process;

end architecture;
