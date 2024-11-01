library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.utilities.all;

entity control_unit is
	port (
		clk: in std_logic;
		signal memory_info_in : in memory_rec_in;
		signal memory_info_out : out memory_rec_out;

		signal reg_a_info_in : in register_rec8_in;
		signal reg_a_info_out : out register_rec8_out;

		signal reg_b_info_in : in register_rec8_in;
		signal reg_b_info_out : out register_rec8_out;

		signal reg_don_info_in : in register_rec8_in;
		signal reg_don_info_out : out register_rec8_out;

		signal reg_aux_info_in : in register_rec8_in;
		signal reg_aux_info_out : out register_rec8_out;

		signal reg_co_info_in : in register_rec16_in;
		signal reg_co_info_out : out register_rec16_out;

		signal reg_dcod_info_in : in register_rec8_in;
		signal reg_dcod_info_out : out register_rec8_out;

		signal reg_rad_info_in : in register_rec16_in;
		signal reg_rad_info_out : out register_rec16_out;

		signal reg_ix_info_in : in register_rec16_in;
		signal reg_ix_info_out : out register_rec16_out;

		signal alu_info_in : in alu_rec_in;
		signal alu_info_out : out alu_rec_out;

		signal reg_flags_info_in : in register_flags_rec_in;
		signal reg_flags_enable : out std_logic
	);
end entity;

