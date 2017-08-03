LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY HA128_DRC_system IS
    PORT( 
        clk                 :   IN    std_logic;  -- system clock (50 Mhz)
        clk_3072            :   IN    std_logic;  -- clock at 3.072 MHz = 48 KHz * 64, which is the bit clock rate at 48 KHz coming from the AD1939
        reset               :   IN    std_logic; 
        band1_gain          :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16  -- Gain of HA for 2K  - 4K  Bandpass filter  (assuming 48 KHz sample rate)
        band1_drc_threshold :   IN    std_logic_vector(31 DOWNTO 0);  -- W32F16  -- compression threshold
        band1_drc_gain1     :   IN    std_logic_vector(31 DOWNTO 0);  -- W32F16  -- Gain applied if below compression threshold
        band1_drc_gain2     :   IN    std_logic_vector(31 DOWNTO 0);  -- W32F16  -- Gain applied if above compression threshold
        band1_drc_exponent  :   IN    std_logic_vector(31 DOWNTO 0);  -- W32F16  -- Gain applied if above compression threshold
        band1_drc_bypass    :   IN    std_logic;                      -- bypassed when asserted (1)
        band1_delay         :   IN    std_logic_vector(11 DOWNTO 0);  -- uint12       -- delay in clock cycles that is running at Fs_clk rate 
        band2_gain          :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16  -- Gain of HA for 1K  - 2K  Bandpass filter
        band2_drc_threshold :   IN    std_logic_vector(31 DOWNTO 0);  -- W32F16  -- compression threshold
        band2_drc_gain1     :   IN    std_logic_vector(31 DOWNTO 0);  -- W32F16  -- Gain applied if below compression threshold
        band2_drc_gain2     :   IN    std_logic_vector(31 DOWNTO 0);  -- W32F16  -- Gain applied if above compression threshold
        band2_drc_exponent  :   IN    std_logic_vector(31 DOWNTO 0);  -- W32F16  -- Gain applied if above compression threshold
        band2_drc_bypass    :   IN    std_logic;                      -- bypassed when asserted (1)
        band2_delay         :   IN    std_logic_vector(11 DOWNTO 0);  -- uint12       -- delay in clock cycles that is running at Fs_clk rate 
        band3_gain          :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16  -- Gain of HA for 500 - 1K  Bandpass filter
        band3_drc_threshold :   IN    std_logic_vector(31 DOWNTO 0);  -- W32F16  -- compression threshold
        band3_drc_gain1     :   IN    std_logic_vector(31 DOWNTO 0);  -- W32F16  -- Gain applied if below compression threshold
        band3_drc_gain2     :   IN    std_logic_vector(31 DOWNTO 0);  -- W32F16  -- Gain applied if above compression threshold
        band3_drc_exponent  :   IN    std_logic_vector(31 DOWNTO 0);  -- W32F16  -- Gain applied if above compression threshold
        band3_drc_bypass    :   IN    std_logic;                      -- bypassed when asserted (1)
        band3_delay         :   IN    std_logic_vector(11 DOWNTO 0);  -- uint12       -- delay in clock cycles that is running at Fs_clk rate 
       -- band4_gain          :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16  -- Gain of HA for 250 - 500 Bandpass filter
       -- band5_gain          :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16  -- Gain of HA for 125 - 250 Bandpass filter
        samples_in          :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En28  -- data in  at Fs=48Khz
        samples_out         :   OUT   std_logic_vector(31 DOWNTO 0)   -- sfix32_En28  -- data out at Fs=48Khz
    );
END HA128_DRC_system;


