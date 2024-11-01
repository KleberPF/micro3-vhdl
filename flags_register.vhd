library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.utilities.all;

entity flags_register is
	port (
		clk: in std_logic;
		input_flags : in flags_rec;
		enable : in std_logic;
		
		flags : out flags_rec
	);
end entity;

architecture behavioral of flags_register is
	signal mem : flags_rec;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if enable = '1' then
                mem <= input_flags;
			end if;
		end if;
	end process;
	
	flags <= mem;
end architecture;
