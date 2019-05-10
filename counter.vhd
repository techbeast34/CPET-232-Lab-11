library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY counter IS
	PORT(
	max_value :IN STD_LOGIC_VECTOR(5 DOWNTO 0);
	clk 	  :IN STD_LOGIC;
	enable	  :IN STD_LOGIC;
	reset_n	  :IN STD_LOGIC;
	flag	  :OUT STD_LOGIC);
END counter;

ARCHITECTURE model OF counter IS

SIGNAL count 	:UNSIGNED(5 DOWNTO 0) := "000000"; --Count
SIGNAL flag_int :STD_LOGIC := '0';
	
BEGIN
	PROCESS(clk, reset_n, max_value, count, enable)
	BEGIN
			IF(reset_n = '0') THEN
				flag_int <= '0';
			ELSE
				IF(rising_edge(clk)) THEN
					IF(enable = '1') THEN
						IF(count < (UNSIGNED(max_value) - 1)) THEN
							count <= count + 1;
							flag_int <= '0';
						ELSE
							count <= "000000";
							flag_int <= '1';
						END IF;
					END IF;
				END IF;
			END IF;
	END PROCESS;
	--Above process just counts up until "max_value" is reached, then outputs
	--"flag" to enable another component
	flag <= flag_int;

END model;