ARCHITECTURE rtl OF HA128_DRC_system IS

    component FIR128_DecimateBy2_abstracted IS
        PORT( 
            clk_Fs_x16      :   IN    std_logic;  -- system clock rate: Fs times 16 (due to folding)
            clk_Fs          :   IN    std_logic;  -- input  clock rate: Fs
            clk_Fs_d2       :   IN    std_logic;  -- output clock rate: Fs divided by 2
            reset           :   IN    std_logic;
            data_in         :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28  -- data in  at Fs   rate
            data_out        :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En28  -- data out at Fs/2 rate
        );
    END component;
	
    component FIR128_InterpolateBy2_abstracted IS
        PORT( 
            clk_Fs_x32      :   IN    std_logic;  -- system clock rate: Fs times 32 (due to folding)
            clk_Fs          :   IN    std_logic;  -- input  clock rate: Fs
            clk_Fs_x2       :   IN    std_logic;  -- output clock rate: Fs times 2
            reset           :   IN    std_logic;
            data_in         :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28  -- data in  at Fs   rate
            data_out        :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En28  -- data out at Fs*2 rate
        );
    END component;
	

    component HA_Bandpass128_abstracted IS
        PORT( 
            clk_Fs_x32      :   IN    std_logic;  -- system clock rate: Fs times 32 (due to folding)
            clk_Fs          :   IN    std_logic;  -- input/output clock rate: Fs
            reset           :   IN    std_logic;
            data_in         :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28  -- data in  at Fs rate
            data_out        :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En28  -- data out at Fs rate
        );
    END component;
            
    component Delay_Samples_4096 IS
        PORT( 
            Fs_clk              :   IN    std_logic;   -- sample rate clock
            reset               :   IN    std_logic; 
            Delay               :   IN    unsigned(11 DOWNTO 0);  
            samples_in          :   IN    std_logic_vector(31 DOWNTO 0);  
            samples_out         :   OUT   std_logic_vector(31 DOWNTO 0)   
        );
    END component;
    
    component HA_DRC IS
        PORT( 
            clk                 : in  std_logic;   -- system clock (must be greater than ~250*Fs_clk)
            Fs_clk              : in  std_logic;   -- sample rate clock
            reset               : in  std_logic; 
            threshold           : in  std_logic_vector(31 downto 0);  -- W32F16  -- compression threshold
            gain1               : in  std_logic_vector(31 downto 0);  -- W32F16  -- Gain1 applied if below compression threshold
            gain2               : in  std_logic_vector(31 downto 0);  -- W32F16  -- Gain2 applied if above compression threshold
            exponent            : in  std_logic_vector(31 downto 0);  -- W32F16  -- DRC exponent when above compression threshold
            bypass              : in  std_logic;                      -- (1=DRC is bypassed)
            samples_in          : in  std_logic_vector(31 DOWNTO 0);  
            samples_out         : out std_logic_vector(31 DOWNTO 0)   
        );
    END component;

	
    signal      clk_3072_counter :   unsigned(11 DOWNTO 0);
    signal      clk_768K         :   std_logic; 
    signal      clk_384K         :   std_logic; 
    signal      clk_192K         :   std_logic; 
    signal      clk_96K          :   std_logic; 
    signal      clk_48K          :   std_logic; 
    signal      clk_24K          :   std_logic; 
    signal      clk_12K          :   std_logic; 
    signal      clk_6K           :   std_logic; 
    signal      clk_3K           :   std_logic; 
    signal      clk_1500         :   std_logic; 
    signal      clk_750          :   std_logic; 
    
    
    -- decimator signals
	signal  decimator_48K_24k_data_out  : std_logic_vector(31 DOWNTO 0); -- sfix32_En28   
	signal  decimator_48K_24K_data_in   : std_logic_vector(31 DOWNTO 0); -- sfix32_En28
	signal  decimator_24K_12k_data_out  : std_logic_vector(31 DOWNTO 0); -- sfix32_En28   
	signal  decimator_24K_12K_data_in   : std_logic_vector(31 DOWNTO 0); -- sfix32_En28
	signal  decimator_12K_6k_data_out   : std_logic_vector(31 DOWNTO 0); -- sfix32_En28   
	signal  decimator_12K_6K_data_in    : std_logic_vector(31 DOWNTO 0); -- sfix32_En28   
	signal  decimator_6K_3k_data_out    : std_logic_vector(31 DOWNTO 0); -- sfix32_En28   
	signal  decimator_6K_3K_data_in     : std_logic_vector(31 DOWNTO 0); -- sfix32_En28
	signal  decimator_3K_1500_data_out  : std_logic_vector(31 DOWNTO 0); -- sfix32_En28   
	signal  decimator_3K_1500_data_in   : std_logic_vector(31 DOWNTO 0); -- sfix32_En28
	signal  decimator_1500_750_data_out : std_logic_vector(31 DOWNTO 0); -- sfix32_En28   
	signal  decimator_1500_750_data_in  : std_logic_vector(31 DOWNTO 0); -- sfix32_En28
    
    
	-- interpolator signals
	signal  interpolator_24K_48K_data_out  : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28    
	signal  interpolator_24K_48K_data_in   : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	 
	signal  interpolator_12K_24K_data_out  : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28    
	signal  interpolator_12K_24K_data_in   : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	 
	signal  interpolator_6K_12K_data_out   : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28    
	signal  interpolator_6K_12K_data_in    : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	 
	signal  interpolator_3K_6K_data_out    : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28    
	signal  interpolator_3K_6K_data_in     : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	 
	signal  interpolator_1500_3K_data_out  : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28    
	signal  interpolator_1500_3K_data_in   : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	 
	signal  interpolator_750_1500_data_out : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28    
	signal  interpolator_750_1500_data_in  : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	 

	-- FIR Bandpass signals
	signal  Bandpass_2K_4K_Fs12K_data_out    : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28   
	signal  Bandpass_2K_4K_Fs12K_data_in     : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	    
	signal  Bandpass_1K_2K_Fs6K_data_out     : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28   
	signal  Bandpass_1K_2K_Fs6K_data_in      : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	    
	signal  Bandpass_500_1K_Fs3K_data_out    : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28   
	signal  Bandpass_500_1K_Fs3K_data_in     : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	    
	signal  Bandpass_250_500_Fs1500_data_out : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28   
	signal  Bandpass_250_500_Fs1500_data_in  : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	    
	signal  Bandpass_125_250_Fs750_data_out  : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28   
	signal  Bandpass_125_250_Fs750_data_in   : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	    

	signal  Bandpass_2K_4K_Fs12K_gain    : signed(63 DOWNTO 0);  -- sfix64_En44   
	signal  Bandpass_1K_2K_Fs6K_gain     : signed(63 DOWNTO 0);  -- sfix64_En44   
	signal  Bandpass_500_1K_Fs3K_gain    : signed(63 DOWNTO 0);  -- sfix64_En44   
	signal  Bandpass_250_500_Fs1500_gain : signed(63 DOWNTO 0);  -- sfix64_En44   
	signal  Bandpass_125_250_Fs750_gain  : signed(63 DOWNTO 0);  -- sfix64_En44   
  
	signal  Bandpass_2K_4K_Fs12K_gain_delay    : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28   
	signal  Bandpass_1K_2K_Fs6K_gain_delay     : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28 
	signal  Bandpass_500_1K_Fs3K_gain_delay    : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28  
	signal  Bandpass_250_500_Fs1500_gain_delay : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28   

	-- DRC signals
	signal  DRC_2K_4K_Fs12K_data_out    : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28   
	signal  DRC_2K_4K_Fs12K_data_in     : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	    
	signal  DRC_1K_2K_Fs6K_data_out     : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28   
	signal  DRC_1K_2K_Fs6K_data_in      : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	    
	signal  DRC_500_1K_Fs3K_data_out    : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28   
	signal  DRC_500_1K_Fs3K_data_in     : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	    
  
  
