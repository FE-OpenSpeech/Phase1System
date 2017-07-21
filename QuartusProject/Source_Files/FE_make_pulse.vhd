

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FE_make_pulse is
	port (
		clk         : in  std_logic;                     -- clock that trigger pulse comes in on.
		clk2         : in  std_logic;                     -- clock that the output pulse will be generated on.
		reset        : in  std_logic;
		trigger      : in  std_logic;                     -- trigger is pulse on clk
		pulse        : out std_logic;                     -- pulse
		pulse_width  : in  std_logic_vector(9 downto 0)   -- max pulse wdith of 1024
	);
end FE_make_pulse;


architecture behavior of FE_make_pulse is

	type state1_type is (state1_wait, state1_triggered);
	signal state1 : state1_type := state1_wait;
	
	signal triggered : std_logic;
	
	type state2_type is (state2_wait, state2_count, state2_done);
	signal state2 : state2_type := state2_wait;

   signal pulse_count        : unsigned(9 downto 0);   
	signal pulse_count_enable : std_logic;
	signal pulse_count_reset  : std_logic;
   signal trigger_reset      : std_logic;
	
begin

	-- Logic to advance to the next state
	process (clk,reset)
	begin
		if reset = '1' then
			state1 <= state1_wait;
		elsif rising_edge(clk) then
			case state1 is
			   ------------------------------------------
				when state1_wait => 
				   if trigger = '1' then
				      state1 <= state1_triggered;
					else
					   state1 <= state1_wait;
					end if;
			   ------------------------------------------
				when state1_triggered => 
				   if trigger_reset = '1' then
				      state1 <= state1_wait;
					else
					   state1 <= state1_triggered;
					end if;
			   ------------------------------------------
				when others =>
				   state1 <= state1_wait;
			end case;
		end if;
	end process;
	-- Output depends solely on the current state
	process (state1)
	begin
		case state1 is
			------------------------------------------
			when state1_wait =>
				triggered <= '0';
			------------------------------------------
			when state1_triggered  =>
				triggered <= '1';
			------------------------------------------
			when others =>
				triggered <= '0';
 		end case;
	end process;


	-- Logic to advance to the next state
	process (clk2, reset)
	begin
		if reset = '1' then
			state2 <= state2_wait;
		elsif rising_edge(clk2) then
			case state2 is
			   ------------------------------------------
				when state2_wait => 
				   if triggered = '1' then
				      state2 <= state2_count;
					else
					   state2 <= state2_wait;
					end if;
			   ------------------------------------------
				when state2_count =>
				   if pulse_count < (unsigned(pulse_width)-1) then
					    state2 <= state2_count;
					else
					    state2 <= state2_done;
				   end if;
			   ------------------------------------------
				when state2_done =>
					state2 <= state2_wait;
			   ------------------------------------------
				when others =>
				   state2 <= state2_wait;
			end case;
		end if;
	end process;
	-- Output depends solely on the current state
	process (state2)
	begin
	   pulse_count_enable <= '0';
		pulse_count_reset  <= '0';
		pulse              <= '0';
      trigger_reset      <= '0';
		case state2 is
			------------------------------------------
			when state2_wait =>
				pulse_count_reset  <= '1';
			------------------------------------------
			when state2_count =>
				pulse_count_enable <= '1';
				pulse              <= '1';
			------------------------------------------
			when state2_done =>
				trigger_reset      <= '1';
				pulse_count_reset  <= '1';
			------------------------------------------
			when others =>
				-- do nothing
 		end case;
	end process;


   process(clk2)
	begin
		if pulse_count_reset = '1' then
	      pulse_count <= (others => '0');
	   elsif rising_edge(clk2) then
			if pulse_count_enable = '1' then
			   pulse_count <= pulse_count + 1;
			end if;
		end if;
	end process;


end behavior;

