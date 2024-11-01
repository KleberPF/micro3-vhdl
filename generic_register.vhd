library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_register is
	generic (
		WIDTH: integer := 8
	);
	port (
		clk: in std_logic;
		input : in std_logic_vector(WIDTH - 1 downto 0);
		enable : in std_logic;
		
		data : out std_logic_vector(WIDTH - 1 downto 0)
	);
end entity;

architecture behavioral of generic_register is
	signal mem : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');

begin
	process(clk)
	begin
		if rising_edge(clk) then
			if enable = '1' then
				mem <= input;
			end if;
		end if;
	end process;
	
	data <= mem;
end architecture;
