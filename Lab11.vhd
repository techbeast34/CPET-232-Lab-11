library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Common.ALL;

ENTITY Lab11 IS
	PORT(
	seed		:IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	PB			:IN STD_LOGIC;
	test_mode	:IN STD_LOGIC;
	clk			:IN STD_LOGIC;
	reset_n		:IN STD_LOGIC;
	GPIO		:OUT STD_LOGIC;
	state  		:OUT state_type);
END Lab11;

ARCHITECTURE model OF Lab11 IS

	SIGNAL clk_flag_wire	  :STD_LOGIC;
	SIGNAL count_flag_wire	  :STD_LOGIC;
	SIGNAL clk_spd_cont_wire  :STD_LOGIC;
	SIGNAL load_SR_wire		  :STD_LOGIC;
	SIGNAL load_rng_wire	  :STD_LOGIC;
	SIGNAL en_rng_wire		  :STD_LOGIC;
	SIGNAL en_counter_wire	  :STD_LOGIC;
	SIGNAL clk_spd_cont_mout  :STD_LOGIC;
	SIGNAL d_ff_wire		  :STD_LOGIC;
	SIGNAL sr_out_wire		  :STD_LOGIC;
	SIGNAL delay_unit_rst_wire:STD_LOGIC;
	
	--AND GATES
	SIGNAL counter_reset      :STD_LOGIC;
	SIGNAL delay_unit_reset	  :STD_LOGIC;
	
	
	SIGNAL rand_num			:STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL delay_value		:STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL max_count		:STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL output_cont_wire	:STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	CONSTANT five		:STD_LOGIC_VECTOR(5 DOWNTO 0) := "000101";
	CONSTANT seven		:STD_LOGIC_VECTOR(5 DOWNTO 0) := "001001";
	CONSTANT twentyNine :STD_LOGIC_VECTOR(5 DOWNTO 0) := "011101";
	CONSTANT fifty		:STD_LOGIC_VECTOR(5 DOWNTO 0) := "110010";
	CONSTANT one		:STD_LOGIC := '1';

	COMPONENT fsm
		PORT(
		count_flag	:IN STD_LOGIC;
		PB			:IN STD_LOGIC;
		EN_Master	:IN STD_LOGIC;
		clk			:IN STD_LOGIC;
		reset_n		:IN STD_LOGIC;
		Load_RNG, EN_RNG, load_SR, EN_Counter, clock_spd_control,
		delay_unit_rst	:OUT STD_LOGIC;
		output_control	:OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		state			:OUT state_type);
	END COMPONENT;
	
	COMPONENT counter
		PORT(
		max_value :IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		clk 	  :IN STD_LOGIC;
		enable	  :IN STD_LOGIC;
		reset_n	  :IN STD_LOGIC;
		flag	  :OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT rng
		PORT(
		seed	:IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		load	:IN STD_LOGIC;
		clk		:IN STD_LOGIC;
		reset_n	:IN STD_LOGIC;
		enable	:IN STD_LOGIC;
		rand	:OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	END COMPONENT;
	
	COMPONENT shift_reg
		PORT(
		input	  :IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		load	  :IN STD_LOGIC;
		enable	  :IN STD_LOGIC;
		reset_n	  :IN STD_LOGIC;
		output	  :OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT d_ff
		PORT(
		D		:IN STD_LOGIC;
		clk		:IN STD_LOGIC;
		reset_n :IN STD_LOGIC;
		Q		:OUT STD_LOGIC);
	END COMPONENT;

BEGIN
	counter_reset <= (reset_n AND en_counter_wire);
	delay_unit_reset <= (reset_n AND delay_unit_rst_wire);

	delay_unit_mux	: PROCESS(test_mode, clk)
	BEGIN
		CASE(test_mode) IS
			WHEN '1' => delay_value <= five;
			WHEN '0'=> delay_value <= fifty;
			WHEN OTHERS => delay_value <= "000000";
		END CASE;
	END PROCESS;
	
	count_value_mux	: PROCESS(output_cont_wire, clk)
	BEGIN
		CASE(output_cont_wire) IS
			WHEN "01" => max_count <= twentyNine;
			WHEN "10" => max_count <= seven;
			WHEN OTHERS => max_count <= "000000";
		END CASE;
	END PROCESS;
	
	d_ff_mux	    : PROCESS(output_cont_wire, clk)
	BEGIN
		CASE(output_cont_wire) IS
			WHEN "10" => d_ff_wire <= sr_out_wire;
			WHEN "01" => d_ff_wire <= '1';
			WHEN OTHERS => d_ff_wire <= '0';
		END CASE;
	END PROCESS;
	
	clk_spd_cont_mux: PROCESS(clk_spd_cont_wire, clk)
	BEGIN
		CASE(clk_spd_cont_wire) IS
			WHEN '1' => clk_spd_cont_mout <= '1';
			WHEN '0' => clk_spd_cont_mout <= clk_flag_wire;
			WHEN OTHERS => clk_spd_cont_mout <= '0';
		END CASE;
	END PROCESS;
	
	fsm_U1: fsm PORT MAP(count_flag_wire, PB, clk_flag_wire, clk, reset_n, 
	load_rng_wire, en_rng_wire, load_SR_wire, en_counter_wire, 
	clk_spd_cont_wire, delay_unit_rst_wire, output_cont_wire, state);
	
	delay_unit_U2: counter PORT MAP(delay_value, clk, one, 
	delay_unit_reset, clk_flag_wire);
	
	counter_U3: counter PORT MAP(max_count, clk, clk_spd_cont_mout, 
	counter_reset, count_flag_wire);
	
	rng_U4: rng PORT MAP(seed, load_rng_wire, clk, reset_n, en_rng_wire, rand_num);
	
	shift_reg_U5: shift_reg PORT MAP(rand_num, load_SR_wire, clk_flag_wire,
	reset_n, sr_out_wire);
	
	d_ff_U6: d_ff PORT MAP(d_ff_wire, clk, reset_n, GPIO);
END model;