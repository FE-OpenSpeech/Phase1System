LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY Delay_Samples IS
    PORT( 
        Fs_clk              :   IN    std_logic;   -- sample rate clock
        reset               :   IN    std_logic; 
        Delay               :   IN    unsigned(9 DOWNTO 0);  
        samples_in          :   IN    std_logic_vector(31 DOWNTO 0);  
        samples_out         :   OUT   std_logic_vector(31 DOWNTO 0)   
    );
END Delay_Samples;


ARCHITECTURE rtl OF Delay_Samples IS

 
    component Delay_DualPort_1024x32
        PORT
        (
            clock		: IN STD_LOGIC  := '1';
            data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            rdaddress   : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            wraddress	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            wren		: IN STD_LOGIC  := '0';
            q		    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    end component;

    signal write_counter : unsigned(9 DOWNTO 0);
    signal write_ptr     : unsigned(9 DOWNTO 0);
    signal read_ptr      : unsigned(9 DOWNTO 0);

begin


    process(Delay)
    begin
        if Delay = "0000000000" then    -- bypass when no delay
            samples_out <= samples_in;
        else
            samples_out <= data_out
    end process;
    
    process (Fs_clk)
	begin
		if reset = '1' then
			write_counter <= (others => '0');
		elsif rising_edge(Fs_clk) then
			write_counter <= write_counter + 1;
		end if;
	end process;
    
    read_ptr <= write_ptr - (Delay-1);  -- there is already one clock delay through dual port memory

    Delay_memory : Delay_DualPort_1024x32 PORT MAP (
        clock	    => Fs_clk,
        data	    => samples_in,
        rdaddress   => read_ptr,
        wraddress   => write_ptr,
        wren	    => '1',
        q	        => data_out
    );
    


end rtl;

