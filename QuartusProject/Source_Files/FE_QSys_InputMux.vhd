--! @file FE_QSys_InputMux.vhd
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



--! Create an 2-1 input mux to select the channel to do the processing on
--! @note This core doesn't generate any error signals
ENTITY FE_QSys_InputMux IS
  generic (DEFAULT_SOURCE :integer := 1);     --! 0 (mute), 1(line in), 2(mic in), 3(mems)
  port (
    clk             : in std_logic;                                 --! Clock for the memory mapped axi bus
    reset_n         : in std_logic;                                 --! Active low reset signal
    ------------------------------------------------------------
    -- Avalon Memory Mapped Slave Signals
    ------------------------------------------------------------
    avs_s1_address        : in std_logic_vector(3 downto 0);        --! Avalon Memory mapped address to select channels from the HPS
    avs_s1_write          : in std_logic;                           --! Active high write signal
    avs_s1_writedata      : in std_logic_vector(31 downto 0);       --! Data to write on the write signal
    avs_s1_read           : in std_logic;                           --! Active high read signal
    avs_s1_readdata       : out std_logic_vector(31 downto 0);      --! Data read on the read signal
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Sink)
    ------------------------------------------------------------
    ast_sink_data_1_l         : in std_logic_vector(31 downto 0);   --! Input 1 data, left channel
    ast_sink_valid_1_l        : in std_logic;                       --! Input 1 valid signal, left channel
    ast_sink_error_1_l        : in std_logic_vector( 1 downto 0);   --! Input 1 error, left channel
    ------------------------------------------------------------
    ast_sink_data_1_r         : in std_logic_vector(31 downto 0);   --! Input 1 data, right channel
    ast_sink_valid_1_r        : in std_logic;                       --! Input 1 valid signal, right channel
    ast_sink_error_1_r        : in std_logic_vector( 1 downto 0);   --! Input 1 error, left channel
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Sink)
    ------------------------------------------------------------
    ast_sink_data_2_l         : in std_logic_vector(31 downto 0);   --! Input 2 data, left channel
    ast_sink_valid_2_l        : in std_logic;                       --! Input 2 valid signal, left channel
    ast_sink_error_2_l        : in std_logic_vector( 1 downto 0);   --! Input 2 error, left channel
    ------------------------------------------------------------
    ast_sink_data_2_r         : in std_logic_vector(31 downto 0);   --! Input 2 data, right channel
    ast_sink_valid_2_r        : in std_logic;                       --! Input 2 valid signal, right channel
    ast_sink_error_2_r        : in std_logic_vector( 1 downto 0);   --! Input 2 error, right channel  
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Source)
    ------------------------------------------------------------
    ast_source_data_l       : out std_logic_vector(31 downto 0);    --! Output data, left channel
    ast_source_valid_l      : out std_logic;                        --! Output valid signal, left channel
    ast_source_error_l      : out std_logic_vector( 1 downto 0);    --! Output error, left channel
    ------------------------------------------------------------
    ast_source_data_r       : out std_logic_vector(31 downto 0);    --! Output data, right channel
    ast_source_valid_r      : out std_logic;                        --! Output valid signal, right channel
    ast_source_error_r      : out std_logic_vector( 1 downto 0)     --! Output error, right channel
  );
END FE_QSys_InputMux;  


--! Architecture containing a wrapper between QSys and the input mux component
ARCHITECTURE FE_QSys_InputMux_arch OF FE_QSys_InputMux IS  
  signal selectRegister : std_logic_vector(3 downto 0) := std_logic_vector(to_unsigned(DEFAULT_SOURCE,4));  --! Signal to hold the mux position selected

  --! VHDL component containing the MUX logic
  component FE_InputMux IS
    generic (DEFAULT_SOURCE : integer := DEFAULT_SOURCE);
    port (
    reset_n          : in std_logic;
    input_select     : in integer range 0 to 7;
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Sink)
    ------------------------------------------------------------
    ast_sink_data_1_l         : in std_logic_vector(31 downto 0);
    ast_sink_valid_1_l        : in std_logic;
    ast_sink_error_1_l        : in std_logic_vector( 1 downto 0);
    ------------------------------------------------------------
    ast_sink_data_1_r         : in std_logic_vector(31 downto 0);
    ast_sink_valid_1_r        : in std_logic;
    ast_sink_error_1_r        : in std_logic_vector( 1 downto 0);
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Sink)
    ------------------------------------------------------------
    ast_sink_data_2_l         : in std_logic_vector(31 downto 0);
    ast_sink_valid_2_l        : in std_logic;
    ast_sink_error_2_l        : in std_logic_vector( 1 downto 0);
    ------------------------------------------------------------
    ast_sink_data_2_r         : in std_logic_vector(31 downto 0);
    ast_sink_valid_2_r        : in std_logic;
    ast_sink_error_2_r        : in std_logic_vector( 1 downto 0);   
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Source)
    ------------------------------------------------------------
    ast_source_data_l       : out std_logic_vector(31 downto 0);
    ast_source_valid_l      : out std_logic;
    ast_source_error_l      : out std_logic_vector( 1 downto 0);  
   ------------------------------------------------------------
    ast_source_data_r       : out std_logic_vector(31 downto 0);
    ast_source_valid_r      : out std_logic;
    ast_source_error_r      : out std_logic_vector( 1 downto 0) 
    );
  END component;

  begin
  
    u0 : component FE_InputMux
   port map (
      reset_n => reset_n,
      input_select => to_integer(unsigned(selectRegister)),
      ------------------------------------------------------------
      -- Avalon Streaming Interface Signals (Sink)
      ------------------------------------------------------------
      ast_sink_data_1_l  => ast_sink_data_1_l,
      ast_sink_valid_1_l => ast_sink_valid_1_l,
      ast_sink_error_1_l => ast_sink_error_1_l,
      ------------------------------------------------------------
      ast_sink_data_1_r  => ast_sink_data_1_r,
      ast_sink_valid_1_r => ast_sink_valid_1_r,
      ast_sink_error_1_r => ast_sink_error_1_r,
      ------------------------------------------------------------
      -- Avalon Streaming Interface Signals (Sink)
      ------------------------------------------------------------
      ast_sink_data_2_l  => ast_sink_data_2_l,
      ast_sink_valid_2_l => ast_sink_valid_2_l,
      ast_sink_error_2_l => ast_sink_error_2_l,
      ------------------------------------------------------------
      ast_sink_data_2_r  => ast_sink_data_2_r,
      ast_sink_valid_2_r => ast_sink_valid_2_r,
      ast_sink_error_2_r => ast_sink_error_2_r,
      ------------------------------------------------------------    
      -- Avalon Streaming Interface Signals (Source)
      ------------------------------------------------------------
      ast_source_data_l  => ast_source_data_l,
      ast_source_valid_l => ast_source_valid_l,
      ast_source_error_l => ast_source_error_l,
      ------------------------------------------------------------
      ast_source_data_r  => ast_source_data_r,
      ast_source_valid_r => ast_source_valid_r,
      ast_source_error_r => ast_source_error_r
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
  
