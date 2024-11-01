library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package utilities is
    type memory_rec_out is record
        read_enable : std_logic;
        write_enable : std_logic;
        read_addr : std_logic_vector(15 downto 0); -- Maybe change this name, we also use this for writing
        value_to_write : std_logic_vector(7 downto 0);
    end record memory_rec_out;

    type memory_rec_in is record
        read_result : std_logic_vector(7 downto 0);
    end record memory_rec_in;

    type register_rec8_out is record
        input : std_logic_vector(7 downto 0);
        enable : std_logic;
    end record register_rec8_out;

    type register_rec8_in is record
        data : std_logic_vector(7 downto 0);
    end record register_rec8_in;

    type register_rec16_out is record
        input : std_logic_vector(15 downto 0);
        enable : std_logic;
    end record register_rec16_out;

    type register_rec16_in is record
        data : std_logic_vector(15 downto 0);
    end record register_rec16_in;

    type flags_rec is record
        z : std_logic;
        n : std_logic;
        r : std_logic;
        d : std_logic;
    end record flags_rec;

    type register_flags_rec_in is record
        flags : flags_rec;
    end record register_flags_rec_in;

    type register_flags_rec_out is record
        input_flags : flags_rec;
        enable : std_logic;
    end record register_flags_rec_out;

    type alu_rec_out is record
        a : std_logic_vector(15 downto 0);
        b : std_logic_vector(15 downto 0);
        selection : std_logic_vector(2 downto 0);
    end record alu_rec_out;

    type alu_rec_in is record
        result : std_logic_vector(15 downto 0);
    end record alu_rec_in;

	procedure copy_register16_data(signal reg_to : out register_rec16_out; signal reg_from : in register_rec16_in);
    procedure copy_register8_data(signal reg_to : out register_rec8_out; signal reg_from : in register_rec8_in);
    procedure ram_fetch(signal mem_info : out memory_rec_out; reg_rad : in register_rec16_in);
    procedure ram_to_reg(signal mem_info : in memory_rec_in; signal reg_to : out register_rec8_out);
    procedure increment_reg16(signal reg_to_out : out register_rec16_out; signal reg_to_in : in register_rec16_in; constant inc : in integer := 1);
end package;

package body utilities is
	procedure copy_register16_data(signal reg_to : out register_rec16_out; signal reg_from : in register_rec16_in) is
    begin
        reg_to.input <= reg_from.data;
        reg_to.enable <= '1';
    end procedure;
    
    procedure copy_register8_data(signal reg_to : out register_rec8_out; signal reg_from : in register_rec8_in) is
    begin
        reg_to.input <= reg_from.data;
        reg_to.enable <= '1';
    end procedure;

    procedure ram_fetch(signal mem_info : out memory_rec_out; reg_rad : in register_rec16_in) is
    begin
        mem_info.read_enable <= '1';
        mem_info.read_addr <= reg_rad.data;
    end procedure;

    procedure ram_to_reg(signal mem_info : in memory_rec_in; signal reg_to : out register_rec8_out) is
    begin
        reg_to.input <= mem_info.read_result;
        reg_to.enable <= '1';
    end procedure;
    
    procedure increment_reg16(signal reg_to_out : out register_rec16_out; signal reg_to_in : in register_rec16_in; constant inc : in integer := 1) is
    begin
        reg_to_out.input <= std_logic_vector(unsigned(reg_to_in.data) + inc);
        reg_to_out.enable <= '1';
    end procedure;
end utilities;