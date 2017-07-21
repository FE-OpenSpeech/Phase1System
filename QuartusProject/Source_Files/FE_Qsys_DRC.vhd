--!@file FE_Qsys_DRC.vhd
----------------------------------------------------------------------------------
-- Company:          Montana State University
-- Author/Engineer:   Ross Snider 
-- 
-- Create Date:    3/16/2017 
-- Design Name: 
-- Module Name:    Dynamic Range Compression  (DRC_Qsys)
-- Project Name: 
-- Target Devices: DE0-Nano-SoC
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

--! Use the standard IEEE library functions
library ieee;
--! Use STD_LOGIC datatypes
use ieee.std_logic_1164.all;
--! Use standard integer datatypes
use ieee.numeric_std.all;

--! Entity to create a dynamic range compression block
entity FE_Qsys_DRC is
  port (
    clk               : in std_logic;                                   --! Fast clock in signal
    reset_n           : in std_logic;                                   --! Active low reset signal
    ------------------------------------------------------------
    -- Avalon Memory Mapped Slave Signals
    ------------------------------------------------------------
    avs_s1_address        : in  std_logic_vector( 2 downto 0);          --! Memory mapped address port
    avs_s1_write          : in  std_logic;                              --! Active high write assertion for memory mapped region
    avs_s1_writedata      : in  std_logic_vector(31 downto 0);          --! Data to write to the memory mapped region
    avs_s1_read           : in  std_logic;                              --! Active high read assertion line
    avs_s1_readdata       : out std_logic_vector(31 downto 0);          --! Data to read from the memory mapped region
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Sink)
    ------------------------------------------------------------
    ast_sink_data         : in  std_logic_vector(31 downto 0);          --! Streaming data in
    ast_sink_valid        : in  std_logic;                              --! Streaming valid in line
    ast_sink_error        : in  std_logic_vector( 1 downto 0);          --! Streaming error in line
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Source)
    ------------------------------------------------------------
    ast_source_data       : out std_logic_vector(31 downto 0);          --! Streaming out data line
    ast_source_valid      : out std_logic;                              --! Streaming out valid line
    ast_source_error      : out std_logic_vector( 1 downto 0)           --! Streaming out error line
  );
end FE_Qsys_DRC;


--! Architecture to create the Dynamic Range Compression logic
architecture behavior of FE_Qsys_DRC is
   
  signal enable_reg_read  : std_logic;
  signal enable_reg_write : std_logic;
  signal reg_address      : std_logic_vector(2 downto 0);
  signal reset            : std_logic;
  signal data_in          : signed(47 downto 0);  
  signal data_in_shifted  : signed(47 downto 0);  
  signal data_out         : signed(47 downto 0);  
  signal data_out_shifted : signed(47 downto 0);  
  
  ------------------------------------------------------------------------------
  -- Qsys Avalon Memory Mapped Slave Registers
  -- Data format expected: signed fixed-point with W=16 and F=16
  ------------------------------------------------------------------------------
  signal reg0_threshold             : signed(31 downto 0) := "00000000000010100000000000000000";  -- 10      (W32F16)
  signal reg1_gain1                 : signed(31 downto 0) := "00000000000001011001111110010111";  -- 5.6234  (W32F16)
  signal reg2_gain2                 : signed(31 downto 0) := "00000000000111111001111101110000";  -- 31.6228 (W32F16)
  signal reg3_exponent              : signed(31 downto 0) := "00000000000000000100000000000000";  -- 0.25    (W32F16)
  signal reg3_exponent_48           : signed(47 downto 0);  
  signal reg4_passthrough           : signed(31 downto 0) := "00000000000000000000000000000000";  -- 0  (1=passthrough)
  
  

    component fxpt_power_compute_W48F24 is
       port (
          clock	: in  std_logic;
          reset	: in  std_logic;
          x	    : in  std_logic_vector(47 downto 0);   -- x in: w = power(x,y) = x^y
          y	    : in  std_logic_vector(47 downto 0);   -- y in: w = power(x,y) = x^y
          start	: in  std_logic;   -- start computation (set to '1' for one clock period)
          w     : out std_logic_vector(47 downto 0);   -- w in: w = power(x,y) = x^y
          done  : out std_logic    -- computation is done (set to '1' for one clock period)
       );
    end component;
 
  type state_type is (state_wait, state_passthrough, state_compare1_abs, state_compare2_diff, state_compare3, state_gain1, state_power_start, state_power_wait, state_gain2, state_negative, state_done);
  signal state : state_type;

  signal flag_power_start : std_logic;
  signal flag_power_done  : std_logic;
  signal flag_passthrough : std_logic;
  signal flag_compression_threshold : std_logic;
  signal data_in_abs      : unsigned(47 downto 0);
  signal gain_result      : signed(79 downto 0);
  signal power_result     : std_logic_vector(47 downto 0);
  signal power_data_abs   : unsigned(47 downto 0);
  signal power_data       : signed(47 downto 0);

