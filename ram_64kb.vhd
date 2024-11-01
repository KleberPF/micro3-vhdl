library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ram_64kb is
	port (
		clk          : in std_logic;                    -- Clock signal
		read_enable  : in std_logic;                    -- Read enable signal (Leimem)
		write_enable : in std_logic;                    -- Write enable signal (Ecmem)
		addr         : in std_logic_vector(15 downto 0);-- 16-bit address input
		data_in      : in std_logic_vector(7 downto 0); -- 8-bit data input
		data_out     : out std_logic_vector(7 downto 0) -- 8-bit data output
	);
end entity;

architecture behavioral of ram_64kb is
	type ram_type is array (0 to 65535) of std_logic_vector(7 downto 0);
	signal ram : ram_type  := (
		/* 0x0000 */ 0 => x"28", -- LDX imediato, colocando 0x0100 no registrador IX
		/* 0x0001 */ 1 => x"01",
		/* 0x0002 */ 2 => x"00",
		/* 0x0003 */ 3 => x"B0", -- LDA pós-indexado
		/* 0x0004 */ 4 => x"01", 
		/* 0x0005 */ 5 => x"23",
		/* 0x0123 */ 291 => x"00",
		/* 0x0124 */ 292 => x"03",
		/* 0x0103 */ 259 => x"42",
		others => (others => '0'));
	signal read_data : std_logic_vector(7 downto 0) := (others => '0');
 
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- Write operation
            if write_enable = '1' then
                ram(to_integer(unsigned(addr))) <= data_in;
            end if;

            -- Read operation
            if read_enable = '1' then
                read_data <= ram(to_integer(unsigned(addr)));
            end if;
        end if;
    end process;
    
    -- Assign read_data to output
    data_out <= read_data;
    
end architecture behavioral;
