library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity nd_board_top_layer is
	 Port(Clk: in std_logic;
			Switch: in std_logic_vector(7 downto 0);
			others_break: in std_logic;
			others_confirmed: in std_logic;
			reset: in std_logic := '0';
			reset_signal : out STD_LOGIC;
			self_confirmed_button: in std_logic;
			self_ans_button: in std_logic;
			LED : out std_logic_vector(7 downto 0);
			Common: out std_logic_vector(3 downto 0);
			Segment: out std_logic_vector(6 downto 0);
			ans: out std_logic_vector(7 downto 0);
			self_break: out std_logic;
			Top_buzzer: out std_logic;
			self_confirmed_signal: out std_logic;
			self_ans_signal: out std_logic
			);					
end nd_board_top_layer;

architecture Behavioral of nd_board_top_layer is
	component Countdown60
	Port (Clk: in std_logic;
			Break: in std_logic;
			Count_Enable: in std_logic;
			Count_rst: in std_logic;
			
			Common: out std_logic_vector(3 downto 0);
			Segment: out std_logic_vector(6 downto 0);
			time_out: out std_logic := '0');
	end component;
	
	component buzzer
	Port (Clk: in std_logic;
			buzzer_break: in std_logic := '0';
			buzzer_enable: in std_logic:= '0';
			buzzer_rst: in std_logic:= '0';
			buzzers: out std_logic
			);
	end component;
	
	signal confirmed : std_logic := '0';
	signal countdown_e : std_logic := '0';
	signal buzzer_e : std_logic := '0';
	signal ans_toggle: std_logic := '0';
	
	signal t_outi : STD_LOGIC :='0';

begin
	self_confirmed_signal <= self_confirmed_button;
	reset_signal <= reset;
	self_break <= t_outi;
	LED <= SWITCH;
	
	process(Clk,self_confirmed_button, others_confirmed)
	begin
		if rising_edge(Clk) then
			if self_confirmed_button = '1' and others_confirmed = '1' then
				confirmed <= '1';
			elsif reset = '1' and t_outi = '1' then
				confirmed <= '0';
			end if;
		end if;
	end process;
	
	process(Clk)
	begin
		if rising_edge(Clk) then
			if confirmed = '1' then
				countdown_e <= '1';
				buzzer_e <= '1';
			else
				countdown_e <= '0';
				buzzer_e <= '0';
			end if;
		end if;
	end process;

	ins1 : Countdown60
	Port map(
		Clk => Clk,
		Common => Common,
		Segment => Segment,
		time_out => t_outi,
		Break => others_break,
		Count_rst => reset,
		Count_Enable => countdown_e
		);
		
	ins2 : buzzer
	Port map(
		Clk => Clk,
		buzzers => Top_buzzer,
		buzzer_break => others_break,
		buzzer_rst => reset,
		buzzer_enable => buzzer_e
		);
	
	process(self_ans_button)
	begin
		if self_ans_button = '1' and confirmed = '1' then
			self_ans_signal <= self_ans_button;
			ans <= Switch;
		else
			self_ans_signal <= '0';
		end if;
	end process;
	
		
end Behavioral;