BEGIN

   -------------------------------------------------------------
	-- clock divider
	-------------------------------------------------------------
	process(reset, clk_3072)
	begin
     if reset = '1' then
         clk_3072_counter <= (others => '0');
      elsif rising_edge(clk_3072) then
		   clk_3072_counter <= clk_3072_counter + 1;
		end if;
	end process;
	
	clk_768K <= clk_3072_counter(1);
	clk_384K <= clk_3072_counter(2);
	clk_192K <= clk_3072_counter(3);
	clk_96K  <= clk_3072_counter(4);
	clk_48K  <= clk_3072_counter(5);   -- divide by 64 = >  48 KHz = 3.072 MHz/64
	clk_24K  <= clk_3072_counter(6);   
	clk_12K  <= clk_3072_counter(7);  
	clk_6K   <= clk_3072_counter(8);  
	clk_3K   <= clk_3072_counter(9);  
	clk_1500 <= clk_3072_counter(10);  
	clk_750  <= clk_3072_counter(11);  

   -------------------------------------------------------------
	-- Decimators
	-------------------------------------------------------------

    decimator_48K_24K_data_in <= samples_in;

	decimator_48K_24K : FIR128_DecimateBy2_abstracted port map (
		clk_Fs_x16 =>  clk_768K,                   -- system clock rate: Fs times 16 (due to folding)
        clk_Fs     =>  clk_48K,                    -- input  clock rate: Fs
        clk_Fs_d2  =>  clk_24K,                    -- output clock rate: Fs divided by 2
		reset      =>  reset,
		data_in    =>  decimator_48K_24K_data_in,
		data_out   =>  decimator_48K_24K_data_out
	);

    
    decimator_24K_12K_data_in <= decimator_48K_24K_data_out;

	decimator_24K_12K : FIR128_DecimateBy2_abstracted port map (
		clk_Fs_x16 =>  clk_384K,                   -- system clock rate: Fs times 16 (due to folding)
        clk_Fs     =>  clk_24K,                    -- input  clock rate: Fs
        clk_Fs_d2  =>  clk_12K,                    -- output clock rate: Fs divided by 2
		reset      =>  reset,
		data_in    =>  decimator_24K_12K_data_in,
		data_out   =>  decimator_24K_12K_data_out
	);
   
    decimator_12K_6K_data_in <= decimator_24K_12K_data_out;

	decimator_12K_6K : FIR128_DecimateBy2_abstracted port map (
		clk_Fs_x16 =>  clk_192K,                   -- system clock rate: Fs times 16 (due to folding)
        clk_Fs     =>  clk_12K,                    -- input  clock rate: Fs
        clk_Fs_d2  =>  clk_6K,                     -- output clock rate: Fs divided by 2
		reset      =>  reset,
		data_in    =>  decimator_12K_6K_data_in,
		data_out   =>  decimator_12K_6K_data_out
	);
 	
    decimator_6K_3K_data_in <= decimator_12K_6K_data_out;

	decimator_6K_3K : FIR128_DecimateBy2_abstracted port map (
		clk_Fs_x16 =>  clk_96K,                    -- system clock rate: Fs times 16 (due to folding)
        clk_Fs     =>  clk_6K,                     -- input  clock rate: Fs
        clk_Fs_d2  =>  clk_3K,                     -- output clock rate: Fs divided by 2
		reset      =>  reset,
		data_in    =>  decimator_6K_3K_data_in,
		data_out   =>  decimator_6K_3K_data_out
	);
    