begin

  -------------------------------------
  -- Signal renaming
  -------------------------------------
  enable_reg_read  <= avs_s1_read;
  enable_reg_write <= avs_s1_write;
  reg_address      <= avs_s1_address;
  reset            <= not reset_n;
  flag_passthrough <= reg4_passthrough(0);
  
  ---------------------------------------------------
  -- Write to Registers
  ---------------------------------------------------
  process (clk)
  begin
    if rising_edge(clk) and (enable_reg_write = '1') then
      case reg_address is
        when "000"  => reg0_threshold             <= signed(avs_s1_writedata(31 downto 0));
        when "001"  => reg1_gain1                 <= signed(avs_s1_writedata(31 downto 0));
        when "010"  => reg2_gain2                 <= signed(avs_s1_writedata(31 downto 0));
        when "011"  => reg3_exponent              <= signed(avs_s1_writedata(31 downto 0));
        when "100"  => reg4_passthrough           <= signed(avs_s1_writedata(31 downto 0));
        when others => -- do nothing
      end case;
    end if;
  end process;
  reg3_exponent_48 <= resize(signed(reg3_exponent & "00000000"), reg3_exponent_48'length);  -- convert W32F16 to W48F24
  
  ---------------------------------------------------
  -- Read from Registers
  ---------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) and (enable_reg_read = '1') then
      case reg_address is
        when "000"  => avs_s1_readdata <= std_logic_vector(reg0_threshold);
        when "001"  => avs_s1_readdata <= std_logic_vector(reg1_gain1);
        when "010"  => avs_s1_readdata <= std_logic_vector(reg2_gain2);
        when "011"  => avs_s1_readdata <= std_logic_vector(reg3_exponent);
        when "100"  => avs_s1_readdata <= std_logic_vector(reg4_passthrough);
        when others => avs_s1_readdata <= (others => '0');
      end case;
    end if;
  end process;
  
  --------------------------------------------------------------------------
  -- Read from Avalon Stream input (Sink) 
  --------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) and (ast_sink_valid = '1') then
      data_in         <= resize(signed(ast_sink_data), data_in'length);  -- convert to W48F24 
      ast_source_data <= std_logic_vector(data_out_shifted(27 downto 0) & "0000" );   -- convert W48F24 -> W32F28
    end if;
  end process;
  data_in_shifted  <= shift_left(data_in, 16);   -- left shift 16 bits (multiply by 2^16)
  data_out_shifted <= shift_right(data_out,16);  -- right shift 16 bits (divide by 2^16)
  
  --------------------------------------------------------------------------
  -- Pass through valid and error signals
  --------------------------------------------------------------------------  
  ast_source_valid <= ast_sink_valid;  
  ast_source_error <= ast_sink_error;
   
  --------------------------------------------------------------------------
  -- power function
  --------------------------------------------------------------------------  
  power1 : fxpt_power_compute_W48F24
    port map (
      clock   => clk,
      reset   => reset,
      x       => std_logic_vector(data_in_abs),
      y       => std_logic_vector(reg3_exponent_48),
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
  process (clk, reset)
  begin
    if reset = '1' then
      state <= state_wait;
    elsif (rising_edge(clk)) then
      case state is
      ----------------------------------------
      when state_wait =>
        if (flag_passthrough = '1') then
          state <= state_passthrough;
        elsif (ast_sink_valid = '1') then     -- new data has arrived
          state <= state_compare1_abs;
        end if;
      ----------------------------------------  
      when state_passthrough =>                -- pass through mode
        if (flag_passthrough = '0') then
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
        state <= state_wait;
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
        if data_in_abs < unsigned(reg0_threshold) then       
          flag_compression_threshold <= '0';
        else
          flag_compression_threshold <= '1';
        end if;
      ----------------------------------------    
      when state_compare3 =>                   -- do nothing while switching to appropriate next state
      ----------------------------------------    
      when state_gain1 =>                      -- implement simple gain
        gain_result <= reg1_gain1 * data_in;   -- W32F16 * W48F24 = W80F40
      ----------------------------------------    
      when state_power_start =>                -- start fixed-point power function
        flag_power_start <= '1';
      ----------------------------------------    
      when state_power_wait =>                 -- do nothing but wait until fixed-point power function finishes
      ----------------------------------------    
      when state_negative =>                  -- convert back to negative value if data_in was negative
        if (data_in(47) = '1') then
          power_data <= signed(not(power_data_abs) + 1);
        else
          power_data <= signed(power_data_abs);
        end if;
      ----------------------------------------    
      when state_gain2 =>                      -- implement gain2
        gain_result <= reg2_gain2 * power_data;-- W32F16 * W48F24 = W80F40
      ----------------------------------------    
      when state_done =>                       -- data to send out
        data_out <= gain_result(63 downto 16); -- W80F40 -> W48F24 
      ----------------------------------------    
      when others =>
      end case;
    end if;
   end process;
    
end behavior;



