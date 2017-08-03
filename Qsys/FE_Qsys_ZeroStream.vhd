----------------------------------------------------------------------------------
-- Company:          Montana State University
-- Author/Engineer:   Ross Snider 
-- 
-- Create Date:    4/14/2017 
-- Design Name: 
-- Module Name:    FE_Qsys_DownUpBy2.vhd  -  Qsys streaming block that down samples by 2 and has two streaming outputs that are both down sampled by 2
--                                                 It also has two streaming inputs that are summed before being up sampled by 2.
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FE_Qsys_ZeroStream is
   port (
      clk                          : in std_logic;   
      reset_n                      : in std_logic;
      ------------------------------------------------------------
      -- Avalon Streaming Sink Signals 
      ------------------------------------------------------------
      sink_data          : in  std_logic_vector(31 downto 0);  
      sink_valid         : in  std_logic;
      sink_error         : in  std_logic_vector( 1 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Source Signals (downsampled data out)
      ------------------------------------------------------------
      source_data         : out std_logic_vector(31 downto 0);  
      source_valid        : out std_logic;
      source_error        : out std_logic_vector( 1 downto 0)
   );
end FE_Qsys_ZeroStream;

architecture behavior of FE_Qsys_ZeroStream is

begin
   
   source_data  <= (others => '0');  -- set the stream to zerl
   source_valid <= sink_valid;
   source_error <= sink_error;
   
end behavior;



