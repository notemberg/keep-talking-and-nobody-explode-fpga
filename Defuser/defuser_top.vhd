
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity defuser is
    Port ( 
		clk_20mhz : in  STD_LOGIC;
          reset : in  STD_LOGIC;
          hsync : out  STD_LOGIC;
          vsync : out  STD_LOGIC;
			 red : out STD_LOGIC; -- R signals
		  green : out STD_LOGIC; -- G signals
		  blue : out STD_LOGIC; -- B signals
		  
		  OUTPUT : inout std_logic_vector(7 downto 0);
		  REQUIRED: inout std_logic_vector(7 downto 0);
		  
		  INPUT : in std_logic_vector (7 downto 0);
		  CHECKING : out std_logic_vector (7 downto 0);
		  operations: inout std_logic_vector (2 downto 0);
		  confirmed_button: in std_logic;
			buzz : out STD_LOGIC:='0';
			ready_button : in STD_LOGIC;
			ans_signal_in : in STD_LOGIC;
			others_break : in STD_LOGIC;
			self_break : out STD_LOGIC;
			self_ready_signal : out STD_LOGIC;
			others_ready: in STD_LOGIC;
			reset_signal : in STD_LOGIC;
  
		  Common: out std_logic_vector (3 downto 0);
		  Segment: out std_logic_vector (6 downto 0);
		  
		  debounced_led : out std_logic ;
		  required_led : out std_logic_vector (7 downto 0);
		  
		  pass: out std_logic;
	     failed: out std_logic;
		  
		  failed_c: out std_logic_vector (2 downto 0);
		  pass_c: out std_logic_vector (2 downto 0);
		  
		  current: out std_logic_vector (2 downto 0);
		  next_s: out std_logic_vector (2 downto 0) 
			  );
end defuser;

architecture Behavioral of defuser is
	
	signal clk_25mhz : STD_LOGIC;
	signal clk_20mhz_new : STD_LOGIC;
	signal locked : STD_LOGIC;
	signal ftoh : STD_LOGIC_VECTOR (2 downto 0);
	signal ptos : STD_LOGIC_VECTOR (2 downto 0);
	signal ans_in : STD_LOGIC;
	signal confirmed : STD_LOGIC:='0';
	signal gameover_signal : STD_LOGIC:='0';
	
	
	component clk_gen
		Port
		(
			clk_in : in STD_LOGIC;
			clk_out : out STD_LOGIC;
			clk_out2 : out STD_LOGIC
		);
	end component;
	
	component vga_health_display
		Port (
        clk : in STD_LOGIC; -- 25 MHz clock
        reset : in STD_LOGIC;
        hsync : out STD_LOGIC;
        vsync : out STD_LOGIC;
        red : out STD_LOGIC; -- R signals
		  green : out STD_LOGIC; -- G signals
		  blue : out STD_LOGIC; -- B signals
		  health : in STD_LOGIC_VECTOR(2 downto 0); -- Health points input (0-3)
		  score : in STD_LOGIC_VECTOR(2 downto 0);
		  gameover : in STD_LOGIC
    );
	end component;
	
	component main_function
	Port(
		  Clk: in std_logic;
		  output_bits : inout std_logic_vector(7 downto 0);
		  required_bits : inout std_logic_vector(7 downto 0);
		  input_bits : in std_logic_vector (7 downto 0);
		  confirmed_button: in std_logic;
		  ans_signal : in std_logic;
		  Common: out std_logic_vector (3 downto 0);
		  Segment: out std_logic_vector (6 downto 0);
		  reseto : in STD_LOGIC ;
		  debounced_led : out std_logic ;
		  required_led : out std_logic_vector (7 downto 0);
		  pass: out std_logic;
	     failed: out std_logic;
		  failed_c: out std_logic_vector (2 downto 0);
		  pass_c: out std_logic_vector (2 downto 0);
		  current: out std_logic_vector (2 downto 0) ;
		  next_s: out std_logic_vector (2 downto 0) 
		  );
	end component;

begin
	CHECKING <= INPUT;
	self_ready_signal <= ready_button;
	ans_in <= ans_signal_in;
	gameover_signal <= others_break;
	
	process(clk_20mhz, ready_button, others_ready)
	begin
		if rising_edge(clk_20mhz) then
			if ready_button = '1' and others_ready = '1' then
				confirmed <= '1';
			end if;
		end if;
	end process;
	
	
	
	clk_wiz_inst : clk_gen
		Port map (	
			clk_in => clk_20mhz,
			clk_out => clk_25mhz,
			clk_out2 => clk_20mhz_new
		);
		
	vga_display_inst : vga_health_display
		Port map (
			clk => clk_25mhz,
			reset => reset_signal,
			hsync => hsync,
			vsync => vsync,
			red => red,
			green => green,
			blue => blue,
			health => ftoh,
			score => ptos,
			gameover => others_break
		);
		
	main_isnt : main_function
		Port map
		(
		  Clk => clk_20mhz_new,
		  output_bits => OUTPUT,
		  required_bits => REQUIRED,
		  input_bits => INPUT,
		  confirmed_button => confirmed_button,
		  ans_signal => ans_in,
		  Common => Common,
		  Segment => Segment,
		  reseto => reset_signal,
		  debounced_led => debounced_led,
		  required_led => required_led,
		  pass => pass,
	     failed => self_break,
		  failed_c => ftoh,
		  pass_c => ptos,
		  current => current,
		  next_s => next_s 
			
		);
		

end Behavioral;

