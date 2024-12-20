--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:22:53 11/21/2023
-- Design Name:   
-- Module Name:   /home/ise/Documents/timer_catur/test.vhd
-- Project Name:  timer_catur
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: main_timer
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test IS
END test;
 
ARCHITECTURE behavior OF test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT main_timer
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         SF_D : OUT  std_logic_vector(3 downto 0);
         LCD_E : OUT  std_logic;
         LCD_RS : OUT  std_logic;
         LCD_RW : OUT  std_logic;
         SF_CE0 : OUT  std_logic;
         LED : OUT  std_logic_vector(7 downto 0);
         PushWhite : IN  std_logic;
         PushBlack : IN  std_logic;
         Start : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal PushWhite : std_logic := '0';
   signal PushBlack : std_logic := '0';
   signal Start : std_logic := '0';

 	--Outputs
   signal SF_D : std_logic_vector(3 downto 0);
   signal LCD_E : std_logic;
   signal LCD_RS : std_logic;
   signal LCD_RW : std_logic;
   signal SF_CE0 : std_logic;
   signal LED : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: main_timer PORT MAP (
          clk => clk,
          reset => reset,
          SF_D => SF_D,
          LCD_E => LCD_E,
          LCD_RS => LCD_RS,
          LCD_RW => LCD_RW,
          SF_CE0 => SF_CE0,
          LED => LED,
          PushWhite => PushWhite,
          PushBlack => PushBlack,
          Start => Start
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		

      -- insert stimulus here 
		Start <= '1';
		wait for 15 ns;
		Start <= '0';
		wait for 40 ns;
		PushWhite <= '1';
		wait for 15 ns;
		PushWhite <= '0';
		
		wait for 30 ns;
		PushBlack <= '1';
		wait for 15 ns;
		PushBlack <= '0';
		
		wait for 15 ns;
		reset <= '1';
		wait for 15 ns;
		reset <= '0';

      wait;
   end process;

END;
