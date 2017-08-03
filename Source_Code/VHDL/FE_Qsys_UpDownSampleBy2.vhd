----------------------------------------------------------------------------------
-- Company:          Montana State University
-- Author/Engineer:    Ross Snider 
-- 
-- Create Date:    4/14/2017 
-- Design Name: 
-- Module Name:    FE_Qsys_UpDownSampleBy2.vhd  -  Qsys streaming block that down samples by 2 and has two streaming outputs that are both down sampled by 2
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

entity FE_Qsys_UpDownSampleBy2 is
   generic(
      FIR_MIF_FileName_up   : string  := "FE_MIF_FIR_UpSampleBy2.mif";    -- Name of .mif file that contains FIR coefficients
      FIR_MIF_FileName_down : string  := "FE_MIF_FIR_DownSampleBy2.mif";  -- Name of .mif file that contains FIR coefficients
      FIR_Max_Coefs         : integer := 64;                       -- Max Number of 32-bit words in either the up or down .mif file.  Note: address zero contains N, the actual number of cofficients to be used in the FIR filter
      FIR_Addr_Width        : integer := 7                         -- This value must be ceil(log2(FIR_MAX_COEFS)) + 1 since this component implements two FIR filters within the same address space
   );
   port (
      clk                            : in std_logic;   
      reset_n                         : in std_logic;
      ------------------------------------------------------------
      -- Avalon Memory Mapped Slave Signals
      ------------------------------------------------------------
      avs_s1_address               : in  std_logic_vector( FIR_Addr_Width-1 downto 0);  
      avs_s1_write                  : in  std_logic;
      avs_s1_writedata               : in  std_logic_vector(31 downto 0);
      avs_s1_read                  : in  std_logic;
      avs_s1_readdata               : out std_logic_vector(31 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Sink Signals (Channel 1 data coming into downsampler)
      ------------------------------------------------------------
      to_downsampler_data          : in  std_logic_vector(31 downto 0);  -- Data arriving with Fs sample rate
      to_downsampler_valid         : in  std_logic;
      to_downsampler_error         : in  std_logic_vector( 1 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Sink Signals (Channel 2 data coming into summer and upsampler)
      ------------------------------------------------------------
      to_summerUpsampler_ch1_data  : in  std_logic_vector(31 downto 0);  -- Data arriving with Fs/2 sample rate, Channel 2 is summed with Channel 3
      to_summerUpsampler_ch1_valid : in  std_logic;
      to_summerUpsampler_ch1_error : in  std_logic_vector( 1 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Sink Signals (Channel 3 data coming into summer and upsampler)
      ------------------------------------------------------------
      to_summerUpsampler_ch2_data  : in  std_logic_vector(31 downto 0);  -- Data arriving with Fs/2 sample rate, Channel 2 is summed with Channel 3
      to_summerUpsampler_ch2_valid : in  std_logic;
      to_summerUpsampler_ch2_error : in  std_logic_vector( 1 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Source Signals (downsampled data out)
      ------------------------------------------------------------
      downsampled_ch1_data         : out std_logic_vector(31 downto 0);  -- Data leaving with Fs/2 sample rate
      downsampled_ch1_valid        : out std_logic;
      downsampled_ch1_error        : out std_logic_vector( 1 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Source Signals (downsampled data out)
      ------------------------------------------------------------
      downsampled_ch2_data         : out std_logic_vector(31 downto 0);  -- Data leaving with Fs/2 sample rate
      downsampled_ch2_valid        : out std_logic;
      downsampled_ch2_error        : out std_logic_vector( 1 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Source Signals (upsampled data out)
      ------------------------------------------------------------
      summedUpsampled_data         : out std_logic_vector(31 downto 0);  -- Data leaving with Fs sample rate
      summedUpsampled_valid        : out std_logic;
      summedUpsampled_error        : out std_logic_vector( 1 downto 0)
   );
end FE_Qsys_UpDownSampleBy2;

architecture behavior of FE_Qsys_UpDownSampleBy2 is

   component FE_FIR IS
        generic (MAX_COEFS : integer := 512;                          --! Maximum number of coefficients that the filter can handle
                ADDR_WIDTH : integer := 11;                           --! Number of bits required to address MAX_COEF works
                INIT_FILENAME : string := ""                          --! Path to a file containing initial coefficient memory data
        );
        port (
          clk               : in std_logic;                           --! High speed clock for the filter processing
          reset_n           : in std_logic;                           --! Active low reset pin
          ------------------------------------------------------------
          -- Register Interface
          ------------------------------------------------------------
          mem_data_in       : in std_logic_vector(31 downto 0);           --! Write Data in to the data registers to set coefficients
          mem_data_out      : out std_logic_vector(31 downto 0);          --! Read Data @todo Doesn't work
          mem_clk           : in std_logic;                               --! @Clock for the memory interface
          mem_addr          : in std_logic_vector(ADDR_WIDTH-1 downto 0); --! Address to write to in the register space
          mem_wren          : in std_logic;                               --! write enable
          mem_rden          : in std_logic;                               --! read enable    
          ------------------------------------------------------------
          -- Streaming Data Interface
          ------------------------------------------------------------  
          data_in           : in std_logic_vector(31 downto 0);       --! Data coming in to the system as a 32 bit integer (non-float).  Fixed point is at developers discretion.
          data_out          : out std_logic_vector(31 downto 0);      --! Data coming in to the system as a 32 bit integer (non-float).  Fixed point place place will match inputs.
          valid_in          : in std_logic;                           --! Single bit wide pulse at clk to specify that new data is present on data_in
          valid_out         : out std_logic                           --! Single bit wide pulse at clk to specify that new data is present on data_out
        );
   end component;

    -------------------------------------------------------
   -- Internal signals
   -------------------------------------------------------
   signal reset               : std_logic;
   signal FIR_down_data_valid : std_logic;
   signal FIR_down_data_out   : std_logic_vector(31 downto 0);
   signal FIR_down_data       : std_logic_vector(31 downto 0);
   signal FIR_up_data_valid   : std_logic;
   signal FIR_up_data_out     : std_logic_vector(31 downto 0);
   signal FIR_up_data         : std_logic_vector(31 downto 0);
   signal FIR_down_address    : std_logic_vector(FIR_Addr_Width-2 downto 0);
   signal FIR_up_address      : std_logic_vector(FIR_Addr_Width-2 downto 0);
   signal FIR_up_wren         : std_logic;
   signal FIR_down_wren       : std_logic;
   signal FIR_up_rden         : std_logic;
   signal FIR_down_rden       : std_logic;
   signal Fs_valid         : std_logic;  -- valid signal at Fs rate
   signal Fsd2_valid       : std_logic;  -- valid signal at Fs/2 rate
   signal up_data          : signed(31 downto 0);
   signal downsampler_data : std_logic_vector(31 downto 0);
   signal ch1_data         : signed(31 downto 0);
   signal ch2_data         : signed(31 downto 0);
   signal ch12_summed_data : signed(31 downto 0);
   
   --------------------------------------------------------------
   -- States for streaming valid signal generation
   --------------------------------------------------------------
   type state_type is (sample1,sample2);
   signal state : state_type := sample1;

begin
   ----------------------------------------------------------------
   -- Signal renaming
   ----------------------------------------------------------------
   reset            <= not reset_n;
   Fs_valid         <= to_downsampler_valid;  -- valid pulse at Fs rate
   
   ----------------------------------------------------------------
   -- Read from Avalon Sink (Channel 1)
   ----------------------------------------------------------------
   process(clk)
   begin
      if rising_edge(clk) and (to_downsampler_valid = '1') then
         downsampler_data <= to_downsampler_data;
      end if;
   end process;
   ----------------------------------------------------------------
   -- Read from Avalon Sink (Channel 2)
   ----------------------------------------------------------------
   process(clk)
   begin
      if rising_edge(clk) and (to_summerUpsampler_ch1_valid = '1') then
         ch1_data <= signed(to_summerUpsampler_ch1_data);
      end if;
   end process;
   ----------------------------------------------------------------
   -- Read from Avalon Sink (Channel 3)
   ----------------------------------------------------------------
   process(clk)
   begin
      if rising_edge(clk) and (to_summerUpsampler_ch2_valid = '1') then
         ch2_data <= signed(to_summerUpsampler_ch2_data);
      end if;
   end process;
   
   ch12_summed_data <= ch1_data + ch2_data;

   
   ----------------------------------------------------------------
   -- Determine which FIR coefficient memory to read/write from/to
   -- and pass through the appropriate read/write enables
   ----------------------------------------------------------------
   process(avs_s1_address(FIR_Addr_Width-1),avs_s1_write,avs_s1_read)
   begin
      if (avs_s1_address(FIR_Addr_Width-1) = '0') then  -- up memory is first block
         FIR_up_wren   <= avs_s1_write;
         FIR_up_rden   <= avs_s1_read;
         FIR_down_wren <= '0';
         FIR_down_rden <= '0';
      else
         FIR_down_wren <= avs_s1_write;                 -- down memory is second block
         FIR_down_rden <= avs_s1_read;
         FIR_up_wren   <= '0';
         FIR_up_rden   <= '0';
      end if;
   end process;
               
--   ----------------------------------------------------------------
--   -- FIR low pass for up sampling,  
--   -- Memory for coefficients are mapped to first block
--   ----------------------------------------------------------------   
   up1 : FE_FIR
     generic map (
       MAX_COEFS         => FIR_MAX_COEFS,
       ADDR_WIDTH        => FIR_Addr_Width-1,  
       INIT_FILENAME     => FIR_MIF_FileName_up
     )                        
     port map (
       clk               => clk,
       reset_n           => reset_n,
       mem_data_in       => avs_s1_writedata,
       mem_data_out      => avs_s1_readdata,
       mem_clk           => clk,
       mem_addr          => avs_s1_address(FIR_Addr_Width-2 downto 0),
       mem_wren          => FIR_up_wren,
       mem_rden          => FIR_up_rden,
       data_in           => std_logic_vector(ch12_summed_data),
       data_out          => FIR_up_data_out,
       valid_in          => Fs_valid,
       valid_out         => FIR_up_data_valid
     );
     
   process(clk)
   begin
      if rising_edge(clk) and (FIR_up_data_valid = '1') then
         FIR_up_data <= FIR_up_data_out;
      end if;
   end process;
     
   ----------------------------------------------------------------
   -- FIR low pass for down sampling
   -- Memory for coefficients are mapped to second block
   ----------------------------------------------------------------   
   down1 : FE_FIR
     generic map (
       MAX_COEFS         => FIR_MAX_COEFS,
       ADDR_WIDTH        => FIR_Addr_Width-1, 
       INIT_FILENAME     => FIR_MIF_FileName_down
     )                        
     port map (
       clk               => clk,
       reset_n           => reset_n,
       mem_data_in       => avs_s1_writedata,
       mem_data_out      => avs_s1_readdata,
       mem_clk           => clk,
       mem_addr          => avs_s1_address(FIR_Addr_Width-2 downto 0),
       mem_wren          => FIR_down_wren,
       mem_rden          => FIR_down_rden,
       data_in           => downsampler_data,
       data_out          => FIR_down_data_out,
       valid_in          => to_downsampler_valid,
       valid_out         => FIR_down_data_valid
     );

   process(clk)
   begin
      if rising_edge(clk) and (FIR_down_data_valid = '1') then
         FIR_down_data <= FIR_down_data_out;
      end if;
   end process;
          



    -----------------------------------------------------------
    -- UpDownsample State Machine 
    -- switch states at Fs rate
    -----------------------------------------------------------
   process (clk, reset)
   begin
      if reset = '1' then
         state <= sample1;
      elsif (rising_edge(clk)) then
         case state is
            --------------------------------------------
            when sample1 =>
               if (Fs_valid = '1') then
                  state <= sample2;
               else
                  state <= sample1;
               end if;
            --------------------------------------------
            when sample2 =>
               if (Fs_valid = '1') then
                  state <= sample1;
               else
                  state <= sample2;
               end if;
            --------------------------------------------
            when others =>
               state <= sample1;
         end case;
      end if;
   end process;
   
    -----------------------------------------------------------
    -- UpDownsample State Machine 
    -- states are switched at Fs rate
    -----------------------------------------------------------
   process (clk, reset)
   begin
      case state is
         when sample1  =>  
            Fsd2_valid    <= Fs_valid;
            up_data       <= ch12_summed_data;
         when sample2  => 
            Fsd2_valid    <= '0';
            up_data       <= (others => '0');   -- insert zeros before low pass filtering when up sampling
         when others =>  -- Do Nothing
      end case;
   end process;
   
   ----------------------------------------------------------------
   -- Generate downsampled streaming data
   ----------------------------------------------------------------
   process(clk)
   begin
      if rising_edge(clk) and (Fsd2_valid = '1') then
         ---------------------------------------------
         -- ch1 streaming signals
         ---------------------------------------------
         downsampled_ch1_data  <= FIR_down_data;
         downsampled_ch1_valid <= Fsd2_valid;
         downsampled_ch1_error <= to_downsampler_error;  -- just pass through any error signals
         ---------------------------------------------
         -- ch2 streaming signals
         ---------------------------------------------
         downsampled_ch2_data  <= FIR_down_data;
         downsampled_ch2_valid <= Fsd2_valid;
         downsampled_ch2_error <= to_downsampler_error;  -- just pass through any error signals
      end if;
   end process;
   
   
   ------------------------------------------------------------
   -- Generate upsample streaming data
   ------------------------------------------------------------
   summedUpsampled_data   <= FIR_up_data;
   summedUpsampled_valid  <= Fs_valid;
   summedUpsampled_error  <= to_summerUpsampler_ch1_error or to_summerUpsampler_ch2_error;
   
   
   
end behavior;



