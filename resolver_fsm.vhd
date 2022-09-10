library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity resolver_fsm is
    port(
        clk     : in std_logic;
        reset   : in std_logic;
        ups     : in std_logic_vector(N - 1 downto 0);
        downs   : in std_logic_vector(N - 1 downto 0);
        buttons : in std_logic_vector(N - 1 downto 0)
    );
end entity resolver_fsm;

architecture rtl of resolver_fsm is

begin

end architecture;