--    decimator_3K_1500_data_in <= decimator_6K_3K_data_out;
--
--	decimator_3K_1500 : FIR128_DecimateBy2_abstracted port map (
--		clk_Fs_x16 =>  clk_48K,                    -- system clock rate: Fs times 16 (due to folding)
--        clk_Fs     =>  clk_3K,                     -- input  clock rate: Fs
--        clk_Fs_d2  =>  clk_1500,                   -- output clock rate: Fs divided by 2
--		reset      =>  reset,
--		data_in    =>  decimator_3K_1500_data_in,
--		data_out   =>  decimator_3K_1500_data_out
--	);
--    
--    decimator_1500_750_data_in <= decimator_3K_1500_data_out;
--
--	decimator_1500_750 : FIR128_DecimateBy2_abstracted port map (
--		clk_Fs_x16 =>  clk_24K,                    -- system clock rate: Fs times 16 (due to folding)
--        clk_Fs     =>  clk_1500,                   -- input  clock rate: Fs
--        clk_Fs_d2  =>  clk_750,                    -- output clock rate: Fs divided by 2
--		reset      =>  reset,
--		data_in    =>  decimator_1500_750_data_in,
--		data_out   =>  decimator_1500_750_data_out
--	);
   
    -------------------------------------------------------------
	-- Bandpass Filters
	-------------------------------------------------------------
	
    Bandpass_2K_4K_Fs12K_data_in <= decimator_24K_12K_data_out;	
	Bandpass_2K_4K_Fs12K : HA_Bandpass128_abstracted port map (
		clk_Fs_x32  =>  clk_384K,                        -- system clock rate: Fs times 32 (due to folding)
		clk_Fs      =>  clk_12K,                         -- input/output clock rate: Fs
		reset       =>  reset,
		data_in     =>  Bandpass_2K_4K_Fs12K_data_in,    -- sfix32_En28  -- data in  at Fs rate
		data_out    =>  Bandpass_2K_4K_Fs12K_data_out    -- sfix32_En28  -- data out at Fs rate
	);
    Bandpass_2K_4K_Fs12K_gain <= signed(Bandpass_2K_4K_Fs12K_data_out) *  signed(band1_gain);

    Bandpass_1K_2K_Fs6K_data_in <= decimator_12K_6K_data_out;	
	Bandpass_1K_2K_Fs6K : HA_Bandpass128_abstracted port map (
		clk_Fs_x32  =>  clk_192K,                        -- system clock rate: Fs times 32 (due to folding)
		clk_Fs      =>  clk_6K,                          -- input/output clock rate: Fs
		reset       =>  reset,
		data_in     =>  Bandpass_1K_2K_Fs6K_data_in,     -- sfix32_En28  -- data in  at Fs rate
		data_out    =>  Bandpass_1K_2K_Fs6K_data_out     -- sfix32_En28  -- data out at Fs rate
	);
    Bandpass_1K_2K_Fs6K_gain <=  signed(Bandpass_1K_2K_Fs6K_data_out) *  signed(band2_gain);
  
    Bandpass_500_1K_Fs3K_data_in <= decimator_6K_3K_data_out;	
	Bandpass_500_1K_Fs3K : HA_Bandpass128_abstracted port map (
		clk_Fs_x32  =>  clk_96K,                         -- system clock rate: Fs times 32 (due to folding)
		clk_Fs      =>  clk_3K,                          -- input/output clock rate: Fs
		reset       =>  reset,
		data_in     =>  Bandpass_500_1K_Fs3K_data_in,    -- sfix32_En28  -- data in  at Fs rate
		data_out    =>  Bandpass_500_1K_Fs3K_data_out    -- sfix32_En28  -- data out at Fs rate
	);
    Bandpass_500_1K_Fs3K_gain <=  signed(Bandpass_500_1K_Fs3K_data_out) *  signed(band3_gain);

