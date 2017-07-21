--!@file FE_QSys_OutputMux.vhd

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



--! Use the standard library
LIBRARY IEEE;
--! Use std_logic elements
USE IEEE.std_logic_1164.all;
--! Use IEEE signed and unsigned numbers
USE IEEE.numeric_std.ALL;

--! Create a QSys compadible component to control the 1-2 output mux
ENTITY FE_QSys_OutputMux IS
  generic (DEFAULT_SOURCE :integer := 1);    --! 0 (mute), 1(line in), 2(mic in), 3(mems)
  port (
    clk             : in std_logic;                               --! Clock for the component
    reset_n         : in std_logic;                               --! Active low reset pin
    ------------------------------------------------------------
    -- Avalon Memory Mapped Slave Signals
    ------------------------------------------------------------
    avs_s1_address        : in std_logic_vector(3 downto 0);        --! Memory mapped address to write to
    avs_s1_write          : in std_logic;                           --! Active high write assertion
    avs_s1_writedata      : in std_logic_vector(31 downto 0);       --! Data to write to memory mapped region
    avs_s1_read           : in std_logic;                           --! Data to read from memory mapped region
    avs_s1_readdata       : out std_logic_vector(31 downto 0);      --! Active high read assertion
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Sink)
    ------------------------------------------------------------
    ast_sink_data_l         : in std_logic_vector(31 downto 0);     --! Input data to the mux, left channel
    ast_sink_valid_l        : in std_logic;                         --! Valid in line, left channel
    ast_sink_error_l        : in std_logic_vector( 1 downto 0);     --! Error in line, left channel
    ------------------------------------------------------------
    ast_sink_data_r         : in std_logic_vector(31 downto 0);     --! Input data to the mux, right channel
    ast_sink_valid_r        : in std_logic;                         --! Valid in line, right channel
    ast_sink_error_r        : in std_logic_vector( 1 downto 0);     --! Error in line, right channel
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Source)
    ------------------------------------------------------------
    ast_source_data_1_l       : out std_logic_vector(31 downto 0);  --! Data output 1, left channel
    ast_source_valid_1_l      : out std_logic;                      --! Valid out signal for channel 1, left channel
    ast_source_error_1_l      : out std_logic_vector( 1 downto 0);  --! Error out signal for channel 1, left channel
    ------------------------------------------------------------
    ast_source_data_1_r       : out std_logic_vector(31 downto 0);  --! Data output 1, right channel
    ast_source_valid_1_r      : out std_logic;                      --! Valid out signal for channel 1, right channel
    ast_source_error_1_r      : out std_logic_vector( 1 downto 0);  --! Error out signal for channel 1, right channel
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Source)
    ------------------------------------------------------------
    ast_source_data_2_l       : out std_logic_vector(31 downto 0);  --! Data output 2, left channel
    ast_source_valid_2_l      : out std_logic;                      --! Valid out signal for channel 2, left channel
    ast_source_error_2_l      : out std_logic_vector( 1 downto 0);  --! Error out signal for channel 2, left channel
    ------------------------------------------------------------
    ast_source_data_2_r       : out std_logic_vector(31 downto 0);  --! Data output 2, right channel
    ast_source_valid_2_r      : out std_logic;                      --! Valid out signal for channel 2, right channel
    ast_source_error_2_r      : out std_logic_vector( 1 downto 0)   --! Error out signal for channel 2, right channel
  );
END FE_QSys_OutputMux;  
  
