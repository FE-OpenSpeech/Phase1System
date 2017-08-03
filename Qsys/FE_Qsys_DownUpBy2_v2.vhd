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

entity FE_Qsys_DownUpBy2_v2 is
   generic(
      FIR_MIF_FileName_up   : string  := "FE_MIF_FIR_UpSampleBy2.mif";    -- Name of .mif file that contains FIR coefficients
      FIR_MIF_FileName_down : string  := "FE_MIF_FIR_DownSampleBy2.mif";  -- Name of .mif file that contains FIR coefficients
      FIR_Max_Coefs         : integer := 256;                       -- Max Number of 32-bit words in either the up or down .mif file.  Note: address zero contains N, the actual number of cofficients to be used in the FIR filter
      FIR_Addr_Width        : integer := 8                         -- This value must be ceil(log2(FIR_MAX_COEFS)) since this component implements two FIR filters within the same address space
   );
   port (
      clk                          : in std_logic;   
      reset_n                      : in std_logic;
      ------------------------------------------------------------
      -- Avalon Memory Mapped Slave Signals
      ------------------------------------------------------------
      avs_s1_address               : in  std_logic_vector( FIR_Addr_Width-1 downto 0);  
      avs_s1_write                 : in  std_logic;
      avs_s1_writedata             : in  std_logic_vector(31 downto 0);
      avs_s1_read                  : in  std_logic;
      avs_s1_readdata              : out std_logic_vector(31 downto 0);
      ------------------------------------------------------------
      -- Avalon Memory Mapped Slave Signals
      ------------------------------------------------------------
      avs_s2_address               : in  std_logic_vector( FIR_Addr_Width-1 downto 0);  
      avs_s2_write                 : in  std_logic;
      avs_s2_writedata             : in  std_logic_vector(31 downto 0);
      avs_s2_read                  : in  std_logic;
      avs_s2_readdata              : out std_logic_vector(31 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Sink Signals (Channel 1 data coming into downsampler)
      ------------------------------------------------------------
      to_downsampler_data          : in  std_logic_vector(31 downto 0);  -- Data arriving with Fs sample rate
      to_downsampler_valid         : in  std_logic;
      to_downsampler_error         : in  std_logic_vector( 1 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Sink Signals (Channel 2 data coming into summer and upsampler)
      ------------------------------------------------------------
      to_Upsampler_data            : in  std_logic_vector(31 downto 0);  -- Data arriving with Fs/2 sample rate, Channel 2 is summed with Channel 3
      to_Upsampler_valid           : in  std_logic;
      to_Upsampler_error           : in  std_logic_vector( 1 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Source Signals (downsampled data out)
      ------------------------------------------------------------
      downsampled_data             : out std_logic_vector(31 downto 0);  -- Data leaving with Fs/2 sample rate
      downsampled_valid            : out std_logic;
      downsampled_error            : out std_logic_vector( 1 downto 0);
      ------------------------------------------------------------
      -- Avalon Streaming Source Signals (upsampled data out)
      ------------------------------------------------------------
      Upsampled_data               : out std_logic_vector(31 downto 0);  -- Data leaving with Fs sample rate
      Upsampled_valid              : out std_logic;
      Upsampled_error              : out std_logic_vector( 1 downto 0)
   );
end FE_Qsys_DownUpBy2_v2;

architecture behavior of FE_Qsys_DownUpBy2_v2 is

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
   signal reset                : std_logic;
   signal FIR_down_valid_in    : std_logic;
   signal FIR_down_valid_out   : std_logic;
   signal FIR_down_data_in     : std_logic_vector(31 downto 0);
   signal FIR_down_data_out    : std_logic_vector(31 downto 0);
   signal filtered_data_down   : std_logic_vector(31 downto 0);
   signal filtered_data_down_hold   : std_logic_vector(31 downto 0);
   signal filtered_data_up     : std_logic_vector(31 downto 0);
   signal FIR_up_valid_in      : std_logic;
   signal FIR_up_valid_out     : std_logic;
   signal FIR_up_data_in       : std_logic_vector(31 downto 0);
   signal FIR_up_data_out      : std_logic_vector(31 downto 0);
   signal FIR_downsampled_data : std_logic_vector(31 downto 0);
   signal Fs_valid             : std_logic;  -- valid signal at Fs rate
   signal Fsd2_valid           : std_logic;  -- valid signal at Fs/2 rate
   signal up_data              : std_logic_vector(31 downto 0);
   signal downsampler_data     : std_logic_vector(31 downto 0);
   signal upsampler_data_1     : std_logic_vector(31 downto 0);
   signal upsampler_data_2     : std_logic_vector(31 downto 0);
   signal summed_data          : signed(31 downto 0);
   signal interpolated_data_1  : signed(31 downto 0);
   signal interpolated_data_2  : signed(31 downto 0);
   
   --------------------------------------------------------------
   -- States for streaming valid signal generation
   --------------------------------------------------------------
   type state_type is (s1_wait, s1_FIR_capture, s1_FIR_start, s1_FIR_wait, s1_FIR_done,
                       s2_wait, s2_FIR_capture, s2_FIR_start, s2_FIR_wait, s2_FIR_done);
   signal state : state_type := s1_wait;

begin
   ----------------------------------------------------------------
   -- Signal renaming
   ----------------------------------------------------------------
   reset            <= not reset_n;
   Fs_valid         <= to_downsampler_valid;  -- Valid pulse at Fs rate
   
   ----------------------------------------------------------------
   -- Read from Avalon Sink (Channel 1 at Fs rate)
   -- and also put out the upsampled data at the Fs rate
   ----------------------------------------------------------------
   process(clk)
   begin
      if rising_edge(clk) and (to_downsampler_valid = '1') then  -- data in at Fs rate
         downsampler_data <= to_downsampler_data;    -- sent directly to FIR_down
         Upsampled_data   <= filtered_data_up;       -- data out at Fs rate
         downsampled_data <= filtered_data_down;
      end if;
   end process;
   downsampled_valid <= Fsd2_valid;           -- valid at Fs/2 rate
   downsampled_error <= to_downsampler_error; -- the error is just passed through
   Upsampled_valid   <= to_downsampler_valid; -- valid at Fs rate
   Upsampled_error   <= to_Upsampler_error;   -- the error is just passed through

   ----------------------------------------------------------------
   -- Read from Avalon Sink (Channel 2 at Fs/2 rate)
   ----------------------------------------------------------------
   process(clk)
   begin
      if rising_edge(clk) and (to_Upsampler_valid = '1') then  -- data in at Fs/2 rate
         upsampler_data_2    <= upsampler_data_1;              -- delay Fs/2 input data
         upsampler_data_1    <= to_Upsampler_data;             -- Fs/2 input data
         interpolated_data_2 <= interpolated_data_1;
      end if;
   end process;   
   summed_data         <= signed(upsampler_data_1) + signed(upsampler_data_2);
   interpolated_data_1 <= shift_right(summed_data,1);    -- interpolate between Fs/2 data
            
--  ----------------------------------------------------------------
-- -- FIR low pass for up sampling,  
-- -- Memory for coefficients are mapped to first block
-- ----------------------------------------------------------------  
   up1 : FE_FIR
     generic map (
       MAX_COEFS         => FIR_MAX_COEFS,
       ADDR_WIDTH        => FIR_Addr_Width,  
       INIT_FILENAME     => FIR_MIF_FileName_up
     )                        
     port map (
       clk               => clk,
       reset_n           => reset_n,
       mem_data_in       => avs_s2_writedata,
       mem_data_out      => avs_s2_readdata,
       mem_clk           => clk,
       mem_addr          => avs_s2_address(FIR_Addr_Width-1 downto 0),
       mem_wren          => avs_s2_write,
       mem_rden          => avs_s2_read,
       data_in           => FIR_up_data_in,
       data_out          => FIR_up_data_out,
       valid_in          => FIR_up_valid_in,
       valid_out         => FIR_up_valid_out
     );
     
   ----------------------------------------------------------------
   -- FIR low pass for down sampling
   -- Memory for coefficients are mapped to second block
   ----------------------------------------------------------------  
   down1 : FE_FIR
     generic map (
       MAX_COEFS         => FIR_MAX_COEFS,
       ADDR_WIDTH        => FIR_Addr_Width, 
       INIT_FILENAME     => FIR_MIF_FileName_down
     )                        
     port map (
       clk               => clk,
       reset_n           => reset_n,
       mem_data_in       => avs_s1_writedata,
       mem_data_out      => avs_s1_readdata,
       mem_clk           => clk,
       mem_addr          => avs_s1_address(FIR_Addr_Width-1 downto 0),
       mem_wren          => avs_s1_write,
       mem_rden          => avs_s1_read,
       data_in           => FIR_down_data_in,
       data_out          => FIR_down_data_out,
       valid_in          => FIR_down_valid_in,
       valid_out         => FIR_down_valid_out
     );
        

    -----------------------------------------------------------
    -- UpDownsample State Machine 
    -----------------------------------------------------------
   process (clk, reset)
   begin
      if reset = '1' then
         state <= s1_wait;
      elsif (rising_edge(clk)) then
         case state is
            --------------------------------------------
            -- S1
            --------------------------------------------
            when s1_wait =>
               if (Fs_valid = '1') then
                  state <= s1_FIR_capture;
               else
                  state <= s1_wait;
               end if;
            --------------------------------------------
            when s1_FIR_capture =>
               state <= s1_FIR_start;
            --------------------------------------------
            when s1_FIR_start =>
               state <= s1_FIR_wait;
            --------------------------------------------
            when s1_FIR_wait =>
               if (FIR_up_valid_out = '1') then  -- Note: we are transitioning on FIR_up_valid since we have plenting of time to capture the FIR_down_data in state s2_wait, since FIR_down_data is a registered output (rather than transitioning on FIR_down_valid)
                  state <= s1_FIR_done;
               else
                  state <= s1_FIR_wait;
               end if;
            --------------------------------------------
            when s1_FIR_done =>
               state <= s2_wait;
            --------------------------------------------
            -- S2
            --------------------------------------------
            when s2_wait =>
               if (Fs_valid = '1') then
                  state <= s2_FIR_capture;
               else
                  state <= s2_wait;
               end if;
            --------------------------------------------
            when s2_FIR_capture =>
               state <= s2_FIR_start;
            --------------------------------------------
            when s2_FIR_start =>
               state <= s2_FIR_wait;
            --------------------------------------------
            when s2_FIR_wait =>
               if (FIR_up_valid_out = '1') then  -- Note: we are transitioning on FIR_up_valid since we have plenting of time to capture the FIR_down_data in state s2_wait, since FIR_down_data is a registered output (rather than transitioning on FIR_down_valid)
                  state <= s2_FIR_done;
               else
                  state <= s2_FIR_wait;
               end if;
            --------------------------------------------
            when s2_FIR_done =>
               state <= s1_wait;
            --------------------------------------------
            when others =>
               state <= s1_wait;
         end case;
      end if;
   end process;
   
    -----------------------------------------------------------
    -- UpDownsample State Machine 
    -----------------------------------------------------------
   process (state, Fs_valid, upsampler_data_2, downsampler_data, FIR_up_data_out, FIR_down_data_out, interpolated_data_2)
   begin
      ---------------------------------
      -- Default signal values
      ---------------------------------
      Fsd2_valid         <= '0';
      FIR_up_valid_in    <= '0';
      FIR_down_valid_in  <= '0';
      case state is
            --------------------------------------------
            --             --- S1 ----
            --------------------------------------------
            when s1_wait =>
                Fsd2_valid <= Fs_valid;          -- Fsd2_valid is Fs/2 
            --------------------------------------------
            when s1_FIR_capture => 
                FIR_up_data_in   <= upsampler_data_2; 
                FIR_down_data_in <= downsampler_data;
            --------------------------------------------
            when s1_FIR_start =>
                FIR_up_valid_in    <= '1';
                FIR_down_valid_in  <= '1';
            --------------------------------------------
            when s1_FIR_wait =>
                -- do nothing
            --------------------------------------------
            when s1_FIR_done =>
                filtered_data_up        <= upsampler_data_2;
                filtered_data_down      <= downsampler_data;
                filtered_data_down_hold <= downsampler_data;
                
                --filtered_data_up   <= FIR_up_data_out;
                --filtered_data_down <= FIR_down_data_out;
            --------------------------------------------
            --             --- S2 ----
            --------------------------------------------
            when s2_wait =>
               -- do nothing
            --------------------------------------------
            when s2_FIR_capture =>
                FIR_up_data_in   <= std_logic_vector(interpolated_data_2);  
                FIR_down_data_in <= downsampler_data;
            --------------------------------------------
            when s2_FIR_start =>
                FIR_up_valid_in    <= '1';
                FIR_down_valid_in  <= '1';
           --------------------------------------------
            when s2_FIR_wait =>
                -- do nothing
            --------------------------------------------
            when s2_FIR_done =>
                filtered_data_up   <= std_logic_vector(interpolated_data_2);  
                filtered_data_down <= filtered_data_down_hold;
                
                --filtered_data_up   <= FIR_up_data_out;
                --filtered_data_down <= FIR_down_data_out;
           --------------------------------------------
            when others =>  -- Do Nothing
      end case;
   end process;
   
   
    
   
end behavior;



