LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY HA_DRC IS
    PORT( 
        clk                 : in  std_logic;   -- system clock (must be greater than ~250*Fs_clk)
        Fs_clk              : in  std_logic;   -- sample rate clock
        reset               : in  std_logic; 
        threshold           : in  std_logic_vector(31 downto 0);  -- W32F16  -- compression threshold
        gain1               : in  std_logic_vector(31 downto 0);  -- W32F16  -- Gain1 applied if below compression threshold
        gain2               : in  std_logic_vector(31 downto 0);  -- W32F16  -- Gain2 applied if above compression threshold
        exponent            : in  std_logic_vector(31 downto 0);  -- W32F16  -- DRC exponent when above compression threshold
        bypass              : in  std_logic;                      -- (1=DRC is bypassed)
        samples_in          : in  std_logic_vector(31 DOWNTO 0);  
        samples_out         : out std_logic_vector(31 DOWNTO 0)   
    );
END HA_DRC;


ARCHITECTURE rtl OF HA_DRC IS

    component fxpt_power_compute_W48F24 is
       port (
          clock	: in  std_logic;
          reset	: in  std_logic;
          x	    : in  std_logic_vector(47 downto 0);   -- x in: w = power(x,y) = x^y
          y	    : in  std_logic_vector(47 downto 0);   -- y in: w = power(x,y) = x^y
          start	: in  std_logic;                       -- start computation (set to '1' for one clock period)
          w     : out std_logic_vector(47 downto 0);   -- w in: w = power(x,y) = x^y
          done  : out std_logic                        -- computation is done (set to '1' for one clock period)
       );
    end component;
     
    signal exponent_48      : signed(47 downto 0);  
	signal data_in          : signed(47 downto 0);  
    signal data_in_shifted  : signed(47 downto 0);  
    signal data_out         : signed(47 downto 0);  
    signal data_out_shifted : signed(47 downto 0);  
    signal flag_power_start : std_logic;
    signal flag_power_done  : std_logic;
    signal flag_passthrough : std_logic;
    signal flag_compression_threshold : std_logic;
    signal data_in_abs      : unsigned(47 downto 0);
    signal gain_result      : signed(79 downto 0);
    signal power_result     : std_logic_vector(47 downto 0);
    signal power_data_abs   : unsigned(47 downto 0);
    signal power_data       : signed(47 downto 0);
    type state_type is (state_wait, state_passthrough, state_compare1_abs, state_compare2_diff, state_compare3, state_gain1, state_power_start, state_power_wait, state_gain2, state_negative, state_done);
    signal state : state_type;

