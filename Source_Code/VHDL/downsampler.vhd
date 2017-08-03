--! @file downsampler.vhd

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

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

--! Use Altera/Intel Primitives library
LIBRARY altera_mf;
--! Use the altera components
USE altera_mf.altera_mf_components.all;


--! Entity to creat a QSys compadible FIR filter block for Avalon streaming signals
--! @note The latency of this core takes is coeffs+3 clocks.  Ensure sure that the fast clock achieve this between valid signals.
--! @note This core current doesn't generate errors, and only passes this signal through
ENTITY downsampler IS
  generic (MAX_COEFS : integer := 128;                          --! Maximum number of coefficients that the filter can handle
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
END downsampler;

----------------------------------------------------------------
--Module Architecture: filter
----------------------------------------------------------------
ARCHITECTURE rtl OF downsampler IS

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


  signal data_out_sig          : std_logic_vector(31 downto 0);      --! Data coming in to the system as a 32 bit integer (non-float).  Fixed point place place will match inputs.
  signal valid_out_sig         : std_logic;                           --! Single bit wide pulse at clk to specify that new data is present on data_out
  signal n_count               : std_logic;

begin

  --- Low pass filter the input signal to remove high frequencies prior to decimation
  FIR_FILTER_updown : component FE_FIR_updown
  port map (
    clk => clk,
    reset_n => reset_n,
    ------------------------------------------------------------
    -- Register Interface
    ------------------------------------------------------------
    mem_data_in => (others=>'0'),
    mem_data_out => open,
    mem_clk => clk,
    mem_addr => (others=>'1'),
    mem_rden => '1',
    mem_wren => '0',
    ------------------------------------------------------------
    -- Streaming Data Interface
    ------------------------------------------------------------  
    data_in => ast_sink_data,
    data_out => data_out_sig,
    valid_in => ast_sink_valid,
    valid_out => valid_out_sig
  );


  --- Decimate the filtered signal and pass every other data point and valid pulse to the output
  decimate_process : PROCESS (clk, reset_n, n_count)
  begin
    if reset_n = '0' then
      n_count <= '0';
      ast_source_data <= (others=>'0');
      ast_source_valid <= '0';
    elsif rising_edge(clk) then
       ast_source_valid <= '0';
       if valid_out_sig = '1' then
        if n_count = '1' then
          ast_source_data <= data_out_sig;
          n_count <= '0';
          ast_source_valid <= '1';
        else
          n_count <= '1';
        end if;
      end if;
    end if;
  end process;

  
  --- Passthrough for the error signal (no errors defined in this core)
  ast_source_error <= ast_sink_error;
  
end architecture;

