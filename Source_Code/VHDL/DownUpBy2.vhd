LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY DownUpBy2 IS
   PORT( clk_3072                        :   IN    std_logic;   -- clock at 3.072 MHz = 48 KHz * 64, which is the bit clock rate at 48 KHz coming from the AD1939
         reset                           :   IN    std_logic; 
         samples_in                      :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28  -- data in  at Fs=48Khz
         samples_out                     :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En28  -- data out at Fs=48Khz
         );
END DownUpBy2;


ARCHITECTURE rtl OF DownUpBy2 IS

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
	

	signal      clk_3072_counter :   unsigned(10 DOWNTO 0);
    signal      clk_768K         :   std_logic; 
    signal      clk_384K         :   std_logic; 
    signal      clk_192K         :   std_logic; 
    signal      clk_96K          :   std_logic; 
    signal      clk_48K          :   std_logic; 
    signal      clk_24K          :   std_logic; 
	 
	-- decimator signals
	signal  decimator_48K_24k_data_out : std_logic_vector(31 DOWNTO 0); -- sfix32_En28   
	signal  decimator_48K_24K_data_in  : std_logic_vector(31 DOWNTO 0); -- sfix32_En28
	 
	-- interpolator signals
	signal  interpolator_24K_48K_data_out : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28    
	signal  interpolator_24K_48K_data_in  : std_logic_vector(31 DOWNTO 0);  -- sfix32_En28	 
	 
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
	clk_24K  <= clk_3072_counter(6);   -- divide by 128 =>  24 KHz = 3.072 MHz/128
	

    -------------------------------------------------------------
	-- Decimator
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

    -------------------------------------------------------------
	-- Interpolator
	-------------------------------------------------------------
	
    interpolator_24K_48K_data_in <= decimator_48K_24K_data_out;
   
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