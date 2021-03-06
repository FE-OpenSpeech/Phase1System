LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY HA_Bandpass64_abstracted IS
    PORT( 
        clk_Fs_x16      :   IN    std_logic;  -- system clock rate: Fs times 32 (due to folding)
        clk_Fs          :   IN    std_logic;  -- input/output clock rate: Fs
        reset           :   IN    std_logic;
        data_in         :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28  -- data in  at Fs rate
        data_out        :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En28  -- data out at Fs rate
    );
END HA_Bandpass64_abstracted;


ARCHITECTURE rtl OF HA_Bandpass64_abstracted IS


    component HA_Bandpass64 IS
       PORT( clk                             :   IN    std_logic;   -- 32x Fs
             clk_enable                      :   IN    std_logic; 
             reset                           :   IN    std_logic; 
             filter_in                       :   IN    std_logic_vector(31 DOWNTO 0); -- sfix32_En28
             filter_out                      :   OUT   std_logic_vector(70 DOWNTO 0)  -- sfix71_En60
             );
    END component;
    --### Clock rate is 16 times the input sample rate for this architecture.
    --### Successful completion of VHDL code generation process for filter: HA_Bandpass64
    --### HDL latency is 3 samples
    -- Code auto generated by Matlab:   filter_length = 64; 
    --                                  Fs = 12000;
    --                                  w1 = 2000/(Fs/2);
    --                                  w2 = 4000/(Fs/2);
    --                                  bandpass = dsp.FIRFilter('Numerator',fir1(filter_length,[w1 w2]));
    --                                  fdhdltool(bandpass,numerictype(1,32,28))

 	-- decimator signals
	signal  bandpass_data_in     : std_logic_vector(31 DOWNTO 0); -- sfix32_En28
	signal  bandpass_data_out    : std_logic_vector(70 DOWNTO 0); -- sfix71_En60  
	 
BEGIN

    -------------------------------------------------------------------
    -- Capture data in on Fs clock
    -------------------------------------------------------------------
    process(clk_Fs)
    begin
        if rising_edge(clk_Fs) then
            bandpass_data_in <= data_in;
            data_out         <= bandpass_data_out(63 downto 32);  -- convert back to -- sfix32_En28
         end if;
    end process;
    
    -------------------------------------------------------------------
    -- Send through bandpass filter
    -------------------------------------------------------------------
	bandpass : HA_Bandpass64 port map (
		clk         =>  clk_Fs_x16,                       
		clk_enable  =>  '1',
		reset       =>  reset,
		filter_in   =>  bandpass_data_in,      
		filter_out  =>  bandpass_data_out
	);
     
 END rtl;