----------------------------------------------------------------------------------
-- Company:          Montana State University
-- Author/Engineer:    Ross Snider 
-- 
-- Create Date:    4/14/2017 
-- Design Name: 
-- Module Name:    FE_Qsys_BP_2Kto4K_Fs12K.vhd  -  Qsys streaming block that down samples by 2 and has two streaming outputs that are both down sampled by 2
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

entity FE_Qsys_BP_2Kto4K_Fs12K is
    port (
      clk                            : in std_logic;   
      reset_n                        : in std_logic;
      clk_3072                       : in std_logic;   
   ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Sink)
    ------------------------------------------------------------
    ast_sink_data         : in  std_logic_vector(31 downto 0);
    ast_sink_valid        : in  std_logic;
    ast_sink_error        : in  std_logic_vector( 1 downto 0);
    ------------------------------------------------------------
    -- Avalon Streaming Interface Signals (Source)
    ------------------------------------------------------------
    ast_source_data       : out std_logic_vector(31 downto 0);
    ast_source_valid      : out std_logic;
    ast_source_error      : out std_logic_vector( 1 downto 0)
    );
end FE_Qsys_BP_2Kto4K_Fs12K;

architecture behavior of FE_Qsys_BP_2Kto4K_Fs12K is

   component HA_BP_2Kto4K_Fs12K IS
      PORT( clk_3072                        :   IN    std_logic;   -- clock at 3.072 MHz = 48 KHz * 64, which is the bit clock rate at 48 KHz coming from the AD1939
            reset                           :   IN    std_logic; 
            samples_in                      :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28
            valid_in                        :   IN    std_logic;  -- valid in a Fs rate = 48 KHz
            samples_out                     :   OUT   std_logic_vector(31 DOWNTO 0); -- sfix32_En28
            ce_out                          :   OUT   std_logic  
      );
   END component;
	
	component FE_make_pulse is
		port (
			clk          : in  std_logic;                     -- clock that trigger pulse comes in on.
			clk2         : in  std_logic;                     -- clock that the output pulse will be generated on.
			reset        : in  std_logic;
			trigger      : in  std_logic;                     -- rising edge of trigger is the actual trigger
			pulse        : out std_logic;                     -- pulse
			pulse_width  : in  std_logic_vector(9 downto 0)   -- max pulse wdith of 1024
		);
	end component;



    -------------------------------------------------------
   -- Internal signals
   -------------------------------------------------------
   signal reset               : std_logic;
   signal ce_out              : std_logic;
   signal valid_pulse         : std_logic;
   signal data_in             : std_logic_vector(31 downto 0);
   signal data_out            : std_logic_vector(31 downto 0);
   
 begin
   ----------------------------------------------------------------
   -- Signal renaming
   ----------------------------------------------------------------
   reset            <= not reset_n;
   
   process(clk)
   begin
       if rising_edge(clk) and ast_sink_valid = '1' then
           data_in <= ast_sink_data;
       end if;
   end process;
	
	pulse1 : FE_make_pulse port map(
			clk           =>  clk,
			clk2          =>  clk_3072,
			reset         =>  reset,
			trigger       =>  ast_sink_valid ,
			pulse         =>  valid_pulse,
			pulse_width   =>  "0000000001"  
		);	

   bandpass_2k_4k : HA_BP_2Kto4K_Fs12K port map( 
      clk_3072    =>  clk_3072,
      reset       =>  reset,
      samples_in  =>  data_in,
      valid_in    =>  valid_pulse,
      samples_out =>  data_out,
      ce_out      =>  ce_out
   );

   
   ast_source_data  <= data_out;
   ast_source_valid <= ast_sink_valid;
   ast_source_error <= ast_sink_error;  
   
end behavior;



