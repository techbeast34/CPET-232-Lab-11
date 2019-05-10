library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY d_ff IS
	PORT(
	D		:IN STD_LOGIC;
	clk		:IN STD_LOGIC;
	reset_n :IN STD_LOGIC;
	Q		:OUT STD_LOGIC);
END d_ff;

ARCHITECTURE model OF d_ff IS
BEGIN
	PROCESS(clk, reset_n, D)
	BEGIN
		IF(reset_n = '0') THEN
			Q <= '0';
		ELSIF(rising_edge(clk)) THEN
			Q <= D;
		END IF;
	END PROCESS;
END model;

