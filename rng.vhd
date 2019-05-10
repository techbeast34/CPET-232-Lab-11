library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY rng IS		
	PORT(
	seed	:IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	load	:IN STD_LOGIC;
	clk		:IN STD_LOGIC;
	reset_n	:IN STD_LOGIC;
	enable	:IN STD_LOGIC;
	rand	:OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END rng;		
					
ARCHITECTURE model OF rng IS
	SIGNAL shift_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
	rand_num : PROCESS(clk, reset_n)
	BEGIN			
		IF(reset_n = '0') THEN
			shift_out <= "00000000";
		ELSIF(rising_edge(clk)) THEN
			IF (load = '1') THEN 
				shift_out <= seed;		
			ELSIF(enable = '1') THEN
				shift_out(7 DOWNTO 1) <= shift_out(6 DOWNTO 0);
				shift_out(0) <= (((shift_out(5) XOR shift_out(7)) XOR (shift_out(4))) XOR shift_out(3));				
			END IF; -- load
		END IF; -- clk
	END PROCESS;
	
	rand <= shift_out;
	
END model;