--! Architecture to wrap the Qsys block to the output mux vhdl component
ARCHITECTURE FE_QSys_OutputMux_arch OF FE_QSys_OutputMux IS  
  signal selectRegister : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(DEFAULT_SOURCE,4));      --! Register to hold the current mux position
  
  --! Component containing the actual mux logic
  component FE_OutputMux IS
    generic (DEFAULT_SOURCE : integer := DEFAULT_SOURCE);
    port (
    reset_n           : in std_logic;
    output_select     : in integer range 0 to 7;
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Sink)
    ------------------------------------------------------------
    ast_sink_data_l         : in std_logic_vector(31 downto 0);
    ast_sink_valid_l        : in std_logic;
    ast_sink_error_l        : in std_logic_vector( 1 downto 0);
    ------------------------------------------------------------
    ast_sink_data_r         : in std_logic_vector(31 downto 0);
    ast_sink_valid_r        : in std_logic;
    ast_sink_error_r        : in std_logic_vector( 1 downto 0);
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Source)
    ------------------------------------------------------------
    ast_source_data_1_l       : out std_logic_vector(31 downto 0);
    ast_source_valid_1_l      : out std_logic;
    ast_source_error_1_l      : out std_logic_vector( 1 downto 0);  
    -----------------------------------------------------------
    ast_source_data_1_r       : out std_logic_vector(31 downto 0);
    ast_source_valid_1_r      : out std_logic;
    ast_source_error_1_r      : out std_logic_vector( 1 downto 0);
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Source)
    ------------------------------------------------------------
    ast_source_data_2_l       : out std_logic_vector(31 downto 0);
    ast_source_valid_2_l      : out std_logic;
    ast_source_error_2_l      : out std_logic_vector( 1 downto 0);  
    ------------------------------------------------------------
    ast_source_data_2_r       : out std_logic_vector(31 downto 0);
    ast_source_valid_2_r      : out std_logic;
    ast_source_error_2_r      : out std_logic_vector( 1 downto 0)     
    );
  END component;

  begin
  
    u0 : component FE_OutputMux
    port map (
      reset_n => reset_n,
      output_select => to_integer(unsigned(selectRegister)),
      ------------------------------------------------------------
      -- Avalon Streaming Interface Signals (Sink)
      ------------------------------------------------------------
      ast_sink_data_l  => ast_sink_data_l,
      ast_sink_valid_l => ast_sink_valid_l,
      ast_sink_error_l => ast_sink_error_l,
      ------------------------------------------------------------
      ast_sink_data_r  => ast_sink_data_r,
      ast_sink_valid_r => ast_sink_valid_r,
      ast_sink_error_r => ast_sink_error_r,
      ------------------------------------------------------------
      -- Avalon Streaming Interface Signals (Source)
      ------------------------------------------------------------
      ast_source_data_1_l  => ast_source_data_1_l,
      ast_source_valid_1_l => ast_source_valid_1_l,
      ast_source_error_1_l => ast_source_error_1_l,
      ------------------------------------------------------------
      ast_source_data_1_r  => ast_source_data_1_r,
      ast_source_valid_1_r => ast_source_valid_1_r,
      ast_source_error_1_r => ast_source_error_1_r,
      ------------------------------------------------------------
      -- Avalon Streaming Interface Signals (Source)
      ------------------------------------------------------------
      ast_source_data_2_l  => ast_source_data_2_l,
      ast_source_valid_2_l => ast_source_valid_2_l,
      ast_source_error_2_l => ast_source_error_2_l,
      ------------------------------------------------------------
      ast_source_data_2_r  => ast_source_data_2_r,
      ast_source_valid_2_r => ast_source_valid_2_r,
      ast_source_error_2_r => ast_source_error_2_r
    );

    
    --! Read and write the select line using the avalon bus signals  
    process(clk)
    begin
      if reset_n = '0' then
        selectRegister <= std_logic_vector(to_unsigned(DEFAULT_SOURCE,4));
      elsif rising_edge(clk) then
        if avs_s1_write = '1' then
          if avs_s1_address = x"0" then
            selectRegister <= avs_s1_writedata(3 downto 0);
          end if;
        end if;
        
        if avs_s1_read = '1' then
          if avs_s1_address = x"0" then
            avs_s1_readdata <= x"0000000" & selectRegister;
          else
            avs_s1_readdata <= (others =>'0');
          end if;
        end if;
      end if;
    end process;
  
END ARCHITECTURE;