--    Bandpass_250_500_Fs1500_data_in <= decimator_3K_1500_data_out;	
--	Bandpass_250_500_Fs1500 : HA_Bandpass128_abstracted port map (
--		clk_Fs_x32  =>  clk_48K,                         -- system clock rate: Fs times 32 (due to folding)
--		clk_Fs      =>  clk_1500,                        -- input/output clock rate: Fs
--		reset       =>  reset,
--		data_in     =>  Bandpass_250_500_Fs1500_data_in, -- sfix32_En28  -- data in  at Fs rate
--		data_out    =>  Bandpass_250_500_Fs1500_data_out -- sfix32_En28  -- data out at Fs rate
--	);
--    Bandpass_250_500_Fs1500_gain <=  signed(Bandpass_250_500_Fs1500_data_out) *  signed(band4_gain);

--  Bandpass_125_250_Fs750_data_in <= decimator_1500_750_data_out;	
--	Bandpass_125_250_Fs750 : HA_Bandpass128_abstracted port map (
--		clk_Fs_x32  =>  clk_24K,                         -- system clock rate: Fs times 32 (due to folding)
--		clk_Fs      =>  clk_750,                         -- input/output clock rate: Fs
--		reset       =>  reset,
--		data_in     =>  Bandpass_125_250_Fs750_data_in,  -- sfix32_En28  -- data in  at Fs rate
--		data_out    =>  Bandpass_125_250_Fs750_data_out  -- sfix32_En28  -- data out at Fs rate
--	);
--  Bandpass_125_250_Fs750_gain <=  signed(Bandpass_125_250_Fs750_data_out) *  signed(band5_gain);
--   Bandpass_125_250_Fs750_gain <=  signed(decimator_1500_750_data_out) *  signed(band5_gain);
  
    -------------------------------------------------------------
	-- DRC blocks
	-------------------------------------------------------------
    DRC_2K_4K_Fs12K_data_in <= std_logic_vector(Bandpass_2K_4K_Fs12K_gain(47 downto 16));
    drc1 : HA_DRC port map (
        clk                  =>   clk,       -- system clock (must be greater than ~250*Fs_clk)
        Fs_clk               =>   clk_12K,   -- sample rate clock
        reset                =>   reset,
        threshold            =>   band1_drc_threshold, -- W32F16  -- compression threshold
        gain1                =>   band1_drc_gain1,     -- W32F16  -- Gain1 applied if below compression threshold
        gain2                =>   band1_drc_gain2,     -- W32F16  -- Gain2 applied if above compression threshold
        exponent             =>   band1_drc_exponent,  -- W32F16  -- DRC exponent when above compression threshold
        bypass               =>   band1_drc_bypass,    -- (1=DRC is bypassed)
        samples_in           =>   DRC_2K_4K_Fs12K_data_in,  
        samples_out          =>   DRC_2K_4K_Fs12K_data_out   
    );

    DRC_1K_2K_Fs6K_data_in <= std_logic_vector(Bandpass_1K_2K_Fs6K_gain(47 downto 16));
    drc2 : HA_DRC port map (
        clk                  =>   clk,       -- system clock (must be greater than ~250*Fs_clk)
        Fs_clk               =>   clk_6K,   -- sample rate clock
        reset                =>   reset,
        threshold            =>   band2_drc_threshold, -- W32F16  -- compression threshold
        gain1                =>   band2_drc_gain1,     -- W32F16  -- Gain1 applied if below compression threshold
        gain2                =>   band2_drc_gain2,     -- W32F16  -- Gain2 applied if above compression threshold
        exponent             =>   band2_drc_exponent,  -- W32F16  -- DRC exponent when above compression threshold
        bypass               =>   band2_drc_bypass,    -- (1=DRC is bypassed)
        samples_in           =>   DRC_1K_2K_Fs6K_data_in,  
        samples_out          =>   DRC_1K_2K_Fs6K_data_out   
    );

    DRC_500_1K_Fs3K_data_in <= std_logic_vector(Bandpass_500_1K_Fs3K_gain(47 downto 16));
    drc3 : HA_DRC port map (
        clk                  =>   clk,       -- system clock (must be greater than ~250*Fs_clk)
        Fs_clk               =>   clk_3K,   -- sample rate clock
        reset                =>   reset,
        threshold            =>   band3_drc_threshold, -- W32F16  -- compression threshold
        gain1                =>   band3_drc_gain1,     -- W32F16  -- Gain1 applied if below compression threshold
        gain2                =>   band3_drc_gain2,     -- W32F16  -- Gain2 applied if above compression threshold
        exponent             =>   band3_drc_exponent,  -- W32F16  -- DRC exponent when above compression threshold
        bypass               =>   band3_drc_bypass,    -- (1=DRC is bypassed)
        samples_in           =>   DRC_500_1K_Fs3K_data_in,  
        samples_out          =>   DRC_500_1K_Fs3K_data_out   
    );

    -------------------------------------------------------------
	-- Delays (to match the delay of Band 5)
	-------------------------------------------------------------
 
    band1_delay_block : Delay_Samples_4096 port map ( 
        Fs_clk              =>  clk_12K,
        reset               =>  reset,
        Delay               =>  unsigned(band1_delay), -- "101101000000",  --2880
        samples_in          =>  DRC_2K_4K_Fs12K_data_out, 
        samples_out         =>  Bandpass_2K_4K_Fs12K_gain_delay
    );
  
    band2_delay_block : Delay_Samples_4096 port map ( 
        Fs_clk              =>  clk_6K,
        reset               =>  reset,
        Delay               =>  unsigned(band2_delay), --"010101000000",  --1344
        --samples_in          =>  std_logic_vector(Bandpass_1K_2K_Fs6K_gain(47 downto 16)), 
        samples_in          =>  DRC_1K_2K_Fs6K_data_out, 
        samples_out         =>  Bandpass_1K_2K_Fs6K_gain_delay
    );

    band3_delay_block : Delay_Samples_4096 port map ( 
        Fs_clk              =>  clk_3K,
        reset               =>  reset,
        Delay               =>  unsigned(band3_delay), --"001001000000",  --576
        --samples_in          =>  std_logic_vector(Bandpass_500_1K_Fs3K_gain(47 downto 16)), 
        samples_in          =>  DRC_500_1K_Fs3K_data_out, 
        samples_out         =>  Bandpass_500_1K_Fs3K_gain_delay
    );
    
