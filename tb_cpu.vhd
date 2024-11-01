library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.utilities.all;

entity tb_cpu is
end entity;

architecture behavior of tb_cpu is
	constant clk_period : time := 10 ns;
	signal clk, iclk : std_logic;
	
	signal memory_info_in : memory_rec_in;
	signal memory_info_out : memory_rec_out;

	signal reg_a_info_in : register_rec8_in;
	signal reg_a_info_out : register_rec8_out;

	signal reg_b_info_in : register_rec8_in;
	signal reg_b_info_out : register_rec8_out;

	signal reg_don_info_in : register_rec8_in;
	signal reg_don_info_out : register_rec8_out;

	signal reg_aux_info_in : register_rec8_in;
	signal reg_aux_info_out : register_rec8_out;

	signal reg_co_info_in : register_rec16_in;
	signal reg_co_info_out : register_rec16_out;

	signal reg_rad_info_in : register_rec16_in;
	signal reg_rad_info_out : register_rec16_out;

	signal reg_dcod_info_in : register_rec8_in;
	signal reg_dcod_info_out : register_rec8_out;

	signal reg_ix_info_in : register_rec16_in;
	signal reg_ix_info_out : register_rec16_out;

	signal alu_info_in : alu_rec_in;
	signal alu_info_out : alu_rec_out;

	signal reg_flags_info_in : register_flags_rec_in;
	signal reg_flags_info_out : register_flags_rec_out;

begin
	memory : entity work.ram_64kb
		port map (
			clk => clk,
			read_enable => memory_info_out.read_enable,
			write_enable => memory_info_out.write_enable,
			addr => memory_info_out.read_addr,
			data_in => memory_info_out.value_to_write,
			data_out => memory_info_in.read_result
		);

	reg_a : entity work.generic_register
		generic map (
			WIDTH => 8
		)
		port map (
			clk => clk,
			input => reg_a_info_out.input,
			enable => reg_a_info_out.enable,
			data => reg_a_info_in.data
		);
	
	reg_b : entity work.generic_register
		generic map (
			WIDTH => 8
		)
		port map (
			clk => clk,
			input => reg_b_info_out.input,
			enable => reg_b_info_out.enable,
			data => reg_b_info_in.data
		);

	reg_don : entity work.generic_register
		generic map (
			WIDTH => 8
		)
		port map (
			clk => clk,
			input => reg_don_info_out.input,
			enable => reg_don_info_out.enable,
			data => reg_don_info_in.data
		);

	reg_aux : entity work.generic_register
		generic map (
			WIDTH => 8
		)
		port map (
			clk => clk,
			input => reg_aux_info_out.input,
			enable => reg_aux_info_out.enable,
			data => reg_aux_info_in.data
		);

	reg_dcod : entity work.generic_register
		generic map (
			WIDTH => 8
		)
		port map (
			clk => clk,
			input => reg_dcod_info_out.input,
			enable => reg_dcod_info_out.enable,
			data => reg_dcod_info_in.data
		);

	reg_co : entity work.generic_register
		generic map (
			WIDTH => 16
		)
		port map (
			clk => clk,
			input => reg_co_info_out.input,
			enable => reg_co_info_out.enable,
			data => reg_co_info_in.data
		);

	reg_rad : entity work.generic_register
		generic map (
			WIDTH => 16
		)
		port map (
			clk => clk,
			input => reg_rad_info_out.input,
			enable => reg_rad_info_out.enable,
			data => reg_rad_info_in.data
		);
	
	reg_ix : entity work.generic_register
		generic map (
			WIDTH => 16
		)
		port map (
			clk => clk,
			input => reg_ix_info_out.input,
			enable => reg_ix_info_out.enable,
			data => reg_ix_info_in.data
		);
	
	alu_inst : entity work.alu
		port map (
			a => alu_info_out.a,
			b => alu_info_out.b,
			selection => alu_info_out.selection,
	
			result => alu_info_in.result,
			flags => reg_flags_info_out.input_flags
		);
	
	reg_flags : entity work.flags_register
		port map (
			clk => clk,
			input_flags => reg_flags_info_out.input_flags,
			enable => reg_flags_info_out.enable,

			flags => reg_flags_info_in.flags
		);
	
	ctrl_unit : entity work.control_unit
		port map (
			clk => iclk,
			memory_info_in => memory_info_in,
			memory_info_out => memory_info_out,
			reg_a_info_in => reg_a_info_in,
			reg_a_info_out => reg_a_info_out,
			reg_b_info_in => reg_b_info_in,
			reg_b_info_out => reg_b_info_out,
			reg_don_info_in => reg_don_info_in,
			reg_don_info_out => reg_don_info_out,
			reg_aux_info_in => reg_aux_info_in,
			reg_aux_info_out => reg_aux_info_out,
			reg_dcod_info_in => reg_dcod_info_in,
			reg_dcod_info_out => reg_dcod_info_out,
			reg_co_info_in => reg_co_info_in,
			reg_co_info_out => reg_co_info_out,
			reg_rad_info_in => reg_rad_info_in,
			reg_rad_info_out => reg_rad_info_out,
			reg_ix_info_in => reg_ix_info_in,
			reg_ix_info_out => reg_ix_info_out,
			alu_info_in => alu_info_in,
			alu_info_out => alu_info_out,
			reg_flags_info_in => reg_flags_info_in,
			reg_flags_enable => reg_flags_info_out.enable
		);
	
	iclk <= not clk;

	clk_process : process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
	
	stim_process: process
	begin
		wait;
	end process;

end architecture;