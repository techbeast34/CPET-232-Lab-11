library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Common.ALL;

ENTITY fsm IS
	PORT(
	count_flag	:IN STD_LOGIC;
	PB			:IN STD_LOGIC;
	EN_Master	:IN STD_LOGIC;
	clk			:IN STD_LOGIC;
	reset_n		:IN STD_LOGIC;
	Load_RNG, EN_RNG, load_SR, EN_Counter, clock_spd_control,
	delay_unit_rst	:OUT STD_LOGIC;
	output_control	:OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	state		:OUT state_type);
END fsm;

ARCHITECTURE model OF fsm IS

	SIGNAL current_state, next_state : state_type;	
	
	-- PROCESS(current_state)
	-- BEGIN
		-- CASE(current_state) IS
			-- WHEN idle =>
			-- WHEN loadRNG =>
			-- WHEN enableRNG =>
			-- WHEN loadSR =>
			-- WHEN transmit =>
			-- WHEN OTHERS =>
		-- END CASE;
	-- END PROCESS;
	
	
BEGIN

	sync : PROCESS(reset_n, clk)
	BEGIN
		IF(reset_n = '0') THEN
			current_state <= idle;
		ELSIF(rising_edge(clk)) THEN
			IF(EN_Master = '1') THEN
				current_state <= next_state;
			END IF;
		END IF;
	END PROCESS;
	
	
	transition: PROCESS(current_state, PB, count_flag)
	BEGIN
		CASE(current_state) IS
			WHEN idle =>
				IF(PB = '0') THEN
					next_state <= loadRNG;
				ELSE
					next_state <= idle;
				END IF;
			WHEN loadRNG => next_state <= enableRNG;
			WHEN enableRNG =>
				IF(count_flag = '1') THEN
					next_state <= loadSR;
				END IF;
			WHEN loadSR =>
				next_state <= transmit;
			WHEN transmit =>
				IF(count_flag = '1') THEN
					next_state <= idle;
				END IF;
			WHEN OTHERS => next_state <= idle;
		END CASE;
	END PROCESS;
	
	loadRNG_out: PROCESS(next_state, clk, reset_n)
	BEGIN
		IF(reset_n = '0') THEN
			Load_RNG <= '0';
		ELSIF(rising_edge(clk)) THEN
				CASE(next_state) IS
					WHEN loadRNG => 
						Load_RNG <= '1';
					WHEN OTHERS => 
						Load_RNG <= '0';
				END CASE;
		END IF;
	END PROCESS;
	
	enableRNG_out: PROCESS(next_state, clk, reset_n)
	BEGIN
		IF(reset_n = '0') THEN
			EN_RNG <= '0';
		ELSIF(rising_edge(clk)) THEN
				CASE(next_state) IS
					WHEN enableRNG => 
						EN_RNG <= '1';
					WHEN OTHERS => 
						EN_RNG <= '0';
				END CASE;
		END IF;
	END PROCESS;
	
	enableCount_out: PROCESS(next_state, clk, reset_n)
	BEGIN
		IF(reset_n = '0') THEN
			EN_Counter <= '0';
		ELSIF(rising_edge(clk)) THEN
				CASE(next_state) IS
					WHEN enableRNG => 
						EN_Counter <= '1';
					WHEN transmit => 
						EN_Counter <= '1';
					WHEN OTHERS => 
						EN_Counter <= '0';
				END CASE;
		END IF;
	END PROCESS;
	
	loadSR_out: PROCESS(next_state, clk, reset_n)
	BEGIN
		IF(reset_n = '0') THEN
			load_SR <= '0';
		ELSIF(rising_edge(clk)) THEN
				CASE(next_state) IS
					WHEN loadSR => 
						load_SR <= '1';
					WHEN OTHERS => 
						load_SR <= '0';
				END CASE;
		END IF;
	END PROCESS;
	
	output_control_proc: PROCESS(next_state, clk, reset_n)
	BEGIN
		IF(reset_n = '0') THEN
			output_control <= "00";
		ELSIF(rising_edge(clk)) THEN
				CASE(next_state) IS
					WHEN loadSR =>
						output_control <= "00";	
					WHEN enableRNG => 
						output_control <= "01";
					WHEN transmit => 
						output_control <= "10";
					WHEN OTHERS => 
						output_control <= "01";
				END CASE;
		END IF;
	END PROCESS;
	
	clock_spd_control_out: PROCESS(next_state, clk, reset_n)
	BEGIN
		IF(reset_n = '0') THEN
			clock_spd_control <= '0';
		ELSIF(rising_edge(clk)) THEN
				CASE(next_state) IS
					WHEN enableRNG => 
						clock_spd_control <= '1';
					WHEN OTHERS => 
						clock_spd_control <= '0';
				END CASE;
		END IF;
	END PROCESS;
	
	delay_unit_rst_out: PROCESS(next_state, clk, reset_n)
	BEGIN
		IF(reset_n = '0') THEN
			delay_unit_rst <= '0';
		ELSIF(rising_edge(clk)) THEN
				CASE(next_state) IS
					WHEN OTHERS => 
						delay_unit_rst <= '1';
				END CASE;
		END IF;
	END PROCESS;
	
	state <= current_state;
	
END model;