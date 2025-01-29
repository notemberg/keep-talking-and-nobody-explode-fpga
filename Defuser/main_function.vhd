library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_function is
	Port(
		  Clk: in std_logic;
		  output_bits : inout std_logic_vector(7 downto 0);
		  required_bits : inout std_logic_vector(7 downto 0);
		  input_bits : in std_logic_vector (7 downto 0);
		  
		  confirmed_button: in std_logic := '0';
		  ans_signal : in std_logic := '0';
		  break : in STD_LOGIC :='0';
		  reseto : in STD_LOGIC :='0';
		  
		  Common: out std_logic_vector (3 downto 0);
		  Segment: out std_logic_vector (6 downto 0);
		  
		  debounced_led : out std_logic := '0';
		  required_led : out std_logic_vector (7 downto 0);
		  
		  pass : out std_logic;
	     failed : out std_logic;
		  
		  failed_c : out std_logic_vector (2 downto 0);
		  pass_c : out std_logic_vector (2 downto 0);
		  
		  current : out std_logic_vector (2 downto 0) := "000";
		  next_s : out std_logic_vector (2 downto 0) := "000"
		  );
end main_function;

architecture Behavioral of main_function is


	function AND8bits(st_bits, nd_bits: std_logic_vector (7 downto 0)) return std_logic_vector is
		variable output_bits : std_logic_vector (7 downto 0);
	begin
		for i in 0 to 7 loop
			output_bits(i) := st_bits(i) and nd_bits(i);
		end loop;
		return output_bits;
	end function;
	
	function OR8bits(st_bits, nd_bits: std_logic_vector (7 downto 0)) return std_logic_vector is
		variable output_bits : std_logic_vector (7 downto 0);
	begin
		for i in 0 to 7 loop
			output_bits(i) := st_bits(i) or nd_bits(i);
		end loop;
		return output_bits;
	end function;
	
	function XOR8bits(st_bits, nd_bits: std_logic_vector (7 downto 0)) return std_logic_vector is
		variable output_bits : std_logic_vector (7 downto 0);
	begin
		for i in 0 to 7 loop
			output_bits(i) := (st_bits(i) xor nd_bits(i));
		end loop;
		return output_bits;
	end function;
	
	function bcd7segment (bits :  std_logic_vector (3 downto 0)) return std_logic_vector is
		variable segments : std_logic_vector (6 downto 0); 
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
	
	
	--random operation
	 function lfsr3_next(state: unsigned(2 downto 0)) return unsigned is
        variable new_state: unsigned(2 downto 0);
    begin
        new_state := (state(1) xor state(0)) & state(2 downto 1);
		  
		   if new_state > "101" then
				new_state := new_state - "110";
			end if;
			
        return new_state;
    end function lfsr3_next;
	 
	 --random num
	 function lfsr8_next(state, taps : unsigned(7 downto 0)) return unsigned is
		 variable feedback: std_logic;
		 variable new_state: unsigned(7 downto 0);
	 begin
		 feedback := '0';
		 for i in 0 to 7 loop
			  if taps(i) = '1' then
					feedback := feedback xor state(i);
			  end if;
		 end loop;

		 new_state := feedback & state(7 downto 1);
		 return new_state;
	 end function lfsr8_next;
	 
	signal operations: std_logic_vector (2 downto 0);

	
	signal pass_count: std_logic_vector (2 downto 0) := "000";
	signal failed_count: std_logic_vector (2 downto 0) := "000";
	signal failed_internal : STD_LOGIC :='0' ;
	signal common_clk: std_logic_vector (15 downto 0);
	signal common_stage: std_logic_vector (1 downto 0);
	signal operators: std_logic_vector (2 downto 0);
	
	signal stable_counter : integer range 0 to 500000 := 0;  
   signal button_stable : std_logic := '0';
   signal last_button_state : std_logic := '0';
   signal debounced_button : std_logic;
	
	signal slow_clk : std_logic := '0';
	signal slow_clk_counter: unsigned(14 downto 0) := (others => '0');
	
	signal free_running_counter : unsigned(7 downto 0) := (others => '0');
	
	signal current_state : std_logic_vector(2 downto 0) := "000";
	signal next_state : std_logic_vector(2 downto 0) := "000";
	
