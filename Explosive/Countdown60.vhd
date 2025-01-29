library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Countdown60 is
	Port(Clk: in std_logic;
			Break: in std_logic;
			Count_Enable: in std_logic;
			Count_rst: in std_logic;
			
			Common: out std_logic_vector(3 downto 0);
			Segment: out std_logic_vector(6 downto 0);
			time_out: out std_logic := '0');
end Countdown60;

architecture Behavioral of Countdown60 is
	function hex_to_7segment (bits :  std_logic_vector (3 downto 0)) return std_logic_vector is
		variable segments: std_logic_vector (6 downto 0); 
	begin
		case bits is 
			when "0000" => segments := "1111110";
			when "0001" => segments := "0110000";
			when "0010" => segments := "1101101";
			when "0011" => segments := "1111001";
			when "0100" => segments := "0110011";
			when "0101" => segments := "1011011";
			when "0110" => segments := "1011111";
			when "0111" => segments := "1110000";
			when "1000" => segments := "1111111";
			when "1001" => segments := "1111011";
			when "1010" => segments := "1110111";
			when "1011" => segments := "0011111";
			when "1100" => segments := "1001110";
			when "1101" => segments := "0111101";
			when "1110" => segments := "1001111";
			when "1111" => segments := "1000111";
			when others => segments := "0000000";
		end case;
		return segments;
	end function;
	
	signal ce: std_logic := '0';
	signal t_out: std_logic := '0';
	signal common_clk: unsigned(15 downto 14);
	signal common_stage: unsigned(1 downto 0);
	signal st_count: std_logic_vector(3 downto 0);
	signal nd_count: std_logic_vector(3 downto 0);
	signal sec_count: integer range 0 to 100 := 99;
	signal clk_count : unsigned(27 downto 0);
	signal countdown_started : STD_LOGIC := '0'; 
begin
	
	process(Clk, Count_rst, Break)
	begin
		ce <= Count_enable;
		if Count_rst = '1' and (t_out = '1' or Break = '1') then
			sec_count <= 99;
			time_out <= '0';
			countdown_started <= '0';
			
		elsif rising_edge(Clk) then
			common_clk <= common_clk + 1;
			if Break = '0' and ce = '1' then
				if clk_count = 20000000 then
					clk_count <= (others => '0');
					if sec_count > 0 then
						sec_count <= sec_count - 1;
						time_out <= '0';
						t_out <= '0';
					else
						t_out <= '1';
						time_out <= '1';
					end if;
				else
					clk_count <= clk_count + 1;
				end if;
			end if;
		else
			sec_count <= 0;
		end if;
	end process;
	
	common_stage <= common_clk (15 downto 14);
	
	st_count <= std_logic_vector(to_unsigned(sec_count mod 10, 4));
	nd_count <= std_logic_vector(to_unsigned(sec_count / 10, 4));
	
	process(common_stage, st_count, nd_count)
	begin
		case common_stage is
			when "00" =>
				Common <= "1110";
				Segment <= hex_to_7segment(st_count);
			when "01" =>
				Common <= "1101";
				Segment <= hex_to_7segment(nd_count);
			when others =>
				Common <= "1111";
		end case;
	end process;
end Behavioral;