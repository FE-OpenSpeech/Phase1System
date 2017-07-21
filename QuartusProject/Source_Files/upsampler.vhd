--! @file upsampler.vhd

----------------------------------------------------------------------------------
-- Company:          Flat Earth Inc
-- Author/Engineer:  Raymond Weber
-- 
-- Create Date:    4/14/2017 
-- Design Name: 
-- Module Name:    
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

--! Use the standard IEEE libraries
LIBRARY IEEE;
--! Use STD_LOGIC datatypes
USE IEEE.std_logic_1164.all;
--! Use standard integer datatypes
USE IEEE.numeric_std.ALL;
--! Use unsigned math on STD_LOGIC_VECTORS
use ieee.std_logic_unsigned.all;

--! Use Altera/Intel Primitives library
LIBRARY altera_mf; 
--! Use the altera components
USE altera_mf.altera_mf_components.all;


--! Entity to creat a QSys compadible FIR filter block for Avalon streaming signals
--! @note The latency of this core takes is coeffs+3 clocks.  Ensure sure that the fast clock achieve this between valid signals.
--! @note This core current doesn't generate errors, and only passes this signal through
ENTITY upsampler IS
  generic (MAX_COEFS : integer := 256;                          --! Maximum number of coefficients that the filter can handle
          ADDR_WIDTH : integer := 11                            --! Number of bits required to address MAX_COEF works
  );
  port (
    clk               : in std_logic;                                     --! Fast clock to use for the processing
    reset_n           : in std_logic;                                     --! Active low reset for the component
    ------------------------------------------------------------
    -- Avalon Memory Mapped Slave Signals
    ------------------------------------------------------------
--    avs_s1_address        : in std_logic_vector(ADDR_WIDTH-1 downto 0);   --! Memory mapped avalon bus address to configure the core
--    avs_s1_write          : in std_logic;                                 --! Memory mapped avalon bus write enable
--    avs_s1_writedata      : in std_logic_vector(31 downto 0);             --! Memory mapped avalon bus write data to configure the core
--    avs_s1_read           : in std_logic;                                 --! Memory mapped avalon bus read enable
--    avs_s1_readdata       : out std_logic_vector(31 downto 0);            --! Memory mapped avalon bus read data (with a 1 clock cycle latency)
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Sink)
    ------------------------------------------------------------
    ast_sink_data         : in std_logic_vector(31 downto 0);             --! Streaming avalon bus input data
    ast_sink_valid        : in std_logic;                                 --! Streaming avalon bus input valid signal
    ast_sink_error        : in std_logic_vector( 1 downto 0);             --! Streaming avalon bus input error signal
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Source)
    ------------------------------------------------------------
    ast_source_data       : out std_logic_vector(31 downto 0);            --! Output filtered data
    ast_source_valid      : out std_logic;                                --! Delayed valid signal to match the output data becoming valid
    ast_source_error      : out std_logic_vector( 1 downto 0)             --! Error signal for the output
  );
END upsampler;


--! Architecture block holding the logic for the upsampler circuit
ARCHITECTURE rtl OF upsampler IS


TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0);            --! Type definition of the sfix32_En28 array to hold the circular shift buffer for the input values

signal delay_pipeline : delay_pipeline_type(0 TO MAX_COEFS);                            --! Array of 32b28f signed values of the inputs, shift buffer
signal add_temp2      : std_logic_vector(63 downto 0) := (others=>'0');                 --! Casted the accumulator register to a std_logic_vector so bits can be extracted @todo eliminate this signal
signal add_temp4      : signed(63 downto 0) := to_signed(0,64);                         --! Temp signal to hold the accumulated count of the fir filter
signal mult_count     : integer range 0 to MAX_COEFS := 0;                              --! Counter for the current pipeline element
signal numCoefs       : integer range 0 to MAX_COEFS-1 := 8;                            --! Number of coefficients to use
signal address_a      : std_logic_vector(ADDR_WIDTH-1 downto 0);                        --! Address going into the bram block for the internal logic
signal address_a_reg  : std_logic_vector(ADDR_WIDTH-1 downto 0);                        --! Address delayed by 1 clk cycle, so this is the address of what is coming out of the BRAM
signal data_a         : std_logic_vector(31 downto 0);                                  --! Data register to hold data coming out of the BRAM to be used inside the process


