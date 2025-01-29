library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity vga_health_display is
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
end vga_health_display;

architecture Behavioral of vga_health_display is

    -- VGA timing parameters for 640x480
    constant h_visible : integer := 640;
    constant h_front_porch : integer := 16;
    constant h_sync_pulse : integer := 96;
    constant h_back_porch : integer := 48;
    constant h_total : integer := 800;

    constant v_visible : integer := 480;
    constant v_front_porch : integer := 10;
    constant v_sync_pulse : integer := 2;
    constant v_back_porch : integer := 33;
    constant v_total : integer := 525;

    signal h_counter : integer range 0 to h_total - 1 := 0;
    signal v_counter : integer range 0 to v_total - 1 := 0;
	 
	 
	 signal display_active : STD_LOGIC;

	
begin

    -- Horizontal and vertical sync pulse generation
    process(clk)
    begin
        if rising_edge(clk) then
            if h_counter = h_total - 1 then
                h_counter <= 0;
                if v_counter = v_total - 1 then
                    v_counter <= 0;
                else
                    v_counter <= v_counter + 1;
                end if;
            else
                h_counter <= h_counter + 1;
            end if;
        end if;
    end process;

    -- Generate hsync and vsync pulses
    hsync <= '0' when (h_counter >= h_visible + h_front_porch and h_counter < h_visible + h_front_porch + h_sync_pulse) else '1';
    vsync <= '0' when (v_counter >= v_visible + v_front_porch and v_counter < v_visible + v_front_porch + v_sync_pulse) else '1';

process(h_counter, v_counter, health, score)
    variable center_x : integer := h_visible / 2;
    variable center_y : integer := v_visible / 2;
    variable point_size : integer := 60;  -- Size for health points
    variable point_spacing : integer := 100;  -- Spacing between health points
    
    constant square_size : integer := 20;  -- Size of smaller squares
    constant square_spacing : integer := 30;  -- Spacing between squares
    constant start_x : integer := 50;  -- Starting X position
    constant start_y : integer := v_visible - 100;  -- Starting Y position at bottom
begin
    -- Default background color (set before any conditions to ensure reset each cycle)
    red <= '0';
    green <= '0';
    blue <= '0';

    -- Turn the entire screen green if score reaches 5
    if to_integer(unsigned(score)) = 5 then
		if h_counter >= 0 and
               h_counter < h_visible  and
               v_counter >= 0 and
               v_counter < v_visible  then
        red <= '0';
        green <= '1';
        blue <= '0';  -- Green screen for score >= 5
		  end if;
    -- Turn the entire screen red if health reaches 0
    elsif health = "100" or gameover = '1' then
        if h_counter >= 0 and
               h_counter < h_visible  and
               v_counter >= 0 and
               v_counter < v_visible  then
		  red <= '1';
        green <= '0';
        blue <= '0';  -- Red screen for health = 0
		  end if;
    else
        -- Draw squares at the bottom based on score
        for i in 0 to 4 loop
            if h_counter >= start_x + i * square_spacing - square_size/2 and
               h_counter < start_x + i * square_spacing + square_size/2 and
               v_counter >= start_y - square_size/2 and
               v_counter < start_y + square_size/2 then

                -- Check if score threshold is met to light up this square
                if i < to_integer(unsigned(score)) then
                    red <= '0';
                    green <= '1';
                    blue <= '0';  -- Green square when score reaches threshold
                else
                    red <= '1';
                    green <= '1';
                    blue <= '0';  -- Yellow square when score hasn't reached threshold
                end if;
            end if;
        end loop;

        -- Draw the first health point if health >= 1
        if h_counter >= center_x - point_spacing - point_size/2 and
           h_counter < center_x - point_spacing + point_size/2 and
           v_counter >= center_y - point_size/2 and
           v_counter < center_y + point_size/2 then
            if health <= "001" then
                red <= '1';
                green <= '0';
                blue <= '0';  -- Red when health is on
            end if;
        end if;

        -- Draw the second health point if health >= 2
        if h_counter >= center_x - point_size/2 and
           h_counter < center_x + point_size/2 and
           v_counter >= center_y - point_size/2 and
           v_counter < center_y + point_size/2 then
            if health <= "010" then
                red <= '1';
                green <= '0';
                blue <= '0';  -- Red when health is on
            end if;
        end if;

        -- Draw the third health point if health >= 3
        if h_counter >= center_x + point_spacing - point_size/2 and
           h_counter < center_x + point_spacing + point_size/2 and
           v_counter >= center_y - point_size/2 and
           v_counter < center_y + point_size/2 then
            if health <= "011" then
                red <= '1';
                green <= '0';
                blue <= '0';  -- Red when health is on

            end if;
        end if;
    end if;
end process;

end Behavioral;