architecture behavioral of control_unit is
	type fsm_state is (
		T0,
		T1,
		T2,
		T3,
		T4,
		T5,
		T6,

		DIRECT_0,
		DIRECT_1,
		DIRECT_2,
		DIRECT_3,
		DIRECT_4,
		DIRECT_5,
		DIRECT_6,
		DIRECT_7,
		DIRECT_8,
		DIRECT_9,

		IMMEDIATE_0,
		IMMEDIATE_1,
		IMMEDIATE_2,
		IMMEDIATE_3,
		IMMEDIATE_4,
		IMMEDIATE_5,
		IMMEDIATE_6,
		IMMEDIATE_7,

		INDIRECT_0,
		INDIRECT_1,
		INDIRECT_2,
		INDIRECT_3,
		INDIRECT_4,
		INDIRECT_5,
		INDIRECT_6,
		INDIRECT_7,
		INDIRECT_8,
		INDIRECT_9,
		INDIRECT_10,
		INDIRECT_11,
		INDIRECT_12,
		INDIRECT_13,
		INDIRECT_14,
		INDIRECT_15,

		INDEXED_0,
		INDEXED_1,
		INDEXED_2,
		INDEXED_3,
		INDEXED_4,
		INDEXED_5,
		INDEXED_6,
		INDEXED_7,
		INDEXED_8,
		INDEXED_9,
		INDEXED_10,
		INDEXED_11,
		INDEXED_12,

		PRE_INDEXED_0,
		PRE_INDEXED_1,
		PRE_INDEXED_2,
		PRE_INDEXED_3,
		PRE_INDEXED_4,
		PRE_INDEXED_5,
		PRE_INDEXED_6,
		PRE_INDEXED_7,
		PRE_INDEXED_8,
		PRE_INDEXED_9,
		PRE_INDEXED_10,
		PRE_INDEXED_11,
		PRE_INDEXED_12,
		PRE_INDEXED_13,
		PRE_INDEXED_14,
		PRE_INDEXED_15,
		PRE_INDEXED_16,
		PRE_INDEXED_17,
		PRE_INDEXED_18,

		POS_INDEXED_0,
		POS_INDEXED_1,
		POS_INDEXED_2,
		POS_INDEXED_3,
		POS_INDEXED_4,
		POS_INDEXED_5,
		POS_INDEXED_6,
		POS_INDEXED_7,
		POS_INDEXED_8,
		POS_INDEXED_9,
		POS_INDEXED_10,
		POS_INDEXED_11,
		POS_INDEXED_12,
		POS_INDEXED_13,
		POS_INDEXED_14,
		POS_INDEXED_15,
		POS_INDEXED_16,
		POS_INDEXED_17,
		POS_INDEXED_18,
		
		EXEC, -- Send first operand to ALU
		ALU1, -- Send second operand to ALU
		ALU2, -- Calculate result in ALU
		ALU3, -- Store result from ALU
		ALU4,
		END_STATE
	);
	signal state : fsm_state;

	type instruction is (
		LDA,
		LDB,
		ADA,
		STA,
		LDX,
		CPA,
		CAL, -- Right now CAL is only meant to be called to exit the program
		BRE,
		BNE,
		ANA,
		ANB,
		NOP
	);
	signal ins : instruction;

	type addressing_mode is (
		DIRECT,
		IMMEDIATE,
		INDIRECT,
		INDEXED,
		PRE_INDEXED,
		POS_INDEXED,
		NO_FETCH
	);
	signal addr_mode : addressing_mode;

	signal indirect_step : integer := 0;
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			-- reset enable pins
			memory_info_out.read_enable <= '0';
			memory_info_out.write_enable <= '0';
			reg_a_info_out.enable <= '0';
			reg_don_info_out.enable <= '0';
			reg_aux_info_out.enable <= '0';
			reg_dcod_info_out.enable <= '0';
			reg_co_info_out.enable <= '0';
			reg_rad_info_out.enable <= '0';
			reg_flags_enable <= '0';

			case state is
			when T0 =>
				copy_register16_data(reg_rad_info_out, reg_co_info_in);
				state <= T1;
			when T1 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= T2;
			when T2 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= T3;
			when T3 =>
				copy_register8_data(reg_dcod_info_out, reg_don_info_in);
				state <= T4;
			when T4 =>
				case reg_dcod_info_in.data is
				when x"00" =>
					ins <= NOP;
					addr_mode <= NO_FETCH;
				when x"10" =>
					ins <= LDA;
					addr_mode <= DIRECT;
				when x"20" =>
					ins <= LDA;
					addr_mode <= IMMEDIATE;
				when x"50" =>
					ins <= LDB;
					addr_mode <= DIRECT;
				when x"60" =>
					ins <= LDB;
					addr_mode <= IMMEDIATE;
				when x"24" =>
					ins <= ADA;
					addr_mode <= IMMEDIATE;
				when x"11" =>
					ins <= STA;
					addr_mode <= DIRECT;
				when x"90" =>
					ins <= LDA;
					addr_mode <= INDIRECT;
				when x"30" =>
					ins <= LDA;
					addr_mode <= INDEXED;
				when x"C0" =>
					ins <= LDA;
					addr_mode <= PRE_INDEXED;
				when x"B0" =>
					ins <= LDA;
					addr_mode <= POS_INDEXED;
				when x"D0" =>
					ins <= LDB;
					addr_mode <= INDIRECT;
				when x"28" =>
					ins <= LDX;
					addr_mode <= IMMEDIATE;
				when x"27" =>
					ins <= CPA;
					addr_mode <= IMMEDIATE;
				when x"58" =>
					ins <= CAL;
					addr_mode <= DIRECT;
				when x"A0" =>
					ins <= BRE;
					addr_mode <= IMMEDIATE;
				when x"A1" =>
					ins <= BNE;
					addr_mode <= IMMEDIATE;
				when x"12" =>
					ins <= ANA;
					addr_mode <= DIRECT;
				when x"22" =>
					ins <= ANA;
					addr_mode <= IMMEDIATE;
				when x"52" =>
					ins <= ANB;
					addr_mode <= DIRECT;
				when others =>
				end case;
				state <= T5;
			when T5 =>
				increment_reg16(reg_co_info_out, reg_co_info_in);
				state <= T6;
			when T6 =>
				--- T0 to T6 is done by all instructions (opcode fetching and decoding)
				--- Now we need to decide what should be done next
				if ins = NOP then
					state <= T0;
				elsif ins = CAL then
					state <= END_STATE;
				elsif addr_mode = NO_FETCH then
					state <= EXEC;
				else
					copy_register16_data(reg_rad_info_out, reg_co_info_in);
					if addr_mode = DIRECT then
						state <= DIRECT_0;
					elsif addr_mode = IMMEDIATE then
						state <= IMMEDIATE_0;
					elsif addr_mode = INDIRECT then
						state <= INDIRECT_0;
					elsif addr_mode = INDEXED then
						state <= INDEXED_0;
					elsif addr_mode = PRE_INDEXED then
						state <= PRE_INDEXED_0;
					elsif addr_mode = POS_INDEXED then
						state <= POS_INDEXED_0;
					end if;
				end if;

			-- Direct
			when DIRECT_0 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= DIRECT_1;
			when DIRECT_1 =>
				ram_to_reg(memory_info_in, reg_aux_info_out);
				state <= DIRECT_2;
			when DIRECT_2 =>
				increment_reg16(reg_rad_info_out, reg_rad_info_in);
				state <= DIRECT_3;
			when DIRECT_3 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= DIRECT_4;
			when DIRECT_4 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= DIRECT_5;
			when DIRECT_5 =>
				reg_rad_info_out.input <= reg_aux_info_in.data & reg_don_info_in.data;
				reg_rad_info_out.enable <= '1';
				state <= DIRECT_6;
			when DIRECT_6 =>
				increment_reg16(reg_co_info_out, reg_co_info_in);
				state <= DIRECT_7;
			when DIRECT_7 =>
				increment_reg16(reg_co_info_out, reg_co_info_in);
				state <= DIRECT_8;
			when DIRECT_8 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= DIRECT_9;
			when DIRECT_9 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= EXEC;
			-- End Direct

			-- Immediate
			when IMMEDIATE_0 =>
				increment_reg16(reg_co_info_out, reg_co_info_in);
				if (ins = LDX) or (ins = BRE) or (ins = BNE) then
					state <= IMMEDIATE_1;
				else
					state <= IMMEDIATE_2;
				end if;
			when IMMEDIATE_1 =>
				increment_reg16(reg_co_info_out, reg_co_info_in);
				state <= IMMEDIATE_2;
			when IMMEDIATE_2 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= IMMEDIATE_3;
			when IMMEDIATE_3 =>
				if (ins = LDX) or (ins = BRE) or (ins = BNE) then
					ram_to_reg(memory_info_in, reg_aux_info_out);
					state <= IMMEDIATE_4;
				else
                	ram_to_reg(memory_info_in, reg_don_info_out);
                	state <= EXEC;
				end if;
			when IMMEDIATE_4 =>
				increment_reg16(reg_rad_info_out, reg_rad_info_in);
				state <= IMMEDIATE_5;
			when IMMEDIATE_5 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= IMMEDIATE_6;
			when IMMEDIATE_6 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= IMMEDIATE_7;
			when IMMEDIATE_7 =>
				reg_rad_info_out.input <= reg_aux_info_in.data & reg_don_info_in.data;
				reg_rad_info_out.enable <= '1';
				state <= EXEC;
			-- End Immediate

			-- Indirect
			when INDIRECT_0 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= INDIRECT_1;
			when INDIRECT_1 =>
				ram_to_reg(memory_info_in, reg_aux_info_out);
				state <= INDIRECT_2;
			when INDIRECT_2 =>
				increment_reg16(reg_rad_info_out, reg_rad_info_in);
				state <= INDIRECT_3;
			when INDIRECT_3 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= INDIRECT_4;
			when INDIRECT_4 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= INDIRECT_5;
			when INDIRECT_5 =>
				reg_rad_info_out.input <= reg_aux_info_in.data & reg_don_info_in.data;
				reg_rad_info_out.enable <= '1';
				state <= INDIRECT_6;
			when INDIRECT_6 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= INDIRECT_7;
			when INDIRECT_7 =>
				ram_to_reg(memory_info_in, reg_aux_info_out);
				state <= INDIRECT_8;
			when INDIRECT_8 =>
				increment_reg16(reg_rad_info_out, reg_rad_info_in);
				state <= INDIRECT_9;
			when INDIRECT_9 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= INDIRECT_10;
			when INDIRECT_10 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= INDIRECT_11;
			when INDIRECT_11 =>
				reg_rad_info_out.input <= reg_aux_info_in.data & reg_don_info_in.data;
				reg_rad_info_out.enable <= '1';
				state <= INDIRECT_12;
			when INDIRECT_12 =>
				increment_reg16(reg_co_info_out, reg_co_info_in);
				state <= INDIRECT_13;
			when INDIRECT_13 =>
				increment_reg16(reg_co_info_out, reg_co_info_in);
				state <= INDIRECT_14;
			when INDIRECT_14 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= INDIRECT_15;
			when INDIRECT_15 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= EXEC;
			-- End Indirect

			-- Indexed
			when INDEXED_0 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= INDEXED_1;
			when INDEXED_1 =>
				ram_to_reg(memory_info_in, reg_aux_info_out);
				state <= INDEXED_2;
			when INDEXED_2 =>
				increment_reg16(reg_rad_info_out, reg_rad_info_in);
				state <= INDEXED_3;
			when INDEXED_3 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= INDEXED_4;
			when INDEXED_4 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= INDEXED_5;
			when INDEXED_5 =>
				reg_rad_info_out.input <= reg_aux_info_in.data & reg_don_info_in.data;
				reg_rad_info_out.enable <= '1';
				state <= INDEXED_6;
			when INDEXED_6 =>
				alu_info_out.a <= reg_rad_info_in.data;
				alu_info_out.selection <= "000"; -- ADD
				state <= INDEXED_7;
			when INDEXED_7 =>
				alu_info_out.b <= reg_ix_info_in.data;
				state <= INDEXED_8;
			when INDEXED_8 =>
				reg_rad_info_out.input <= alu_info_in.result;
				reg_rad_info_out.enable <= '1';
				state <= INDEXED_9;
			when INDEXED_9 =>
				increment_reg16(reg_co_info_out, reg_co_info_in);
				state <= INDEXED_10;
			when INDEXED_10 =>
				increment_reg16(reg_co_info_out, reg_co_info_in);
				state <= INDEXED_11;
			when INDEXED_11 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= INDEXED_12;
			when INDEXED_12 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= EXEC;
			-- End Indexed

			-- Pre Indexed
			when PRE_INDEXED_0 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= PRE_INDEXED_1;
			when PRE_INDEXED_1 =>
				ram_to_reg(memory_info_in, reg_aux_info_out);
				state <= PRE_INDEXED_2;
			when PRE_INDEXED_2 =>
				increment_reg16(reg_rad_info_out, reg_rad_info_in);
				state <= PRE_INDEXED_3;
			when PRE_INDEXED_3 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= PRE_INDEXED_4;
			when PRE_INDEXED_4 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= PRE_INDEXED_5;
			when PRE_INDEXED_5 =>
				reg_rad_info_out.input <= reg_aux_info_in.data & reg_don_info_in.data;
				reg_rad_info_out.enable <= '1';
				state <= PRE_INDEXED_6;
			when PRE_INDEXED_6 =>
				alu_info_out.a <= reg_rad_info_in.data;
				alu_info_out.selection <= "000"; -- ADD
				state <= PRE_INDEXED_7;
			when PRE_INDEXED_7 =>
				alu_info_out.b <= reg_ix_info_in.data;
				state <= PRE_INDEXED_8;
			when PRE_INDEXED_8 =>
				reg_rad_info_out.input <= alu_info_in.result;
				reg_rad_info_out.enable <= '1';
				state <= PRE_INDEXED_9;
			when PRE_INDEXED_9 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= PRE_INDEXED_10;
			when PRE_INDEXED_10 =>
				ram_to_reg(memory_info_in, reg_aux_info_out);
				state <= PRE_INDEXED_11;
			when PRE_INDEXED_11 =>
				increment_reg16(reg_rad_info_out, reg_rad_info_in);
				state <= PRE_INDEXED_12;
			when PRE_INDEXED_12 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= PRE_INDEXED_13;
			when PRE_INDEXED_13 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= PRE_INDEXED_14;
			when PRE_INDEXED_14 =>
				reg_rad_info_out.input <= reg_aux_info_in.data & reg_don_info_in.data;
				reg_rad_info_out.enable <= '1';
				state <= PRE_INDEXED_15;
			when PRE_INDEXED_15 =>
				increment_reg16(reg_co_info_out, reg_co_info_in);
				state <= PRE_INDEXED_16;
			when PRE_INDEXED_16 =>
				increment_reg16(reg_co_info_out, reg_co_info_in);
				state <= PRE_INDEXED_17;
			when PRE_INDEXED_17 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= PRE_INDEXED_18;
			when PRE_INDEXED_18 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= EXEC;
			-- End Pre Indexed

			-- Pos Indexed
			when POS_INDEXED_0 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= POS_INDEXED_1;
			when POS_INDEXED_1 =>
				ram_to_reg(memory_info_in, reg_aux_info_out);
				state <= POS_INDEXED_2;
			when POS_INDEXED_2 =>
				increment_reg16(reg_rad_info_out, reg_rad_info_in);
				state <= POS_INDEXED_3;
			when POS_INDEXED_3 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= POS_INDEXED_4;
			when POS_INDEXED_4 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= POS_INDEXED_5;
			when POS_INDEXED_5 =>
				reg_rad_info_out.input <= reg_aux_info_in.data & reg_don_info_in.data;
				reg_rad_info_out.enable <= '1';
				state <= POS_INDEXED_6;
			when POS_INDEXED_6 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= POS_INDEXED_7;
			when POS_INDEXED_7 =>
				ram_to_reg(memory_info_in, reg_aux_info_out);
				state <= POS_INDEXED_8;
			when POS_INDEXED_8 =>
				increment_reg16(reg_rad_info_out, reg_rad_info_in);
				state <= POS_INDEXED_9;
			when POS_INDEXED_9 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= POS_INDEXED_10;
			when POS_INDEXED_10 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= POS_INDEXED_11;
			when POS_INDEXED_11 =>
				reg_rad_info_out.input <= reg_aux_info_in.data & reg_don_info_in.data;
				reg_rad_info_out.enable <= '1';
				state <= POS_INDEXED_12;
			when POS_INDEXED_12 =>
				alu_info_out.a <= reg_rad_info_in.data;
				alu_info_out.selection <= "000"; -- ADD
				state <= POS_INDEXED_13;
			when POS_INDEXED_13 =>
				alu_info_out.b <= reg_ix_info_in.data;
				state <= POS_INDEXED_14;
			when POS_INDEXED_14 =>
				reg_rad_info_out.input <= alu_info_in.result;
				reg_rad_info_out.enable <= '1';
				state <= POS_INDEXED_15;
			when POS_INDEXED_15 =>
				increment_reg16(reg_co_info_out, reg_co_info_in);
				state <= POS_INDEXED_16;
			when POS_INDEXED_16 =>
				increment_reg16(reg_co_info_out, reg_co_info_in);
				state <= POS_INDEXED_17;
			when POS_INDEXED_17 =>
				ram_fetch(memory_info_out, reg_rad_info_in);
				state <= POS_INDEXED_18;
			when POS_INDEXED_18 =>
				ram_to_reg(memory_info_in, reg_don_info_out);
				state <= EXEC;
			-- End Pos Indexed

			when EXEC =>
				case ins is
				-- Because we need to set flags even when loading directly to a register,
				-- our load is basically adding the operand to 0 and storing the result
				when LDA | LDB | LDX =>
					alu_info_out.a <= (others => '0');
					alu_info_out.selection <= "000"; -- ADD
					state <= ALU1;
				when ANA | ANB =>
					alu_info_out.a <= "00000000" & reg_a_info_in.data;
					alu_info_out.selection <= "010"; -- AND
					state <= ALU1;
				when STA =>
					memory_info_out.write_enable <= '1';
					memory_info_out.read_addr <= reg_rad_info_in.data;
					memory_info_out.value_to_write <= reg_a_info_in.data;
					state <= T0;
				when ADA =>
					-- fetch first operand
					alu_info_out.a <= "00000000" & reg_a_info_in.data;
					alu_info_out.selection <= "000"; -- ADD
					state <= ALU1;
				when CPA =>
					alu_info_out.a <= "00000000" & reg_a_info_in.data;
					alu_info_out.selection <= "001"; -- SUB
					state <= ALU1;
				when BRE =>
					if reg_flags_info_in.flags.z = '1' then
						copy_register16_data(reg_co_info_out, reg_rad_info_in);
					end if;
					state <= T0;
				when BNE =>
					if reg_flags_info_in.flags.z = '0' then
						copy_register16_data(reg_co_info_out, reg_rad_info_in);
					end if;
					state <= T0;
				when others =>
				end case;

			-- ALU states
			when ALU1 =>
				if ins = LDX then
					alu_info_out.b <= reg_rad_info_in.data;
				else
					alu_info_out.b <= "00000000" & reg_don_info_in.data;
				end if;
				state <= ALU2;
			when ALU2 =>
				case ins is
				when LDA | ADA | ANA =>
					reg_a_info_out.enable <= '1';
					reg_a_info_out.input <= alu_info_in.result(7 downto 0);
				when LDB | ANB =>
					reg_b_info_out.enable <= '1';
					reg_b_info_out.input <= alu_info_in.result(7 downto 0);
				when LDX =>
					reg_ix_info_out.enable <= '1';
					reg_ix_info_out.input <= alu_info_in.result;
				when CPA => -- We just need to update flags
				when others =>
				end case;

				state <= ALU3;
			when ALU3 => -- Update flags
				reg_flags_enable <= '1';
				state <= T0;
			when others =>
			end case;
		end if;
	end process;
end architecture;