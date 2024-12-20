----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:48:20 11/16/2023 
-- Design Name: 
-- Module Name:    main_timer - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.MATH_REAL.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main_timer is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           SF_D : out  STD_LOGIC_VECTOR (3 downto 0);
           LCD_E : out  STD_LOGIC;
           LCD_RS : out  STD_LOGIC;
           LCD_RW : out  STD_LOGIC;
           SF_CE0 : out  STD_LOGIC;
           LED : out  STD_LOGIC_VECTOR (7 downto 0);
           PushWhite : in  STD_LOGIC;
           PushBlack : in  STD_LOGIC;
           Start : in  STD_LOGIC);
end main_timer;

architecture Behavioral of main_timer is

	type tx_sequence is (high_setup, high_hold, oneus, low_setup, low_hold, fortyus, done);
	signal tx_state : tx_sequence := done;
	signal tx_byte : STD_LOGIC_VECTOR(7 downto 0);
	signal tx_init : STD_LOGIC := '0';
	type init_sequence is (idle, fifteenms, one, two, three, four, five, six, seven, eight, done);
	signal init_state : init_sequence := idle;
	signal init_init, init_done : STD_LOGIC := '0';
	signal i : integer range 0 to 750000 := 0;
	signal i2 : integer range 0 to 2000 := 0;
	signal i3 : integer range 0 to 82000 := 0;
	signal SF_D0, SF_D1 : STD_LOGIC_VECTOR(3 downto 0);
	signal LCD_E0, LCD_E1 : STD_LOGIC;
	signal mux : STD_LOGIC;
	type display_state is (init, function_set, entry_set, set_display, clr_display, pause1, pause2, set_addr, set_addr2, white_box, min1_1s, min1_2s, colon1, sec1_1s, sec1_2s, black_box, min2_1s, min2_2s, colon2, sec2_1s, sec2_2s, done);
	signal cur_state : display_state := init;

	signal timer_white : integer := 10;
	signal timer_black : integer := 10;
	signal count 		 : integer := 0;
	signal whiteIsRunning : boolean := false;
	signal blackIsRunning : boolean := false;
	signal startCheck : boolean := false;
	
	signal white1_min : integer := 48;
	signal white2_min : integer := 48;
	signal white1_sec : integer := 49;
	signal white2_sec : integer := 48;
	
	signal black1_min : integer := 48;
	signal black2_min : integer := 48;
	signal black1_sec : integer := 49;
	signal black2_sec : integer := 48;
	

begin

