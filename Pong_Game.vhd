library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Pong_Game is
	port(	clk50_in : in std_logic;
			left_button : in std_logic;
			right_button : in std_logic;
			start : in std_logic;
			player_reset : in std_logic;
			redout : out std_logic_vector(9 downto 0);
			blueout : out std_logic_vector(9 downto 0);
			greenout : out std_logic_vector(9 downto 0);
			vs_out : out std_logic;
			hs_out : out std_logic;
			sync : out std_logic;
			blank : out std_logic;
			clk25_out : out std_logic;
			seven_0 : out std_logic_vector(6 downto 0);
			seven_1 : out std_logic_vector(6 downto 0);
			seven_2 : out std_logic_vector(6 downto 0);
			seven_3 : out std_logic_vector(6 downto 0);
			seven_4 : out std_logic_vector(6 downto 0);
			seven_5 : out std_logic_vector(6 downto 0);
			seven_6 : out std_logic_vector(6 downto 0);
			seven_7 : out std_logic_vector(6 downto 0)
			);
			
end Pong_Game;

architecture behavioral of Pong_Game is
signal clk_bar : std_logic;
signal clk_ball : std_logic;
signal clk25 : std_logic;
signal horizontal_count : std_logic_vector(9 downto 0);
signal vertical_count : std_logic_vector(9 downto 0);
signal reset : std_logic := '1';
signal score : integer := 0;
signal highscore : integer := 0;
constant HSIZE_L : integer := 170; -- tested
constant HSIZE_R : integer := 785; -- tested
constant VSIZE_T : integer := 30; -- tested
constant VSIZE_B : integer := 500; -- tested
constant BARWIDTH : integer := 40; -- tested
constant BARHEIGHT : integer := 5; -- tested
constant BALLSIZE : integer := 4; -- tested
constant ZERO : integer := 0;
constant FROMBOTTOM : integer := 5;

begin
clk25_out <= clk25;
sync <= '0';
blank <= '1';

seven_2 <= "1111111";
seven_3 <= "1111111";
seven_4 <= "1111111";
seven_5 <= "1111111";

process (clk50_in)
begin
	if clk50_in'event and clk50_in='1' then
		if (clk25 = '0') then
			clk25 <= '1';
		else
			clk25 <= '0';
		end if;
	end if;
end process;

