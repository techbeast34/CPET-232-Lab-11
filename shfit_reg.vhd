library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY shift_reg IS
	PORT(
	input	  :IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	load	  :IN STD_LOGIC;
	enable	  :IN STD_LOGIC;
	reset_n	  :IN STD_LOGIC;
	output	  :OUT STD_LOGIC
	);
END shift_reg;

ARCHITECTURE model OF shift_reg IS
	SIGNAL reg :STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
	PROCESS(enable, reset_n, input, load)
	BEGIN
		IF(reset_n = '0') THEN
			reg <= "00000000";
		ELSIF(enable = '1') THEN
				IF(load = '1') THEN
					reg(7 DOWNTO 0) <= input;
				ELSE
					reg(7 DOWNTO 1) <= reg(6 DOWNTO 0);
					reg(0) <= '0';
				END IF;
		END IF;
	END PROCESS;
	output <= reg(7);
END model;

