library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_gen is
	Port(
			clk_in : in STD_LOGIC;
			clk_out : out STD_LOGIC;
			clk_out2 : out STD_LOGIC
		);
	
end clk_gen;

architecture Behavioral of clk_gen is
	component clk_25
	Port(
			CLK_IN1 : in STD_LOGIC;
			RESET : in STD_LOGIC;
			CLK_OUT1 : out STD_LOGIC;
			CLK_OUT2 : out STD_LOGIC;
			LOCKED : out STD_LOGIC
		);
	end component;
	signal locked : STD_LOGIC;

begin
	clk_wiz_inst : clk_25
		Port map (	
			CLK_IN1 => clk_in,
			CLK_OUT1 => clk_out,
			CLK_OUT2 => clk_out2,
			RESET => '0',
			LOCKED => locked
		);
	

end Behavioral;