process (clk25)
variable BARWIDTH_L : integer := ((HSIZE_L + HSIZE_R) / 2) - (BARWIDTH / 2);
variable BARWIDTH_R : integer := ((HSIZE_L + HSIZE_R) / 2) + (BARWIDTH / 2);
variable BARHEIGHT_B : integer := (VSIZE_B - 5);
variable BARHEIGHT_T : integer := (VSIZE_B - 5 - BARHEIGHT);
variable BALL_LEFT : integer := ((HSIZE_L + HSIZE_R) / 2) - (BALLSIZE);
variable BALL_RIGHT : integer := ((HSIZE_L + HSIZE_R) / 2) + (BALLSIZE);
variable BALL_B : integer := (VSIZE_T + 20) + (BALLSIZE);
variable BALL_T : integer := (VSIZE_T + 20) - (BALLSIZE);
variable count_bar : integer := 0;
variable count_ball : integer := 0;
variable count_hold : integer := 0;
variable direction : integer := 0;
begin
	if clk25'event and clk25 = '1' then
		if (player_reset = '0' or reset = '0') then
			BARWIDTH_L := ((HSIZE_L + HSIZE_R) / 2) - (BARWIDTH / 2);
			BARWIDTH_R := ((HSIZE_L + HSIZE_R) / 2) + (BARWIDTH / 2);
			BARHEIGHT_B := (VSIZE_B - 5);
			BARHEIGHT_T := (VSIZE_B - 5 - BARHEIGHT);
			BALL_LEFT := ((HSIZE_L + HSIZE_R) / 2) - (BALLSIZE);
			BALL_RIGHT := ((HSIZE_L + HSIZE_R) / 2) + (BALLSIZE);
			BALL_B := (VSIZE_T + 20) + (BALLSIZE);
			BALL_T := (VSIZE_T + 20) - (BALLSIZE);
			count_bar := 0;
			count_ball := 0;
			score <= 0;
			direction := direction + 1;
			if(direction = 4) then
				direction := 0;
			end if;
		end if;
		
			if(reset = '0') then
				count_hold := count_hold + 1;
				if(count_hold = 30000000) then
					count_hold := 0;
					reset <= '1';
				end if;
			end if;
		
		if(start = '1' and count_hold = 0) then
			count_bar := count_bar + 1;
			if(count_bar = 130000) then
				clk_bar <= '1';
				count_bar := 0;
			end if;
		
			count_ball := count_ball + 1;
			if(count_ball = 240000) then
				clk_ball <= '1';
				count_ball := 0;
			end if;
		
		
			-- BACKGROUND
			if (((horizontal_count >= HSIZE_L ) 
				and (horizontal_count < HSIZE_R ) 
				and (vertical_count >= VSIZE_T ) 
				and (vertical_count < VSIZE_B ))) 
				then
				redout <= "0000000000";
				greenout <= "0000000000";
				blueout <= "0011111111";
			else
				redout <= "0000000000";
				greenout <= "0000000000";
				blueout <= "0000000000";
			end if;

			-- BAR CONTROL
			if(clk_bar = '1') 
				then
				clk_bar <= '0';
				if((left_button = '0' and right_button = '1') and (BARWIDTH_L - 5 >= HSIZE_L))
					then
					BARWIDTH_L := BARWIDTH_L - 1;
					BARWIDTH_R := BARWIDTH_R - 1;
				elsif((left_button = '1' and right_button = '0') and (BARWIDTH_R + 5 <= HSIZE_R))
					then
					BARWIDTH_L := BARWIDTH_L + 1;
					BARWIDTH_R := BARWIDTH_R + 1;
				end if;
			end if;
		
			-- BAR
			if (((horizontal_count >= BARWIDTH_L ) 
				and (horizontal_count < BARWIDTH_R ) 
				and (vertical_count >= BARHEIGHT_T ) 
				and (vertical_count < BARHEIGHT_B ))) 
				then
				redout <= "1111111111";
				greenout <= "0000000000";
				blueout <= "0000000000";
			end if;
		
			-- BALL CONTROL
			if(clk_ball = '1') 
				then
				clk_ball <= '0';
				if(direction = 0) then -------------------
					if(BALL_LEFT - 1 = HSIZE_L) then
						direction := 1;
					elsif((BALL_B + 1 = VSIZE_B - 10) and (BALL_RIGHT >= BARWIDTH_L and BALL_LEFT <= BARWIDTH_R)) then
						direction := 3;
						score <= score + 1;
					elsif(BALL_B = VSIZE_B) then
						if(score > highscore) then
							highscore <= score;
						end if;
						reset <= '0';
					else
						BALL_LEFT := BALL_LEFT - 1;
						BALL_RIGHT := BALL_RIGHT - 1;
						BALL_B := BALL_B + 1;
						BALL_T := BALL_T + 1;
					end if;
				end if;
				if(direction = 1) then -------------------
					if(BALL_RIGHT + 1 = HSIZE_R) then
						direction := 0;
					elsif((BALL_B + 1 = VSIZE_B - 10) and (BALL_RIGHT >= BARWIDTH_L and BALL_LEFT <= BARWIDTH_R)) then
						direction := 2;
						score <= score + 1;
					elsif(BALL_B = VSIZE_B) then
						reset <= '0';
						if(score > highscore) then
							highscore <= score;
						end if;						
					else
						BALL_LEFT := BALL_LEFT + 1;
						BALL_RIGHT := BALL_RIGHT + 1;
						BALL_B := BALL_B + 1;
						BALL_T := BALL_T + 1;
					end if;
				end if;				
				if(direction = 2) then
					if(BALL_RIGHT + 1 = HSIZE_R) then
						direction := 3;						
					elsif(BALL_T - 1 = VSIZE_T) then
						direction := 1;
					else
						BALL_LEFT := BALL_LEFT + 1;
						BALL_RIGHT := BALL_RIGHT + 1;
						BALL_B := BALL_B - 1;
						BALL_T := BALL_T - 1;
					end if;
				end if;				
				if(direction = 3) then
					if(BALL_LEFT - 1 = HSIZE_L) then
						direction := 2;						
					elsif(BALL_T - 1 = VSIZE_T) then
						direction := 0;
					else
						BALL_LEFT := BALL_LEFT - 1;
						BALL_RIGHT := BALL_RIGHT - 1;
						BALL_B := BALL_B - 1;
						BALL_T := BALL_T - 1;
					end if;
				end if;				
			end if;
		
			-- BALL
			if (((horizontal_count >= BALL_LEFT ) 
				and (horizontal_count < BALL_RIGHT ) 
				and (vertical_count >= BALL_T ) 
				and (vertical_count < BALL_B ))) 
				then
				redout <= "1111111111";
				greenout <= "1111111111";
				blueout <= "0000000000";
			end if;
	
			if (horizontal_count > "0000000000" )
				and (horizontal_count < "0001100001" ) -- 96+1 "0001100001
				then
				hs_out <= '0';
			else
				hs_out <= '1';
			end if;
			if (vertical_count > "0000000000" )
				and (vertical_count < "0000000011" ) -- 2+1
				then
				vs_out <= '0';
			else
				vs_out <= '1';
			end if;
	
			horizontal_count <= horizontal_count+"0000000001";
	
			if (horizontal_count="1100100000") then -- 800
				vertical_count <= vertical_count+"0000000001";
				horizontal_count <= "0000000000";
			end if;
	
			if (vertical_count="1000001001") then -- 521
				vertical_count <= "0000000000";
			end if;
		---
		else
			-- BACKGROUND
			if (((horizontal_count >= HSIZE_L ) 
				and (horizontal_count < HSIZE_R ) 
				and (vertical_count >= VSIZE_T ) 
				and (vertical_count < VSIZE_B ))) 
				then
				redout <= "0000000000";
				greenout <= "0000000000";
				blueout <= "0011111111";
			else
				redout <= "0000000000";
				greenout <= "0000000000";
				blueout <= "0000000000";
			end if;		
		
			-- BAR
			if (((horizontal_count >= BARWIDTH_L ) 
				and (horizontal_count < BARWIDTH_R ) 
				and (vertical_count >= BARHEIGHT_T ) 
				and (vertical_count < BARHEIGHT_B ))) 
				then
				redout <= "1111111111";
				greenout <= "0000000000";
				blueout <= "0000000000";
			end if;
		
			-- BALL
			if (((horizontal_count >= BALL_LEFT ) 
				and (horizontal_count < BALL_RIGHT ) 
				and (vertical_count >= BALL_T ) 
				and (vertical_count < BALL_B ))) 
				then
				redout <= "1111111111";
				greenout <= "1111111111";
				blueout <= "0000000000";
			end if;
	
			if (horizontal_count > "0000000000" )
				and (horizontal_count < "0001100001" ) -- 96+1 "0001100001
				then
				hs_out <= '0';
			else
				hs_out <= '1';
			end if;
			if (vertical_count > "0000000000" )
				and (vertical_count < "0000000011" ) -- 2+1
				then
				vs_out <= '0';
			else
				vs_out <= '1';
			end if;
	
			horizontal_count <= horizontal_count+"0000000001";
	
			if (horizontal_count="1100100000") then -- 800
				vertical_count <= vertical_count+"0000000001";
				horizontal_count <= "0000000000";
			end if;
	
			if (vertical_count="1000001001") then -- 521
				vertical_count <= "0000000000";
			end if;
		end if;
	end if;
	