begin

    --------------------------------------------------------------------------
    -- capture input samples 
    --------------------------------------------------------------------------
    process(Fs_clk)
    begin
        if rising_edge(Fs_clk) then
            data_in     <= resize(signed(samples_in), data_in'length);                  -- convert W32F28 to W48F24 
            samples_out <= std_logic_vector(data_out_shifted(27 downto 0) & "0000" );   -- convert W48F24 to W32F28
        end if;
    end process;
    data_in_shifted  <= shift_left(data_in, 16);   -- left shift 16 bits (multiply by 2^16) -- need to convert fractional representation to integers for power function to compress
    data_out_shifted <= shift_right(data_out,16);  -- right shift 16 bits (divide by 2^16)
  
    exponent_48 <= resize(signed(exponent & "00000000"), exponent_48'length);  -- convert W32F16 to W48F24
    --------------------------------------------------------------------------
    -- power function
    --------------------------------------------------------------------------  
    power1 : fxpt_power_compute_W48F24
        port map (
            clock   => clk,
            reset   => reset,
            x       => std_logic_vector(data_in_abs),
            y       => std_logic_vector(exponent_48),
            start   => flag_power_start,
            w       => power_result,
            done    => flag_power_done
    );
    --------------------------------------------------------------------------
    -- Grab power function result
    --------------------------------------------------------------------------  
    process (clk)
    begin
        if rising_edge(clk) and (flag_power_done = '1') then
            power_data_abs <= unsigned(power_result);  -- grab w=exp_power(x,y) result 
        end if;
    end process;

    --------------------------------------------------------------------------
    -- State machine to control computations (or passthrough)
    -- Next state logic
    --------------------------------------------------------------------------  
    process (clk, Fs_clk, reset)
    begin
        if reset = '1' then
            state <= state_wait;
        elsif (rising_edge(clk)) then
            case state is
                ----------------------------------------
                when state_wait =>
                    if (bypass = '1') then
                        state <= state_passthrough;
                    elsif Fs_clk = '1' then     -- new data has arrived
                        state <= state_compare1_abs;
                    end if;
                ----------------------------------------  
                when state_passthrough =>                -- pass through mode
                    if (bypass = '0') then
                        state <= state_wait;
                end if;
                ----------------------------------------  
                when state_compare1_abs =>         -- compute absolute value of input data
                    state <= state_compare2_diff;
                ----------------------------------------    
                when state_compare2_diff =>        -- compare with compression threshold
                    state <= state_compare3;
                ----------------------------------------    
                when state_compare3 =>
                    if (flag_compression_threshold = '1') then  -- flag_compression_threshold = 1   =>   above compression threshold
                        state <= state_power_start;          -- implement power law
                    else 
                        state <= state_gain1;                -- implement simple gain when below threshold
                    end if;
                ----------------------------------------    
                when state_gain1 =>                      -- implement simple gain
                    state <= state_done;
                ----------------------------------------    
                when state_power_start =>                -- start fixed-point power function
                    state <= state_power_wait;
                ----------------------------------------    
                when state_power_wait =>                 -- wait until fixed-point power function finishes
                    state <= state_negative;
                ----------------------------------------    
                when state_negative =>                   -- convert back to negative value if data_in was negative
                    state <= state_gain2;
                ----------------------------------------    
                when state_gain2 =>                      -- implement gain2
                    state <= state_done;
                ----------------------------------------    
                when state_done =>                       -- data to send out
                    if Fs_clk = '0' then                 -- make sure Fs_clk has been deasserted before we wait for Fs_clk = 1
                       state <= state_wait;
                    else
                       state <= state_done;
                    end if;
                ----------------------------------------    
                when others =>
                    state <= state_wait;
            end case;
        end if;
    end process;
  
    --------------------------------------------------------------------------
    -- State machine 
    -- Perform Computations that are state dependent
    --------------------------------------------------------------------------  
    compute : process (clk)
    begin
        if (rising_edge(clk)) then
            flag_power_start <= '0';
            case state is
                ----------------------------------------
                when state_wait =>                       -- do nothing but wait
                ----------------------------------------  
                when state_passthrough =>                -- bypass mode - no compression - simple pass through
                    data_out <= data_in_shifted;
                ----------------------------------------  
                when state_compare1_abs =>         -- compute absolute value of input data
                    if (data_in_shifted(47) = '1') then
                        data_in_abs <= not(unsigned(data_in_shifted)) + 1;
                    else
                        data_in_abs <= unsigned(data_in_shifted);
                    end if;
                ----------------------------------------    
                when state_compare2_diff =>        -- compare with compression threshold
                    if data_in_abs(39 downto 8) < unsigned(threshold) then       
                        flag_compression_threshold <= '0';
                    else
                        flag_compression_threshold <= '1';
                    end if;
                ----------------------------------------    
                when state_compare3 =>                   -- do nothing while switching to appropriate next state
                ----------------------------------------    
                when state_gain1 =>                      -- implement simple gain
                    gain_result <= signed(gain1) * data_in;      -- W32F16 * W48F24 = W80F40
                ----------------------------------------    
                when state_power_start =>                -- start fixed-point power function
                    flag_power_start <= '1';
                ----------------------------------------    
                when state_power_wait =>                 -- do nothing but wait until fixed-point power function finishes
                ----------------------------------------    
                when state_negative =>                   -- convert back to negative value if data_in was negative
                    if (data_in(47) = '1') then
                        power_data <= signed(not(power_data_abs) + 1);
                    else
                        power_data <= signed(power_data_abs);
                    end if;
                ----------------------------------------    
                when state_gain2 =>                      -- implement gain2
                    gain_result <= signed(gain2) * power_data;   -- W32F16 * W48F24 = W80F40
                ----------------------------------------    
                when state_done =>                         -- data to send out
                    data_out <= gain_result(63 downto 16); -- W80F40 -> W48F24 
                ----------------------------------------    
                when others =>  -- do nothing
            end case;
        end if;
    end process;
    

end rtl;

