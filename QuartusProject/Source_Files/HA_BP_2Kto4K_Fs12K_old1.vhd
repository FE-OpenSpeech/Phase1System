LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY HA_BP_2Kto4K_Fs12K IS
   PORT( clk_3072                        :   IN    std_logic;   -- clock at 3.072 MHz = 48 KHz * 64, which is the bit clock rate at 48 KHz coming from the AD1939
         reset                           :   IN    std_logic; 
         samples_in                      :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28
         valid_in                        :   IN    std_logic;  -- valid in a Fs rate = 48 KHz
         samples_out                     :   OUT   std_logic_vector(31 DOWNTO 0); -- sfix32_En28
         ce_out                          :   OUT   std_logic  
         );
END HA_BP_2Kto4K_Fs12K;


ARCHITECTURE rtl OF HA_BP_2Kto4K_Fs12K IS

	component FIR_DecimatorBy2 IS
		PORT( clk                             :   IN    std_logic; 
				reset                           :   IN    std_logic; 
				clk_enable                      :   IN    std_logic; 
				filter_in                       :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28
				filter_out                      :   OUT   std_logic_vector(68 DOWNTO 0); -- sfix69_En60
				ce_out                          :   OUT   std_logic  
				);
	END component;
	
	component FIR_InterpolatorBy2 IS
		PORT( clk                             :   IN    std_logic; 
				reset                           :   IN    std_logic; 
				clk_enable                      :   IN    std_logic; 
				filter_in                       :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28
				filter_out                      :   OUT   std_logic_vector(68 DOWNTO 0); -- sfix69_En60
				ce_out                          :   OUT   std_logic  
				);
	END component;
	
	component FIR_Bandpass_2K_4K_Fs12K IS
		PORT( clk                             :   IN    std_logic; 
				reset                           :   IN    std_logic; 
				clk_enable                      :   IN    std_logic; 
				filter_in                       :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28
				filter_out                      :   OUT   std_logic_vector(70 DOWNTO 0)  -- sfix71_En60
				);
	END component;

	 signal      clk_3072_counter :   unsigned(10 DOWNTO 0);
    signal      clk_768K         :   std_logic; 
    signal      clk_384K         :   std_logic; 
    signal      clk_192K         :   std_logic; 
    signal      clk_96K          :   std_logic; 
    signal      clk_48K          :   std_logic; 
    signal      clk_24K          :   std_logic; 
    signal      clk_enable       :   std_logic; 
	 
	 -- decimator signals
	 signal  decimator_48K_24k_data_out : std_logic_vector(68 DOWNTO 0); -- sfix69_En60
	 signal  decimator_24K_12k_data_out : std_logic_vector(68 DOWNTO 0); -- sfix69_En60
    
	 signal  decimator_48K_24K_data_in  : std_logic_vector(31 DOWNTO 0); -- sfix32_En28
	 signal  decimator_24K_12K_data_in  : std_logic_vector(31 DOWNTO 0); -- sfix32_En28
	 
	 signal  decimator_48K_24K_ce_out   :   std_logic; 
	 signal  decimator_24K_12K_ce_out   :   std_logic; 
	 
	 -- interpolator signals
	 signal  interpolator_24K_48K_data_out : std_logic_vector(68 DOWNTO 0); -- sfix69_En60
	 signal  interpolator_12K_24K_data_out : std_logic_vector(68 DOWNTO 0); -- sfix69_En60
    
	 signal  interpolator_24K_48K_data_in  : std_logic_vector(31 DOWNTO 0); -- sfix32_En28
	 signal  interpolator_12K_24K_data_in  : std_logic_vector(31 DOWNTO 0); -- sfix32_En28
	 
	 signal  interpolator_24K_48K_ce_out   :   std_logic; 
	 signal  interpolator_12K_24K_ce_out   :   std_logic; 
	 
	 -- bandpass filter signals
	 signal  bandpass_2K_4K_data_in        : std_logic_vector(31 DOWNTO 0); -- sfix32_En28
	 signal  bandpass_2K_4K_data_out       : std_logic_vector(70 DOWNTO 0); -- sfix71_En60
	 
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
	
    clk_enable <= not reset;

    process(clk_3072)
    begin
       if rising_edge(clk_3072) and valid_in = '1' then 
           decimator_48K_24K_data_in <= samples_in;
       end if;
    end process;

   -------------------------------------------------------------
	-- Decimators
	-------------------------------------------------------------
	decimator_48K_24K : FIR_DecimatorBy2 port map (
		clk        =>  clk_384K,           -- clock needs to be 8x sample rate => 48K * 8 = 384K
		reset      =>  reset,
		clk_enable =>  clk_enable,
		filter_in  =>  decimator_48K_24K_data_in,
		filter_out =>  decimator_48K_24K_data_out,
		ce_out     =>  decimator_48K_24K_ce_out
	);

	decimator_24K_12K_data_in <= decimator_48K_24k_data_out(62 downto 31);
	
	decimator_24K_12K : FIR_DecimatorBy2 port map (
		clk        =>  clk_192K,           -- clock needs to be 8x sample rate => 24K * 8 = 192K
		reset      =>  reset,
		clk_enable =>  clk_enable,
		filter_in  =>  decimator_24K_12K_data_in,
		filter_out =>  decimator_24K_12K_data_out,
		ce_out     =>  decimator_24K_12K_ce_out
	);

   bandpass_2K_4K_data_in <= decimator_24K_12k_data_out(62 downto 31);
	
	-------------------------------------------------------------
	-- Bandpass Filter
	-------------------------------------------------------------

	Bandpass_2K_4K : FIR_Bandpass_2K_4K_Fs12K port map (
		clk        =>  clk_192K,           -- clock needs to be 16x sample rate => 12K * 16 = 192K
		reset      =>  reset,
		clk_enable =>  clk_enable,
		filter_in  =>  bandpass_2K_4K_data_in,
		filter_out =>  bandpass_2K_4K_data_out
	);
	
	-- interpolator_12K_24K_data_in <= bandpass_2K_4K_data_out(63 downto 32);
	interpolator_12K_24K_data_in <= decimator_24K_12k_data_out(62 downto 31);

	
   -------------------------------------------------------------
	-- Interpolators
	-------------------------------------------------------------
	interpolator_12K_24K : FIR_InterpolatorBy2 port map (
		clk        =>  clk_384K,           -- clock needs to be 32x sample rate => 12K * 32 = 384K
		reset      =>  reset,
		clk_enable =>  clk_enable,
		filter_in  =>  interpolator_12K_24K_data_in,
		filter_out =>  interpolator_12K_24K_data_out,
		ce_out     =>  interpolator_12K_24K_ce_out
	);
	
  -- interpolator_24K_48K_data_in <= interpolator_12K_24K_data_out(63 downto 32);
  interpolator_24K_48K_data_in <= decimator_48K_24k_data_out(62 downto 31);

	interpolator_24K_48K : FIR_InterpolatorBy2 port map (
		clk        =>  clk_768K,           -- clock needs to be 32x sample rate => 24K * 32 = 768K
		reset      =>  reset,
		clk_enable =>  clk_enable,
		filter_in  =>  interpolator_24K_48K_data_in,
		filter_out =>  interpolator_24K_48K_data_out,
		ce_out     =>  interpolator_24K_48K_ce_out
	);
	
	
	samples_out <= interpolator_24K_48K_data_out(63 downto 32);
   ce_out      <= interpolator_24K_48K_ce_out;


END rtl;