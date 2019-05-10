--*****************************************************************************
--***************************  VHDL Source Code  ******************************
--*********  Copyright 2017, Rochester Institute of Technology  ***************
--*****************************************************************************
--
--  DESIGNER NAME:  Jeanne Christman
--
--       LAB NAME:  System Design
--
--      FILE NAME:  KeyGenerator_tb.vhd
--
-------------------------------------------------------------------------------
--
--  DESCRIPTION
--
--    This test bench will provide input to test the KeyGenerator transmitter
--
-------------------------------------------------------------------------------
--
--  REVISION HISTORY
--
--  _______________________________________________________________________
-- |  DATE    | USER | Ver |  Description                                  |
-- |==========+======+=====+================================================
-- |          |      |     |
-- | 11/27/17 | JWC  | 1.0 | original 
-- |          |      |     |
--
--*****************************************************************************
--*****************************************************************************


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;           -- need for conv_std_logic_vector
USE ieee.std_logic_unsigned.ALL;        -- need for "+"
USE work.Common.ALL;

ENTITY KeyGenerator_tb IS
END KeyGenerator_tb;


ARCHITECTURE test OF KeyGenerator_tb IS

   -- Component Declaration for the Unit Under Test (UUT)
   -- if you use a package with the component defined then you do not need this
COMPONENT Lab11 is 
PORT ( clk, reset_n            : IN std_logic;
       seed               		 : IN std_logic_vector(7 downto 0);
		 PB, test_mode           : IN std_logic;
       GPIO                    : OUT std_logic;
	   state			:OUT state_type);
END COMPONENT;

   -- define signals for component ports
   SIGNAL clk_tb          : std_logic                    := '0';
   SIGNAL reset_n_tb      : std_logic                    := '0';
   SIGNAL pb_tb           : std_logic                    := '1';
   SIGNAL test_mode_tb    : std_logic                    := '1';
   SIGNAL seed_tb         : std_logic_vector(7 DOWNTO 0) := x"00";
   
   -- Outputs
   SIGNAL gpio_tb         : std_logic;
   SIGNAL state_tb		  : state_type;
   
   -- signals for test bench control
   SIGNAL sim_done : boolean := false;
   SIGNAL PERIOD_c : time    := 20 ns;  -- 50MHz

BEGIN  -- test

   -- component instantiation
   UUT : Lab11
      PORT MAP (
         clk           => clk_tb,
         reset_n       => reset_n_tb,
         PB            => pb_tb,
		   test_mode     => test_mode_tb,
         seed          => seed_tb,
         --
		   GPIO            => gpio_tb,
		   state => state_tb
         );

   -- This creates an clock_50 that will shut off at the end of the Simulation
   -- this makes a clock_50 that you can shut off when you are done.
   clk_tb <= NOT clk_tb AFTER PERIOD_C/2 WHEN (NOT sim_done) ELSE '0';


   ---------------------------------------------------------------------------
   -- NAME: Stimulus
   --
   -- DESCRIPTION:
   --    This process will apply stimulus to the UUT.
   ---------------------------------------------------------------------------
   stimulus : PROCESS
   BEGIN
      -- de-assert all input except the reset which is asserted
      reset_n_tb  <= '0';
      pb_tb       <= '1';
      seed_tb     <= x"95";

      -- now lets sync the stimulus to the clk
      -- move stimulus 1ns after clock edge
      WAIT UNTIL clk_tb = '1';
      WAIT FOR 1 ns;
      WAIT FOR PERIOD_c*2;

      -- de-assert reset
      reset_n_tb <= '1';
      WAIT FOR PERIOD_c*2;
      
      --switches now are at "10010101"

      WAIT FOR PERIOD_c*100;
      pb_tb <= '0';
      WAIT FOR PERIOD_c*10;
		  pb_tb <= '1';
    
    --lock in the seed which is "10010101".  
    --The resultant transmit data will drop low for 1us for the start bit and then 
    --go "11101001" at a 100ns rate.
    --a 100ns rate means a new bit transmitted every 5 clock cycles

     WAIT FOR PERIOD_c*100;
 
 	   seed_tb  <= x"12";
	  --switches now are at "00010010"
    
      WAIT FOR PERIOD_c*10;
      pb_tb <= '0';
      WAIT FOR PERIOD_c*10;
		  pb_tb <= '1';

    --lock in the seed which is "00010010".  
    --The resultant transmit data will drop low for 1us for the start bit and then 
    --go "11100100" at a 100ns rate.
    --a 100ns rate means a new bit transmitted every 5 clock cycles
     WAIT FOR PERIOD_c*100;
      sim_done <= true;
     
report "simulation complete. This is not a self-checking testbench. You must verify your results manually. The first transmission should be 11101001 and the second should be 11100100.";
      -----------------------------------------------------------------------
      -- This Last WAIT statement needs to be here to prevent the PROCESS
      -- sequence from re starting.
      -----------------------------------------------------------------------
      WAIT;

   END PROCESS stimulus;

	


END test;
