--! @file FE_OutputMux.vhd
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
  
--! Use the IEEE standard library
LIBRARY IEEE;
--! Use std_logic elements
USE IEEE.std_logic_1164.all;
--! Use IEEE signed and unsigned numbers
USE IEEE.numeric_std.ALL;



--! Create a 1 to 2 output demux, of as a way of selecting which output (or outputs), to send the processed signal to
ENTITY FE_OutputMux IS
  generic (DEFAULT_SOURCE : integer := 0);                          --! Default position to start the MUX in
  port (
    reset_n           : in std_logic;                               --! Active low reset
    output_select     : in integer range 0 to 7;                    --! Which output to use, bit0=channel1, bit1=channel2
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Sink)
    ------------------------------------------------------------
    ast_sink_data_l         : in std_logic_vector(31 downto 0);     --! Input data, left channel
    ast_sink_valid_l        : in std_logic;                         --! Input valid signal, left channel
    ast_sink_error_l        : in std_logic_vector( 1 downto 0);     --! Input error signal, left channel
    ------------------------------------------------------------
    ast_sink_data_r         : in std_logic_vector(31 downto 0);     --! Input data, right channel
    ast_sink_valid_r        : in std_logic;                         --! Input valid signal, right channel
    ast_sink_error_r        : in std_logic_vector( 1 downto 0);     --! Input error signal, right channel
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Source)
    ------------------------------------------------------------
    ast_source_data_1_l       : out std_logic_vector(31 downto 0);  --! Output 1 data left channel
    ast_source_valid_1_l      : out std_logic;                      --! Output 1 valid right channel
    ast_source_error_1_l      : out std_logic_vector( 1 downto 0);  --! Output 1 right error signal
   ------------------------------------------------------------
    ast_source_data_1_r       : out std_logic_vector(31 downto 0);  --! Output 1 data right channel
    ast_source_valid_1_r      : out std_logic;                      --! Output 1 valid right channel
    ast_source_error_1_r      : out std_logic_vector( 1 downto 0);  --! Output 1 right error signal
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Source)
    ------------------------------------------------------------
    ast_source_data_2_l       : out std_logic_vector(31 downto 0);  --! Output 2 data left channel
    ast_source_valid_2_l      : out std_logic;                      --! Output 2 valid left channel
    ast_source_error_2_l      : out std_logic_vector( 1 downto 0);  --! Output 2 left error signal 
   ------------------------------------------------------------
    ast_source_data_2_r       : out std_logic_vector(31 downto 0);  --! Output 2 data right channel
    ast_source_valid_2_r      : out std_logic;                      --! Output 2 valid right channel
    ast_source_error_2_r      : out std_logic_vector( 1 downto 0)   --! Output 2 right error signal     
    );
END FE_OutputMux;


--! Architecture for the output mux
ARCHITECTURE FE_OutputMux_arch OF FE_OutputMux IS  
  signal output_select_sig : std_logic_vector(3 downto 0);          --! Signal to hold the selected channel as a std_logic vector
begin
  output_select_sig <= std_logic_vector(to_unsigned(output_select,4));

  --! Crossbar select on the outputs
  --! @note For the output_select line: 0 = Mute, 1 = Line Out, 2 = Headphone Out, 3 = Both
  ast_source_data_1_l  <= ast_sink_data_l  when (output_select_sig(0) = '1') else (others => '0');
  ast_source_valid_1_l <= ast_sink_valid_l when (output_select_sig(0) = '1') else ('0');
  ast_source_error_1_l <= ast_sink_error_l when (output_select_sig(0) = '1') else (others => '0');
  
  ast_source_data_1_r  <= ast_sink_data_r  when (output_select_sig(0) = '1') else (others => '0');
  ast_source_valid_1_r <= ast_sink_valid_r when (output_select_sig(0) = '1') else ('0');
  ast_source_error_1_r <= ast_sink_error_r when (output_select_sig(0) = '1') else (others => '0');
  
  
  ast_source_data_2_l  <= ast_sink_data_l  when (output_select_sig(1) = '1') else (others => '0');
  ast_source_valid_2_l <= ast_sink_valid_l when (output_select_sig(1) = '1') else ('0');
  ast_source_error_2_l <= ast_sink_error_l when (output_select_sig(1) = '1') else (others => '0');
  
  ast_source_data_2_r  <= ast_sink_data_r  when (output_select_sig(1) = '1') else (others => '0');
  ast_source_valid_2_r <= ast_sink_valid_r when (output_select_sig(1) = '1') else ('0');
  ast_source_error_2_r <= ast_sink_error_r when (output_select_sig(1) = '1') else (others => '0');

END ARCHITECTURE;
