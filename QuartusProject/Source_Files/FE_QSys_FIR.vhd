--! @file FE_QSys_FIR.vhd

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

--! Use the standard IEEE library
LIBRARY IEEE;
--! Use STD_LOGIC datatypes
USE IEEE.std_logic_1164.all;
--! Use standard integer datatypes
USE IEEE.numeric_std.ALL;

--! Entity to creat a QSys compadible FIR filter block for Avalon streaming signals
--! @note The latency of this core takes is coeffs+3 clocks.  Ensure sure that the fast clock achieve this between valid signals.
--! @note This core current doesn't generate errors, and only passes this signal through
ENTITY FE_QSys_FIR IS
  generic (
    MAX_COEFS : integer := 512;                           --! Maximum number of coefficients that can be created (memory size)
    ADDR_WIDTH : integer := 11;                           --! Length of the address bus needed to address MAX_COEF words
    INIT_FILENAME : string := ""                          --! Path to a file containing initial coefficient memory data
  );
  port (
    clk               : in std_logic;                                     --! Fast clock to use for the processing
    reset_n           : in std_logic;                                     --! Active low reset for the component
    ------------------------------------------------------------
    -- Avalon Memory Mapped Slave Signals
    ------------------------------------------------------------
    avs_s1_address        : in std_logic_vector(ADDR_WIDTH-1 downto 0);   --! Memory mapped avalon bus address to configure the core
    avs_s1_write          : in std_logic;                                 --! Memory mapped avalon bus write enable
    avs_s1_writedata      : in std_logic_vector(31 downto 0);             --! Memory mapped avalon bus write data to configure the core
    avs_s1_read           : in std_logic;                                 --! Memory mapped avalon bus read enable
    avs_s1_readdata       : out std_logic_vector(31 downto 0);            --! Memory mapped avalon bus read data (with a 1 clock cycle latency)
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
END FE_QSys_FIR;


--! Architecture for a FIR filter
ARCHITECTURE FE_QSys_FIR_ARCH OF FE_QSys_FIR IS

COMPONENT FE_FIR IS
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

begin

  FIR_FILTER : component FE_FIR
  port map (
    clk => clk,
    reset_n => reset_n,
    ------------------------------------------------------------
    -- Register Interface
    ------------------------------------------------------------
    mem_data_in => avs_s1_writedata,
    mem_data_out => open,
    mem_clk => clk,
    mem_addr => avs_s1_address,
    mem_rden => '1',
    mem_wren => avs_s1_write,
    ------------------------------------------------------------
    -- Streaming Data Interface
    ------------------------------------------------------------  
    data_in => ast_sink_data,
    data_out => ast_source_data,
    valid_in => ast_sink_valid,
    valid_out => ast_source_valid
  );

  ast_source_error <= ast_sink_error;
  
    
end architecture;