begin
	--random clock
	process(Clk)
    begin
        if rising_edge(Clk) then
            free_running_counter <= free_running_counter + 1;
        end if;
    end process;
	 
	--slow clock
	process(Clk)
	 begin
		if rising_edge(Clk) then
			if slow_clk_counter >= 10000 then
				slow_clk <= not slow_clk;
				slow_clk_counter <= (others => '0');
			else
				slow_clk_counter <= slow_clk_counter + 1;
			end if;
		end if;
	 end process;
	--debounced			
    process(Clk)
    begin
        if rising_edge(Clk) then
            if confirmed_button /= last_button_state then
                stable_counter <= 0;
            else
                if stable_counter < 12000 then
                    stable_counter <= stable_counter + 1;
                end if;
            end if;
            
            if stable_counter >= 12000 then
                button_stable <= confirmed_button;
            end if;

            last_button_state <= confirmed_button;
        end if;
    end process;

   debounced_button <= button_stable; 
	debounced_led <= debounced_button ;	 
	
	process(Clk)
	begin
		if rising_edge(Clk) then
			common_clk <= std_logic_vector(unsigned(common_clk) + 1);
		end if;
	end process;
	
	common_stage <= common_clk(15 downto 14);
	failed_c <= failed_count;
	pass_c <= pass_count;
	
	

	process(operations, pass_count, failed_count, output_bits, debounced_button)
			variable lfsr_state1 : unsigned(7 downto 0);
			variable lfsr_state2 : unsigned(7 downto 0);
			variable equal: boolean;
			variable in_currents_state : std_logic_vector(2 downto 0) := "000";
			variable in_operation : STD_LOGIC_VECTOR(2 downto 0):= "000";
			variable start_bit : STD_LOGIC_VECTOR(7 downto 0):= "00000000"; --required
			variable target_bit : STD_LOGIC_VECTOR(7 downto 0):= "00000000"; --target
			variable passc_in : std_logic_vector (2 downto 0) := "000";
			variable failc_in : std_logic_vector (2 downto 0) := "000";
			variable failing : std_logic :='0';
	begin
	
		if rising_edge(debounced_button) then
			if break = '0' then	
				case in_currents_state is
					when "000" =>
					  passc_in  := "000";
						failing := '0';
					  failc_in := "000";
					  in_currents_state := "111";
					  -- Initialize LFSRs with counter value for randomness on reset
					 
					when "111" =>
						lfsr_state1 := free_running_counter;
					   lfsr_state2 := free_running_counter xor "10101010";  -- Slightly different seed for second LFS
						in_operation := std_logic_vector(lfsr3_next(lfsr_state1(2 downto 0)));
						start_bit := std_logic_vector(lfsr8_next(lfsr_state2, lfsr_state1));
						target_bit := std_logic_vector(lfsr8_next(lfsr_state1, lfsr_state2));
						in_currents_state := "001";	
						case in_operation is
							when "000" => 
								start_bit :=  "11111111";
							when "001" =>
								start_bit := "00000000";
							when "010" =>
								start_bit := "11010000";
							when others =>
								start_bit := start_bit ;
							end case;
						
					when "001" =>
						in_currents_state := "101";
						
					when "101" =>		
						case in_operation is
							when "000" => 
								equal := (target_bit = AND8bits(start_bit, input_bits));
							when "001" =>
								equal := (target_bit = OR8bits(start_bit, input_bits));
							when "010" =>
								equal := (target_bit = XOR8bits(start_bit, input_bits));
							when "011" =>
								equal := (target_bit = std_logic_vector(shift_left(unsigned(input_bits), to_integer(unsigned(start_bit)))));
							when "100" =>
								equal := (target_bit = input_bits);
							when others =>
								equal := false;
						end case;
						
						 
						if (equal = true) then
							passc_in  := std_logic_vector(unsigned(passc_in ) + 1);
						else
							failc_in := std_logic_vector(unsigned(failc_in) + 1);
						end if;
						
						
						if to_integer(unsigned(failc_in)) >= 3 then
							in_currents_state := "010";
							failing := '1';
						elsif to_integer(unsigned(passc_in )) >= 5 then
							in_currents_state := "011";
							failing := '1';
						else 
							in_currents_state := "111";
						end if;
									
					--when "010" =>
						--failed_count <= "000";
						--current_state <= "000";	
						
					--when "011" =>
						--pass_count <= "000";
						--current_state <= "000";
		
					
					when others =>
						in_currents_state := "000";
					
				end case;
			elsif (failed_internal = '1' or break = '1') and reseto = '1' then
				in_currents_state := "000";
			else
				in_currents_state := "010";	
		 end if;
		end if;
		
		required_bits <= start_bit;
		output_bits <= target_bit;
		operations <= in_operation;
		current_state <= 	in_currents_state;
		pass_count <=  passc_in;
		 failed_count <= failc_in;
		 failed <= failing;
	end process;
	
	current <= current_state;
	pass_c <= pass_count;
	operators <= operations;
	
	process(clk, common_stage, operators, current_state)
	begin
		if rising_edge(clk) then
			case current_state is
				when "001" =>
					required_led <= required_bits (7 downto 0);
					case operators is 
							when "000" =>
								case common_stage is
									when "00" =>
										Common <= "1110";
										Segment <= "0111101";
								
									when "01" =>
										Common <= "1101";
										Segment <= "1110111";
								
									when "10" =>
										Common <= "1011";
										Segment <= bcd7segment(output_bits(3 downto 0));
									
									when "11" =>
										Common <= "0111";
										Segment <= bcd7segment(output_bits(7 downto 4));
									
									when others =>
										Common <= "1111";
								end case;
								
							when "001" =>
								case common_stage is
									when "00" =>
										Common <= "1110";
										Segment <= "0000101";
								
									when "01" =>
										Common <= "1101";
										Segment <= "1111110";
								
									when "10" =>
										Common <= "1011";
										Segment <= bcd7segment(output_bits(3 downto 0));
									
									when"11" =>
										Common <= "0111";
										Segment <= bcd7segment(output_bits(7 downto 4));
										
									when others =>
										Common <= "1111";
								end case;
								
							when "010" =>
								case common_stage is
									when "00" =>
										Common <= "1110";
										Segment <= "0000101";
								
									when "01" =>
										Common <= "1101";
										Segment <= "0110001";
								
									when "10" =>
										Common <= "1011";
										Segment <= bcd7segment(output_bits(3 downto 0));
									
									when "11" =>
										Common <= "0111";
										Segment <= bcd7segment(output_bits(7 downto 4));
										
									when others =>
										Common <= "1111";
								end case;
								
							when "011" =>
								case common_stage is
									when "00" =>
										Common <= "1110";
										Segment <= "0001110";
								
									when "01" =>
										Common <= "1101";
										Segment <= "1011011";
								
									when "10" =>
										Common <= "1011";
										Segment <= bcd7segment(output_bits(3 downto 0));
									
									when "11" =>
										Common <= "0111";
										Segment <= bcd7segment(output_bits(7 downto 4));
									
									when others =>
										Common <= "1111";
								end case;
								
							when "100" =>
								case common_stage is
									when "00" =>
										Common <= "1110";
										Segment <= "0000000";
									
									when "01" =>
										Common <= "1101";
										Segment <= "0000000";
									
									when "10" =>
										Common <= "1011";
										Segment <= bcd7segment(output_bits(3 downto 0));
										
									when "11" =>
										Common <= "0111";
										Segment <= bcd7segment(output_bits(7 downto 4));
										
									when others =>
										Common <= "1111";					
								end case;
								
							when others => 
								Common <= "1111";
								Segment <= (others => '0');
						end case;
						
					when "010" =>
						failed_internal <= '1';
						case common_stage is
							when "00" =>
								Common <= "1110";
								Segment <= "1000111";
							
							when "01" =>
								Common <= "1111";
								Segment <= "0000000";
							
							when "10" =>
								Common <= "1111";
								Segment <= bcd7segment(output_bits(3 downto 0));
								
							when "11" =>
								Common <= "1111";
								Segment <= bcd7segment(output_bits(7 downto 4));
								
							when others =>
								Common <= "1111";					
						end case;
						
					when "011" =>
						pass <= '1';
						case common_stage is
							when "00" =>
								Common <= "1110";
								Segment <= "0001111";
						
							when "01" =>
								Common <= "1111";
								Segment <= "1011011";
						
							when "10" =>
								Common <= "1111";
								Segment <= bcd7segment(output_bits(3 downto 0));
							
							when "11" =>
								Common <= "1111";
								Segment <= bcd7segment(output_bits(7 downto 4));
							
							when others =>
								Common <= "1111";
						end case;
					
					when "000" =>
						pass <= '0';
						failed_internal <= '0';
						required_led <= (others => '0');
						Common <= "1111";
				  
					when others => 
						required_led <= (others => '0');
						Common <= "1111";
				end case;
			end if;
	end process;
end Behavioral;