--    band4_delay_block : Delay_Samples_4096 port map ( 
--        Fs_clk              =>  clk_1500,
--        reset               =>  reset,
--        Delay               =>  "000011000000",  --192
--        samples_in          =>  std_logic_vector(Bandpass_250_500_Fs1500_gain(47 downto 16)), 
--        samples_out         =>  Bandpass_250_500_Fs1500_gain_delay
--    );
--    
    -------------------------------------------------------------
	-- Interpolators
	-------------------------------------------------------------
--    interpolator_750_1500_data_in <= std_logic_vector(Bandpass_125_250_Fs750_gain(47 downto 16));
--
--	interpolator_750_1500 : FIR128_InterpolateBy2_abstracted port map (
--		clk_Fs_x32 =>  clk_24K,                       -- system clock rate: Fs times 32 (due to folding)
--		clk_Fs     =>  clk_750,                       -- input  clock rate: Fs
--		clk_Fs_x2  =>  clk_1500,                      -- output clock rate: Fs times 2
--		reset      =>  reset,
--		data_in    =>  interpolator_750_1500_data_in,
--		data_out   =>  interpolator_750_1500_data_out 
--	);
    
    --interpolator_1500_3K_data_in <= std_logic_vector(signed(interpolator_750_1500_data_out) + Bandpass_250_500_Fs1500_gain(47 downto 16));
    --interpolator_1500_3K_data_in <= std_logic_vector(signed(interpolator_750_1500_data_out) + signed(Bandpass_250_500_Fs1500_gain_delay));