process(clk, reset)
	begin
		if (reset = '1') then
		
			timer_white <= 600;
			timer_black <= 600;
			white1_min <= 49;
			white2_min <= 48;
			white1_sec <= 48;
			white2_sec <= 48;
			
			black1_min <= 49;
			black2_min <= 48;
			black1_sec <= 48;
			black2_sec <= 48;
			count <= 0;
			whiteIsRunning <= false;
			blackIsRunning <= false;
			startCheck <= false;
			
		elsif (clk'event and clk = '1') then
			if (timer_white > 0) and (timer_black > 0) then 
			
				if (Start = '1' and not startCheck and not whiteIsRunning and not blackIsRunning) then
					startCheck <= true;
					whiteIsRunning <= true;
				elsif (PushWhite = '1' and startCheck and not blackIsRunning) then
					blackIsRunning <= true;
					whiteIsRunning <= false;
				elsif (PushBlack = '1' and startCheck and not whiteIsRunning) then
					whiteIsRunning <= true;
					blackIsRunning <= false;
				end if;
				
				if whiteIsRunning or blackIsRunning then
					if (count = 50000000 - 1) then
						if (whiteIsRunning and not blackIsRunning) then
							if(white2_sec = 48) then
								white2_sec <= 57;
								if(white1_sec = 48) then
									white1_sec <= 53;
									if (white2_min = 48) then
										white2_min <= 57;
										if (white1_min = 48) then
											white1_min <= 53;
										else
											white1_min <= white1_min - 1;
										end if;
									else
										white2_min <= white2_min - 1;
									end if;
								else
									white1_sec <= white1_sec - 1;
								end if;
							else
								white2_sec <= white2_sec - 1;
							end if;
							timer_white <= timer_white - 1;
						elsif (blackIsRunning and not whiteIsRunning) then
							if(black2_sec = 48) then
								black2_sec <=57;
								if(black1_sec = 48) then
									black1_sec <=53;
									if (black2_min = 48) then
										black2_min <=57;
										if (black1_min = 48) then
											black1_min <=53;
										else
											black1_min <= black1_min - 1;
										end if;
									else
										black2_min <= black2_min - 1;
									end if;
								else
									black1_sec <= black1_sec - 1;
								end if;
							else
								black2_sec <= black2_sec - 1;
							end if;
							timer_black <= timer_black - 1;
						end if;
						count <= 0;
					else
						count <= count + 1;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	LED <= tx_byte; --for diagnostic purposes
	SF_CE0 <= '1'; --disable intel strataflash
	LCD_RW <= '0'; --write only
	--The following "with" statements simplify the process of adding and removing states.
	--when to transmit a command/data and when not to
	with cur_state select
		tx_init <= '0' when init | pause1 | pause2 | done,
		'1' when others;
	--control the bus
	with cur_state select
		mux <= '1' when init,
		'0' when others;
	--control the initialization sequence
	with cur_state select
		init_init <= '1' when init,
		'0' when others;
	--register select
	with cur_state select
		LCD_RS <= '0' when function_set|entry_set|set_display|clr_display|set_addr|set_addr2 ,
		'1' when others;
	--what byte to transmit to lcd
	--refer to datasheet for an explanation of these values
	with cur_state select
		tx_byte <= "00101000" when function_set,
		"00000110" when entry_set,
		"00001100" when set_display,
		"00000001" when clr_display,
		"10000000" when set_addr,
		"11000000" when set_addr2,
		"11011011" when white_box,
		std_logic_vector(to_unsigned(white1_min, 8)) when min1_1s,
		std_logic_vector(to_unsigned(white2_min, 8)) when min1_2s,
		"00111010" when colon1,
		std_logic_vector(to_unsigned(white1_sec, 8)) when sec1_1s,
		std_logic_vector(to_unsigned(white2_sec, 8))when sec1_2s,
		"11111111" when black_box,
		std_logic_vector(to_unsigned(black1_min, 8)) when min2_1s,
		std_logic_vector(to_unsigned(black2_min, 8)) when min2_2s,
		"00111010" when colon2,
		std_logic_vector(to_unsigned(black1_sec, 8)) when sec2_1s,
		std_logic_vector(to_unsigned(black2_sec, 8)) when sec2_2s,
		"00000000" when others;
	--main state machine
	display: process(clk, reset)

	begin
		
		if(reset='1') then
		cur_state <= function_set;
		elsif(clk='1' and clk'event) then
		case cur_state is
	--refer to intialize state machine below
			when init =>
				if(init_done = '1') then
				cur_state <= function_set;
				else
				cur_state <= init;
				end if;
	--every other state but pause uses the transmit state machine
			when function_set =>
				if(i2 = 2000) then
				cur_state <= entry_set;
				else
				cur_state <= function_set;
				end if;
			when entry_set =>
				if(i2 = 2000) then
				cur_state <= set_display;
				else
				cur_state <= entry_set;
				end if;
			when set_display =>
				if(i2 = 2000) then
				cur_state <= clr_display;
				else
				cur_state <= set_display;
				end if;
			when clr_display =>
				i3 <= 0;
				if(i2 = 2000) then
				cur_state <= pause1;
				else
				cur_state <= clr_display;
				end if;
			when pause1 =>
				if(i3 = 82000) then
				cur_state <= set_addr;
				i3 <= 0;
				else
				cur_state <= pause1;
				i3 <= i3 + 1;
				end if;
			when set_addr =>
				if(i2 = 2000) then
				cur_state <= white_box;
				else
				cur_state <= set_addr;
				end if;
			when white_box =>
				if i2 = 2000 then
				cur_state <= min1_1s;
				else
				cur_state <= white_box;
				end if;
			when min1_1s =>
				if (i2 = 2000) then
				cur_state <= min1_2s;
				else
				cur_state <= min1_1s;
				end if;
			
			when min1_2s =>
				if(i2 = 2000) then
				cur_state <= colon1;
				else
				cur_state <= min1_2s;
				end if;
			when colon1 =>
				if(i2 = 2000) then
				cur_state <= sec1_1s;
				else
				cur_state <= colon1;
				end if;
			when sec1_1s =>
				if(i2 = 2000) then
				cur_state <= sec1_2s;
				else
				cur_state <= sec1_1s;
				end if;
			when sec1_2s =>
				if(i2 = 2000) then
				cur_state <= set_addr2;
				else
				cur_state <= sec1_2s;
				end if;	
				
			when set_addr2 =>
				if(i2 = 2000) then
				cur_state <= black_box;
				
				else
				cur_state <= set_addr2;
				end if;
			when black_box =>
				if i2 = 2000 then
				cur_state <= min2_1s;
				else
				cur_state <= black_box;
				end if;	
			when min2_1s =>
				if i2 = 2000 then
				cur_state <= min2_2s;
				else
				cur_state <= min2_1s;
				end if;	
		when min2_2s =>
				if i2 = 2000 then
				cur_state <= colon2;
				else
				cur_state <= min2_2s;
				end if;	
		when colon2 =>
				if i2 = 2000 then
				cur_state <= sec2_1s;
				else
				cur_state <= colon2;
				end if;	
		when sec2_1s =>
				if i2 = 2000 then
				cur_state <= sec2_2s;
				else
				cur_state <= sec2_1s;
				end if;
			when sec2_2s =>
				if i2 = 2000 then
				cur_state <= pause2;
				else
				cur_state <= sec2_2s;
				end if;
			when pause2 =>
				if(i3 = 82000) then
				cur_state <= done;
				i3 <= 0;
				else
				cur_state <= pause2;
				i3 <= i3 + 1;
				end if;				
			when done =>
				cur_state <= clr_display;
		end case;
		end if;
	end process display;
with mux select
	SF_D <= SF_D0 when '0', --transmit
	SF_D1 when others; --initialize
with mux select
	LCD_E <= LCD_E0 when '0', --transmit
	LCD_E1 when others; --initialize
	--specified by datasheet
transmit : process(clk, reset, tx_init)
begin
	if(reset='1') then
		tx_state <= done;
	elsif(clk='1' and clk'event) then
		case tx_state is
			when high_setup => --40ns
				LCD_E0 <= '0';
				SF_D0 <= tx_byte(7 downto 4);
				if(i2 = 2) then
					tx_state <= high_hold;
					i2 <= 0;
				else
					tx_state <= high_setup;
					i2 <= i2 + 1;
				end if;
			when high_hold => --230ns
				LCD_E0 <= '1';
				SF_D0 <= tx_byte(7 downto 4);
				if(i2 = 12) then
					tx_state <= oneus;
					i2 <= 0;
				else
					tx_state <= high_hold;
					i2 <= i2 + 1;
				end if;															
			when oneus =>
				LCD_E0 <= '0';
				if(i2 = 50) then
					tx_state <= low_setup;
					i2 <= 0;
				else
					tx_state <= oneus;
					i2 <= i2 + 1;
				end if;
			when low_setup =>
				LCD_E0 <= '0';
				SF_D0 <= tx_byte(3 downto 0);
				if(i2 = 2) then
					tx_state <= low_hold;
					i2 <= 0;
				else
					tx_state <= low_setup;
					i2 <= i2 + 1;
				end if;
			when low_hold =>
				LCD_E0 <= '1';
				SF_D0 <= tx_byte(3 downto 0);
				if(i2 = 12) then
					tx_state <= fortyus;
					i2 <= 0;
				else
					tx_state <= low_hold;
					i2 <= i2 + 1;
				end if;
			when fortyus =>
				LCD_E0 <= '0';
				if(i2 = 2000) then
					tx_state <= done;
					i2 <= 0;
				else
					tx_state <= fortyus;
					i2 <= i2 + 1;
				end if;
			when done =>
				LCD_E0 <= '0';
				if(tx_init = '1') then
					tx_state <= high_setup;
					i2 <= 0;
				else
					tx_state <= done;
					i2 <= 0;
				end if;
		end case;
	end if;
end process transmit;
--specified by datasheet
power_on_initialize: process(clk, reset, init_init) --power on initialization sequence
begin
	if(reset='1') then
		init_state <= idle;
		init_done <= '0';
	elsif(clk='1' and clk'event) then
		case init_state is
			when idle =>
				init_done <= '0';
				if(init_init = '1') then
					init_state <= fifteenms;
					i <= 0;
				else
					init_state <= idle;
					i <= i + 1;
				end if;
			when fifteenms =>
				init_done <= '0';
				if(i = 750000) then
					init_state <= one;
					i <= 0;
				else
					init_state <= fifteenms;
					i <= i + 1;
				end if;
			when one =>
				SF_D1 <= "0011";
				LCD_E1 <= '1';
				init_done <= '0';
				if(i = 11) then
					init_state<=two;
					i <= 0;
				else
					init_state<=one;
					i <= i + 1;
				end if;
			when two =>
				LCD_E1 <= '0';
				init_done <= '0';
				if(i = 205000) then
					init_state<=three;
					i <= 0;
				else
					init_state<=two;
					i <= i + 1;
				end if;
			when three =>
				SF_D1 <= "0011";
				LCD_E1 <= '1';
				init_done <= '0';
				if(i = 11) then
					init_state<=four;
					i <= 0;
				else
					init_state<=three;
					i <= i + 1;
				end if;
			when four =>
				LCD_E1 <= '0';
				init_done <= '0';
				if(i = 5000) then
					init_state<=five;
					i <= 0;
				else
					init_state<=four;
					i <= i + 1;
				end if;
			when five =>
				SF_D1 <= "0011";
				LCD_E1 <= '1';
				init_done <= '0';
				if(i = 11) then
					init_state<=six;
					i <= 0;
				else
					init_state<=five;
					i <= i + 1;
				end if;
			when six =>
				LCD_E1 <= '0';
				init_done <= '0';
				if(i = 2000) then
					init_state<=seven;
					i <= 0;
				else
					init_state<=six;
					i <= i + 1;
				end if;
			when seven =>
				SF_D1 <= "0010";
				LCD_E1 <= '1';
				init_done <= '0';
				if(i = 11) then
					init_state<=eight;
					i <= 0;
				else
					init_state<=seven;
					i <= i + 1;
				end if;
			when eight =>
				LCD_E1 <= '0';
				init_done <= '0';
				if(i = 2000) then
					init_state<=done;
					i <= 0;
				else
					init_state<=eight;
					i <= i + 1;
				end if;
			when done =>
				init_state <= done;
				init_done <= '1';
		end case;
	end if;
	end process power_on_initialize;
end Behavioral;

