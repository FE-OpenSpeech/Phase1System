--! @file FE_InputMux.vhd
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



--! Entity to create a mux that selects a single channel from multiple inputs
ENTITY FE_InputMux IS
  generic (DEFAULT_SOURCE : integer := 0);                            --! Default position to start the MUX in
  port (
    reset_n          : in std_logic;                                  --! Active low reset pin
    input_select     : in integer range 0 to 7;                       --! Active high select bit for each channel
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Sink)
    ------------------------------------------------------------
    ast_sink_data_1_l         : in std_logic_vector(31 downto 0);     --! Source 1 left data channel
    ast_sink_valid_1_l        : in std_logic;                         --! Source 1 left valid signal (active high)
    ast_sink_error_1_l        : in std_logic_vector( 1 downto 0);     --! Source 1 left error signal (passthrough)
    ------------------------------------------------------------
    ast_sink_data_1_r         : in std_logic_vector(31 downto 0);     --! Source 1 right data channel
    ast_sink_valid_1_r        : in std_logic;                         --! Source 1 right valid signal (active high)
    ast_sink_error_1_r        : in std_logic_vector( 1 downto 0);     --! Source 1 right erorr signal (passthrough)
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Sink)
    ------------------------------------------------------------
    ast_sink_data_2_l         : in std_logic_vector(31 downto 0);     --! Source 2 left data channel
    ast_sink_valid_2_l        : in std_logic;                         --! Source 2 left valid signal (active high)
    ast_sink_error_2_l        : in std_logic_vector( 1 downto 0);     --! Source 2 left error signal (passthrough)
    ------------------------------------------------------------
    ast_sink_data_2_r         : in std_logic_vector(31 downto 0);     --! Source 2 right data channel
    ast_sink_valid_2_r        : in std_logic;                         --! Source 2 right valid signal (active high)
    ast_sink_error_2_r        : in std_logic_vector( 1 downto 0);     --! Source 2 right error signal (passthrough)
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Source)
    ------------------------------------------------------------
    ast_source_data_l       : out std_logic_vector(31 downto 0);      --! Ouput left data channel
    ast_source_valid_l      : out std_logic;                          --! Output left valid signal (active high)
    ast_source_error_l      : out std_logic_vector( 1 downto 0);      --! Output left error signal (passthrough)
    ------------------------------------------------------------
    ast_source_data_r       : out std_logic_vector(31 downto 0);      --! Ouput right data channel
    ast_source_valid_r      : out std_logic;                          --! Output right valid signal (active high)
    ast_source_error_r      : out std_logic_vector( 1 downto 0)       --! Output right error signal (passthrough)
    );
END FE_InputMux;




 --! Architecture block to create an input mux component
ARCHITECTURE FE_InputMux_arch OF FE_InputMux IS  
begin

  --! Crossbar select on the input source
  --! @todo Make this a component
  --! @note For the input_select line: 0 = Mute, 1 = Line In, 2 = Microphone in, 3 = Mems Microphone
  --! @todo Mems Microphone input is unconneted
  ast_source_data_l <=   ast_sink_data_1_l when (input_select = 1) else
                         ast_sink_data_2_l when (input_select = 2) else
                         (others => '0');

  ast_source_data_r <=   ast_sink_data_1_r when (input_select = 1) else
                         ast_sink_data_2_r when (input_select = 2) else
                         (others => '0');

  ast_source_valid_l <=  ast_sink_valid_1_l when (input_select = 1) else
                         ast_sink_valid_2_l when (input_select = 2) else
                         '0';

  ast_source_valid_r <=  ast_sink_valid_1_r when (input_select = 1) else
                         ast_sink_valid_2_r when (input_select = 2) else
                         '0';

  ast_source_error_l <=  ast_sink_error_1_l when (input_select = 1) else
                         ast_sink_error_2_l when (input_select = 2) else
                         (others => '0');

  ast_source_error_r <=  ast_sink_error_1_r when (input_select = 1) else
                         ast_sink_error_2_r when (input_select = 2) else
                         (others => '0');

END ARCHITECTURE;
