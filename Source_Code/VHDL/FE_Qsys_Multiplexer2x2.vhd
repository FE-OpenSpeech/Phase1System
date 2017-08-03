----------------------------------------------------------------------------------
-- Company:          Montana State University
-- Author/Engineer:    Ross Snider 
-- 
-- Create Date:    4/14/2017 
-- Design Name: 
-- Module Name:    FE_Qsys_Multiplexer2x2.vhd  
--                                                 
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

entity FE_Qsys_Multiplexer2x2 is
   port (
      clk                       : in std_logic;   
      reset_n                    : in std_logic;
      ------------------------------------------------------------
      -- Avalon Memory Mapped Slave Signals
      ------------------------------------------------------------
      avs_s1_address          : in  std_logic_vector( 1 downto 0);  
      avs_s1_write             : in  std_logic;
      avs_s1_writedata          : in  std_logic_vector(31 downto 0);
      avs_s1_read             : in  std_logic;
      avs_s1_readdata          : out std_logic_vector(31 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Sink Signals (Channel 1)
      ------------------------------------------------------------
      ch1_sink_data           : in  std_logic_vector(31 downto 0);  
      ch1_sink_valid          : in  std_logic;
      ch1_sink_error          : in  std_logic_vector( 1 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Sink Signals (Channel 2)
      ------------------------------------------------------------
      ch2_sink_data           : in  std_logic_vector(31 downto 0);  
      ch2_sink_valid          : in  std_logic;
      ch2_sink_error          : in  std_logic_vector( 1 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Source Signals (channel 1)
      ------------------------------------------------------------
      ch1_source_data         : out std_logic_vector(31 downto 0);  
      ch1_source_valid        : out std_logic;
      ch1_source_error        : out std_logic_vector( 1 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Source Signals (channel 2)
      ------------------------------------------------------------
      ch2_source_data         : out std_logic_vector(31 downto 0);  
      ch2_source_valid        : out std_logic;
      ch2_source_error        : out std_logic_vector( 1 downto 0);
       ------------------------------------------------------------
      -- external
      ------------------------------------------------------------
      switches                : in  std_logic_vector(3 downto 0);
<<<<<<< .mine
	   leds                    : out std_logic_vector(3 downto 0)
	);
||||||| .r130
	   leds                    : out std_logic_vector(3 downto 0);
	);
=======
      leds                    : out std_logic_vector(3 downto 0);
   );
>>>>>>> .r142
end FE_Qsys_Multiplexer2x2;

architecture behavior of FE_Qsys_Multiplexer2x2 is


    -------------------------------------------------------
   -- Internal signals
   -------------------------------------------------------
   signal reset               : std_logic;
   signal reg0                : std_logic_vector(31 downto 0) := (others => '0');  -- if reg0 contains a zero value, control is passed to the switches, otherwise the register controls the multiplexing
   signal muxcontrol          : std_logic_vector( 3 downto 0);
   
begin
   ----------------------------------------------------------------
   -- Signal renaming
   ----------------------------------------------------------------
   reset <= not reset_n;
   
   ---------------------------------------------------
   -- Write to Registers
   ---------------------------------------------------
   process (clk)
   begin
      if rising_edge(clk) and (avs_s1_write = '1') then
         case avs_s1_address is
            when "00"   => reg0 <= avs_s1_writedata(31 downto 0);
            when others => -- do nothing
            end case;
      end if;
   end process;

   ---------------------------------------------------
   -- Read from Registers
   ---------------------------------------------------
   process(clk)
   begin
      if rising_edge(clk) and (avs_s1_read = '1') then
         case avs_s1_address is
            when "00"   => avs_s1_readdata <= reg0;
            when others => avs_s1_readdata <= (others => '0');
            end case;
      end if;
   end process;
   
   ----------------------------------------------------------------
   -- Determine who controls mux
   -- if bit0 = 1  in register 0, then mux is under software control
   -- otherwise it is under external switch control
   -- switch control is default since reg0 powers up as zero
<<<<<<< .mine
	----------------------------------------------------------------
	process(reg0)
	begin
	   if (reg0(0) = '0') then           -- mux under external switch control if bit0=0
		   muxcontrol <= switches;
		else
	      muxcontrol <= reg0(4 downto 1); -- mux under software control if bit0=1
      end if;
	end process;
||||||| .r130
	----------------------------------------------------------------
	process(reg0)
	begin
	   if (reg0(0) = '0') then           -- mux under external switch control if bit0=0
		   muxcontrol <= switches;
		else
	      muxcontrol <= reg(4 downto 1); -- mux under software control if bit0=1
	end
=======
   ----------------------------------------------------------------
   process(reg0)
   begin
      if (reg0(0) = '0') then           -- mux under external switch control if bit0=0
         muxcontrol <= switches;
      else
         muxcontrol <= reg(4 downto 1); -- mux under software control if bit0=1
   end
>>>>>>> .r142

   ----------------------------------------------------------------
   -- ch1,ch2 mux
   ----------------------------------------------------------------
   process(muxcontrol, ch1_sink_data, ch1_sink_valid, ch1_sink_error, ch2_sink_data, ch2_sink_valid, ch2_sink_error)
   begin
      case muxcontrol is
         ----------------------------------------------------------
         when "0000" =>   -- both channels zeroed
            ch1_source_data   <= (others => '0');   -- ch1 <= 0
            ch1_source_valid  <= ch1_sink_valid;
            ch1_source_error  <= ch1_sink_error;
            ch2_source_data   <= (others => '0');   -- ch2 <= 0
            ch2_source_valid  <= ch2_sink_valid;
            ch2_source_error  <= ch2_sink_error;
          ----------------------------------------------------------
         when "0001" =>   -- pass ch1, zero ch2
            ch1_source_data   <= ch1_sink_data;     -- ch1 <= ch1
            ch1_source_valid  <= ch1_sink_valid;
            ch1_source_error  <= ch1_sink_error;
            ch2_source_data   <= (others => '0');   -- ch2 <= 0
            ch2_source_valid  <= ch2_sink_valid;
            ch2_source_error  <= ch2_sink_error;
         ----------------------------------------------------------
         when "0010" =>   -- zero ch1, pass ch2
            ch1_source_data   <= (others => '0');   -- ch1 <= 0
            ch1_source_valid  <= ch1_sink_valid;
            ch1_source_error  <= ch1_sink_error;
            ch2_source_data   <= ch2_sink_data;     -- ch2 <= ch2
            ch2_source_valid  <= ch2_sink_valid;
            ch2_source_error  <= ch2_sink_error;
         ----------------------------------------------------------
         when "0011" =>   -- pass ch1, pass ch2 (passthrough)
            ch1_source_data   <= ch1_sink_data;     -- ch1 <= ch1
            ch1_source_valid  <= ch1_sink_valid;
            ch1_source_error  <= ch1_sink_error;
            ch2_source_data   <= ch2_sink_data;     -- ch2 <= ch2
            ch2_source_valid  <= ch2_sink_valid;
            ch2_source_error  <= ch2_sink_error;
         ----------------------------------------------------------
         -- cross ch1 <-> ch2
         ----------------------------------------------------------
         when "0100" =>   -- both channels zeroed
            ch1_source_data   <= (others => '0');   -- ch1 <= 0
            ch1_source_valid  <= ch2_sink_valid;
            ch1_source_error  <= ch2_sink_error;
            ch2_source_data   <= (others => '0');   -- ch2 <= 0
            ch2_source_valid  <= ch1_sink_valid;
            ch2_source_error  <= ch1_sink_error;
          ----------------------------------------------------------
         when "0101" =>   -- pass ch1, zero ch2
            ch2_source_data   <= ch1_sink_data;     -- ch2 <= ch1
            ch2_source_valid  <= ch1_sink_valid;
            ch2_source_error  <= ch1_sink_error;
            ch1_source_data   <= (others => '0');   -- ch1 <= 0
            ch1_source_valid  <= ch2_sink_valid;
            ch1_source_error  <= ch2_sink_error;
         ----------------------------------------------------------
         when "0110" =>   -- zero ch1, pass ch2
            ch2_source_data   <= (others => '0');   -- ch2 <= 0
            ch2_source_valid  <= ch1_sink_valid;
            ch2_source_error  <= ch1_sink_error;
            ch1_source_data   <= ch2_sink_data;     -- ch1 <= ch2
            ch1_source_valid  <= ch2_sink_valid;
            ch1_source_error  <= ch2_sink_error;
         ----------------------------------------------------------
         when "0111" =>   -- pass ch1, pass ch2 (cross passthrough)
            ch2_source_data   <= ch1_sink_data;     -- ch2 <= ch1
            ch2_source_valid  <= ch1_sink_valid;
            ch2_source_error  <= ch1_sink_error;
            ch1_source_data   <= ch2_sink_data;     -- ch1 <= ch2
            ch1_source_valid  <= ch2_sink_valid;
            ch1_source_error  <= ch2_sink_error;
         ----------------------------------------------------------
         ----------------------------------------------------------
         when others =>   -- pass ch1, pass ch2 (all zeros)
            ch1_source_data   <= (others => '0');     -- ch1 <= ch1
            ch1_source_valid  <= ch1_sink_valid;
            ch1_source_error  <= ch1_sink_error;
            ch2_source_data   <= (others => '0');     -- ch2 <= ch2
            ch2_source_valid  <= ch2_sink_valid;
            ch2_source_error  <= ch2_sink_error;
      end case;
   end process;
   
end behavior;



