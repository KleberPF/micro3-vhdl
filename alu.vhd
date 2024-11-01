library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.utilities.all;

entity alu is
	port (
		a : in std_logic_vector(15 downto 0);
		b : in std_logic_vector(15 downto 0);
		selection : in std_logic_vector(2 downto 0);

		result : out std_logic_vector(15 downto 0);
		flags : out flags_rec
	);
end entity;

architecture behavioral of alu is
begin
	process(a, b, selection)
		variable tmp_result : unsigned(32 downto 0);
	begin
		-- all flags stay zeroed by default
		flags.r <= '0';
		flags.d <= '0';

		case selection is
		when "000" => -- ADD
			tmp_result := resize(unsigned(a), tmp_result'length) + unsigned(b);
		when "001" => -- SUB
			tmp_result := resize(unsigned(a), tmp_result'length) - unsigned(b);
		when "010" => -- AND
			tmp_result := resize(unsigned(a and b), tmp_result'length);
		when others =>
		end case;

		flags.r <= tmp_result(16);

		if tmp_result = "00000000000000000" then
			flags.z <= '1';
		else
			flags.z <= '0';
		end if;

		result <= std_logic_vector(tmp_result(15 downto 0));
		flags.n <= tmp_result(15);
	end process;
end architecture;