--    interpolator_1500_3K_data_in <= Bandpass_250_500_Fs1500_gain_delay;
--
--	interpolator_1500_3K : FIR128_InterpolateBy2_abstracted port map (
--		clk_Fs_x32 =>  clk_48K,                      -- system clock rate: Fs times 32 (due to folding)
--		clk_Fs     =>  clk_1500,                     -- input  clock rate: Fs
--		clk_Fs_x2  =>  clk_3K,                       -- output clock rate: Fs times 2
--		reset      =>  reset,
--		data_in    =>  interpolator_1500_3K_data_in,
--		data_out   =>  interpolator_1500_3K_data_out 
--	);
    
    --interpolator_3K_6K_data_in <= std_logic_vector(signed(interpolator_1500_3K_data_out) + Bandpass_500_1K_Fs3K_gain(47 downto 16));
    --interpolator_3K_6K_data_in <= std_logic_vector(signed(interpolator_1500_3K_data_out) + signed(Bandpass_500_1K_Fs3K_gain_delay));
    interpolator_3K_6K_data_in <= Bandpass_500_1K_Fs3K_gain_delay;

	interpolator_3K_6K : FIR128_InterpolateBy2_abstracted port map (
		clk_Fs_x32 =>  clk_96K,                      -- system clock rate: Fs times 32 (due to folding)
		clk_Fs     =>  clk_3K,                       -- input  clock rate: Fs
		clk_Fs_x2  =>  clk_6K,                       -- output clock rate: Fs times 2
		reset      =>  reset,
		data_in    =>  interpolator_3K_6K_data_in,
		data_out   =>  interpolator_3K_6K_data_out 
	);

    --interpolator_6K_12K_data_in <= std_logic_vector(signed(interpolator_3K_6K_data_out) + Bandpass_1K_2K_Fs6K_gain(47 downto 16));
    interpolator_6K_12K_data_in <= std_logic_vector(signed(interpolator_3K_6K_data_out) + signed(Bandpass_1K_2K_Fs6K_gain_delay));

	interpolator_6K_12K : FIR128_InterpolateBy2_abstracted port map (
		clk_Fs_x32 =>  clk_192K,                      -- system clock rate: Fs times 32 (due to folding)
		clk_Fs     =>  clk_6K,                        -- input  clock rate: Fs
		clk_Fs_x2  =>  clk_12K,                       -- output clock rate: Fs times 2
		reset      =>  reset,
		data_in    =>  interpolator_6K_12K_data_in,
		data_out   =>  interpolator_6K_12K_data_out 
	);
	
    --interpolator_12K_24K_data_in <= std_logic_vector(signed(interpolator_6K_12K_data_out) + Bandpass_2K_4K_Fs12K_gain(47 downto 16));
    interpolator_12K_24K_data_in <= std_logic_vector(signed(interpolator_6K_12K_data_out) + signed(Bandpass_2K_4K_Fs12K_gain_delay));

	interpolator_12K_24K : FIR128_InterpolateBy2_abstracted port map (
		clk_Fs_x32 =>  clk_384K,                      -- system clock rate: Fs times 32 (due to folding)
		clk_Fs     =>  clk_12K,                       -- input  clock rate: Fs
		clk_Fs_x2  =>  clk_24K,                       -- output clock rate: Fs times 2
		reset      =>  reset,
		data_in    =>  interpolator_12K_24K_data_in,
		data_out   =>  interpolator_12K_24K_data_out 
	);
	
    interpolator_24K_48K_data_in <= interpolator_12K_24K_data_out;

	interpolator_24K_48K : FIR128_InterpolateBy2_abstracted port map (
		clk_Fs_x32 =>  clk_768K,                      -- system clock rate: Fs times 32 (due to folding)
		clk_Fs     =>  clk_24K,                       -- input  clock rate: Fs
		clk_Fs_x2  =>  clk_48K,                       -- output clock rate: Fs times 2
		reset      =>  reset,
		data_in    =>  interpolator_24K_48K_data_in,
		data_out   =>  interpolator_24K_48K_data_out 
	);
	
	samples_out <= interpolator_24K_48K_data_out;

    
    

END rtl;