--! Component to do FIR filtering
COMPONENT FE_FIR_updown IS
  generic (MAX_COEFS : integer := MAX_COEFS;                    --! Maximum number of coefficients that the filter can handle
           ADDR_WIDTH : integer := ADDR_WIDTH                   --! Size of the address bus needed to address MAX_COEFS+1
           --readWaitTime : integer := 1                        --! There is a 1 clock cycle latency on reading from this core
  );
  port (
    clk               : in std_logic;                           --! High speed clock for the filter processing
    reset_n           : in std_logic;                           --! Active low reset pin
    ------------------------------------------------------------
    -- Register Interface
    ------------------------------------------------------------
    mem_data_in       : in std_logic_vector(31 downto 0);       --! Data in to the data registers to set coefficients
    mem_data_out      : out std_logic_vector(31 downto 0);      --! @todo Doesn't work
    mem_clk           : in std_logic;                           --! @todo not using BRAM, use clk instead
    mem_addr          : in std_logic_vector(ADDR_WIDTH-1 downto 0);       --! Address to write to in the register space
    mem_wren          : in std_logic;                           --! write enable
    mem_rden          : in std_logic;                           --! read enable
    ------------------------------------------------------------
    -- Streaming Data Interface
    ------------------------------------------------------------  
    data_in           : in std_logic_vector(31 downto 0);       --! Data coming in to the system as a 32 bit integer (non-float).  Fixed point is at developers discretion.
    data_out          : out std_logic_vector(31 downto 0);      --! Data coming in to the system as a 32 bit integer (non-float).  Fixed point place place will match inputs.
    valid_in          : in std_logic;                           --! Single bit wide pulse at clk to specify that new data is present on data_in
    valid_out         : out std_logic                           --! Single bit wide pulse at clk to specify that new data is present on data_out
  );
END COMPONENT;


  signal frame_period_count      : std_logic_vector(31 downto 0);           --! Internal signal to hold the number of counts between valids in clks
  signal frame_period_count_div2 : std_logic_vector(31 downto 0);           --! Internal signal to hold half the number of counts between valids in clks
  signal fast_frame_period_counter      : std_logic_vector(31 downto 0);    --! Counter to create 
  signal fast_valid : std_logic;                                            --! Generated valid output signal

  signal data_to_filter : std_logic_vector(31 downto 0);                    --! Data to send from the interpolator to the filter to smooth

begin

  -- Process to count how long the period is in 50MHz periods such that a new valid out can be created at double the speed
  period_counter_process : process(clk, reset_n, frame_period_count)
  begin
    if reset_n = '0' then
      frame_period_count <= (others=>'0');
    elsif rising_edge(clk) then
      if ast_sink_valid = '1' then
        frame_period_count_div2 <= '0' & frame_period_count(31 downto 1);
        frame_period_count <= (others=>'0');
      else
        frame_period_count <= frame_period_count + 1;
      end if;
    end if;
  end process;


  --Create a new valid signal at 2x the rate of the input valid signal
  fast_valid_out_process : process(clk, reset_n, fast_frame_period_counter)
  begin
    if reset_n = '0' then
      fast_frame_period_counter <= (others=>'0');
    elsif rising_edge(clk) then
      if (ast_sink_valid = '1') or (fast_frame_period_counter = frame_period_count_div2) then
        fast_frame_period_counter <= (others=>'0');
        fast_valid <= '1';
		  --ast_source_data <=ast_sink_data;
      else
        fast_frame_period_counter <= fast_frame_period_counter + 1;
        fast_valid <= '0';
      end if;
    end if;
  end process;

--ast_source_valid <= fast_valid;

  --! Component to smooth the signal after zeros during interpolation
  FIR_FILTER : component FE_FIR_updown
  port map (
    clk => clk,
    reset_n => reset_n,
    ------------------------------------------------------------
    -- Register Interface
    ------------------------------------------------------------
    mem_data_in => (others=>'0'), --avs_s1_writedata,
    mem_data_out => open,
    mem_clk => clk,
    mem_addr => (others=>'1'), --avs_s1_address,
    mem_rden => '1',
    mem_wren => '0', --avs_s1_write,
    ------------------------------------------------------------
    -- Streaming Data Interface
    ------------------------------------------------------------  
    data_in => ast_sink_data,
    data_out => ast_source_data,
    valid_in => fast_valid,
    valid_out => ast_source_valid
  );

  ast_source_error <= ast_sink_error;

    
end architecture;
