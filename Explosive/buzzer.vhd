library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity buzzer is
	Port (Clk: in std_logic;
			buzzer_enable: in std_logic;
			buzzer_break: in std_logic;
			buzzer_rst: in std_logic;
			
			buzzers: out std_logic);
end buzzer;

architecture Behavioral of buzzer is
	 signal be: std_logic := '0';
	 signal timer : integer := 99;
    signal current_interval : integer := 2;
    signal clock_count : integer := 0;
    signal tone_count : integer := 0;
    signal beep_active : STD_LOGIC := '0';
    signal tone_signal : STD_LOGIC := '1';
    signal countdown_started : STD_LOGIC := '1'; 

    constant clk_2sec : integer := 20_000_000;
    constant clk_1sec : integer := 17_500_000;
    constant clk_0_5sec : integer := 15_500_000;
    -- constant clk_0_25sec : integer := 20_000_000 / 3;
    -- constant clk_0_125sec : integer := 20_000_000 / 4;
    constant tone_freq_initial : integer := 1_000; 
    constant tone_freq_final : integer := 20_000_000 / 500 / 2; 
	 signal sec_clk : integer range 0 to 20000000 := 20000000;
	 signal buzzer_clk: integer range 0 to 20000000 := 0;
	 signal sec_count: unsigned(25 downto 0);
	 signal sec_toggle: std_logic := '0';
	
	 signal current_tone_freq : integer := tone_freq_initial;
	 
begin

	process(Clk, buzzer_rst, buzzer_enable, timer)
	begin

		be <= buzzer_enable;
		if buzzer_rst = '1' and (timer = 0 or buzzer_break = '1') then
			timer <= 99;
			countdown_started <= '0';
			
			
		elsif rising_edge(Clk) then
			if buzzer_break = '0' and be = '1' then
				if countdown_started = '1' then
					 -- Determine the interval and tone frequency based on remaining time
					 if timer > 16 then
						  current_interval <= clk_2sec;
						  current_tone_freq <= tone_freq_initial;
					 elsif timer > 6 then
						  current_interval <= clk_1sec;
						  current_tone_freq <= tone_freq_initial;
					 elsif timer > 3 then
						  current_interval <= clk_0_5sec;
						  current_tone_freq <= tone_freq_initial;
					 end if;

					 -- Count clock cycles for beep intervals
					 if clock_count >= current_interval then
						  clock_count <= 0;
						  beep_active <= '1';
						  if timer > 0 then
								timer <= timer - 1;
						  else
								countdown_started <= '0'; -- Stop countdown when timer reaches zero
						  end if;
					 else
						  clock_count <= clock_count + 1;
					 end if;

						 -- Generate tone with variable frequency when beep is active
					 if beep_active = '1' then
						  if tone_count >= current_tone_freq then
								tone_count <= 0;
								tone_signal <= not tone_signal;
						  else
								tone_count <= tone_count + 1;
						  end if;

						  -- Stop the beep after a short duration (e.g., 0.1 sec)
						  if clock_count >= current_interval / 5 then
								beep_active <= '0';
						  end if;
					 else
						  tone_signal <= '0';
					 end if;
					
					if timer = 0 then
						beep_active <= '1';
						current_tone_freq <= tone_freq_final + 100;
					end if;
					
				else
					beep_active <= '1';
					current_tone_freq <= tone_freq_final + 100;
				end if;
				
			elsif buzzer_break = '0' and be = '0' then
				tone_signal <= '0';
			else 
				tone_signal <= '1';
				
			end if;
		end if;
  end process;
	 
    buzzers <= tone_signal;
end Behavioral;