end process;

process (clk25)
	begin
	
	if(score / 10 = 0) then -- ten's place
		seven_1 <= "1000000";
	elsif(score / 10 = 1) then
		seven_1 <= "1111001";
	elsif(score / 10 = 2) then
		seven_1 <= "0100100";
	elsif(score / 10 = 3) then
		seven_1 <= "0110000";
	elsif(score / 10 = 4) then
		seven_1 <= "0011001";
	elsif(score / 10 = 5) then
		seven_1 <= "0010010";
	elsif(score / 10 = 6) then
		seven_1 <= "0000010";
	elsif(score / 10 = 7) then
		seven_1 <= "1111000";
	elsif(score / 10 = 8) then
		seven_1 <= "0000000";
	elsif(score / 10 = 9) then
		seven_1 <= "0010000";
	end if;
	
	
	
	if(score mod 10 = 0) then -- one's place
		seven_0 <= "1000000";
	elsif(score mod 10 = 1) then
		seven_0 <= "1111001";
	elsif(score mod 10 = 2) then
		seven_0 <= "0100100";
	elsif(score mod 10 = 3) then
		seven_0 <= "0110000";
	elsif(score mod 10 = 4) then
		seven_0 <= "0011001";
	elsif(score mod 10 = 5) then
		seven_0 <= "0010010";
	elsif(score mod 10 = 6) then
		seven_0 <= "0000010";
	elsif(score mod 10 = 7) then
		seven_0 <= "1111000";
	elsif(score mod 10 = 8) then
		seven_0 <= "0000000";
	elsif(score mod 10 = 9) then
		seven_0 <= "0010000";
	end if;
	
	
	
	if(highscore / 10 = 0) then -- ten's place
		seven_7 <= "1000000";
	elsif(highscore / 10 = 1) then
		seven_7 <= "1111001";
	elsif(highscore / 10 = 2) then
		seven_7 <= "0100100";
	elsif(highscore / 10 = 3) then
		seven_7 <= "0110000";
	elsif(highscore / 10 = 4) then
		seven_7	<= "0011001";
	elsif(highscore / 10 = 5) then
		seven_7 <= "0010010";
	elsif(highscore / 10 = 6) then
		seven_7 <= "0000010";
	elsif(highscore / 10 = 7) then
		seven_7 <= "1111000";
	elsif(highscore / 10 = 8) then
		seven_7 <= "0000000";
	elsif(highscore / 10 = 9) then
		seven_7 <= "0010000";
	end if;
	
	if(highscore mod 10 = 0) then -- one's place
		seven_6 <= "1000000";
	elsif(highscore mod 10 = 1) then
		seven_6 <= "1111001";
	elsif(highscore mod 10 = 2) then
		seven_6 <= "0100100";
	elsif(highscore mod 10 = 3) then
		seven_6 <= "0110000";
	elsif(highscore mod 10 = 4) then
		seven_6 <= "0011001";
	elsif(highscore mod 10 = 5) then
		seven_6 <= "0010010";
	elsif(highscore mod 10 = 6) then
		seven_6 <= "0000010";
	elsif(highscore mod 10 = 7) then
		seven_6 <= "1111000";
	elsif(highscore mod 10 = 8) then
		seven_6 <= "0000000";
	elsif(highscore mod 10 = 9) then
		seven_6 <= "0010000";
	end if;
	
end process;

end behavioral;