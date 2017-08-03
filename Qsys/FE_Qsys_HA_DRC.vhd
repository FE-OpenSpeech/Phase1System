----------------------------------------------------------------------------------
-- Company:          Flat Earth Inc
-- Author/Engineer:	 Ross Snider
-- 
-- Create Date:    6/28/2017 
-- Design Name: 
-- Module Name:    Hearing Aide Qsys Block with DRC that exports control to top level 
-- Project Name: 
-- Target Devices: DE10
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



entity FE_Qsys_HA_DRC is
	port (
		clk 			    	: in std_logic;   
		reset_n 		    	: in std_logic;
        ------------------------------------------------------------
        -- Avalon Memory Mapped Slave Signals
        ------------------------------------------------------------
        avs_s1_address 	        : in  std_logic_vector( 5 downto 0);   --! Avalon MM Slave address
        avs_s1_write 		    : in  std_logic;                       --! Avalon MM Slave write
        avs_s1_writedata 	    : in  std_logic_vector(31 downto 0);   --! Avalon MM Slave write data
        avs_s1_read 		    : in  std_logic;                       --! Avalon MM Slave read
        avs_s1_readdata 	    : out std_logic_vector(31 downto 0);   --! Avalon MM Slave read data
        ------------------------------------------------------------
        -- Exported control words
        ------------------------------------------------------------       
        band1_gain              : out std_logic_vector(31 downto 0);
        band1_delay             : out std_logic_vector(31 downto 0);
        band1_drc_threshold     : out std_logic_vector(31 downto 0);
        band1_drc_gain1         : out std_logic_vector(31 downto 0);
        band1_drc_gain2         : out std_logic_vector(31 downto 0);
        band1_drc_exponent      : out std_logic_vector(31 downto 0);
        band1_drc_bypass        : out std_logic;
        band2_gain              : out std_logic_vector(31 downto 0);
        band2_delay             : out std_logic_vector(31 downto 0);
        band2_drc_threshold     : out std_logic_vector(31 downto 0);
        band2_drc_gain1         : out std_logic_vector(31 downto 0);
        band2_drc_gain2         : out std_logic_vector(31 downto 0);
        band2_drc_exponent      : out std_logic_vector(31 downto 0);
        band2_drc_bypass        : out std_logic;
        band3_gain              : out std_logic_vector(31 downto 0);
        band3_delay             : out std_logic_vector(31 downto 0);
        band3_drc_threshold     : out std_logic_vector(31 downto 0);
        band3_drc_gain1         : out std_logic_vector(31 downto 0);
        band3_drc_gain2         : out std_logic_vector(31 downto 0);
        band3_drc_exponent      : out std_logic_vector(31 downto 0);
        band3_drc_bypass        : out std_logic;
        band4_gain              : out std_logic_vector(31 downto 0);
        band4_delay             : out std_logic_vector(31 downto 0);
        band4_drc_threshold     : out std_logic_vector(31 downto 0);
        band4_drc_gain1         : out std_logic_vector(31 downto 0);
        band4_drc_gain2         : out std_logic_vector(31 downto 0);
        band4_drc_exponent      : out std_logic_vector(31 downto 0);
        band4_drc_bypass        : out std_logic;
        band5_gain              : out std_logic_vector(31 downto 0);
        band5_delay             : out std_logic_vector(31 downto 0);
        band5_drc_threshold     : out std_logic_vector(31 downto 0);
        band5_drc_gain1         : out std_logic_vector(31 downto 0);
        band5_drc_gain2         : out std_logic_vector(31 downto 0);
        band5_drc_exponent      : out std_logic_vector(31 downto 0);
        band5_drc_bypass        : out std_logic
	);
end FE_Qsys_HA_DRC;

architecture behavior of FE_Qsys_HA_DRC is

    signal band1_gain_int              : std_logic_vector(31 downto 0);
    signal band1_delay_int             : std_logic_vector(31 downto 0);
    signal band1_drc_threshold_int     : std_logic_vector(31 downto 0);
    signal band1_drc_gain1_int         : std_logic_vector(31 downto 0);
    signal band1_drc_gain2_int         : std_logic_vector(31 downto 0);
    signal band1_drc_exponent_int      : std_logic_vector(31 downto 0);
    signal band1_drc_bypass_int        : std_logic_vector(31 downto 0);
    signal band2_gain_int              : std_logic_vector(31 downto 0);
    signal band2_delay_int             : std_logic_vector(31 downto 0);
    signal band2_drc_threshold_int     : std_logic_vector(31 downto 0);
    signal band2_drc_gain1_int         : std_logic_vector(31 downto 0);
    signal band2_drc_gain2_int         : std_logic_vector(31 downto 0);
    signal band2_drc_exponent_int      : std_logic_vector(31 downto 0);
    signal band2_drc_bypass_int        : std_logic_vector(31 downto 0);
    signal band3_gain_int              : std_logic_vector(31 downto 0);
    signal band3_delay_int             : std_logic_vector(31 downto 0);
    signal band3_drc_threshold_int     : std_logic_vector(31 downto 0);
    signal band3_drc_gain1_int         : std_logic_vector(31 downto 0);
    signal band3_drc_gain2_int         : std_logic_vector(31 downto 0);
    signal band3_drc_exponent_int      : std_logic_vector(31 downto 0);
    signal band3_drc_bypass_int        : std_logic_vector(31 downto 0);
    signal band4_gain_int              : std_logic_vector(31 downto 0);
    signal band4_delay_int             : std_logic_vector(31 downto 0);
    signal band4_drc_threshold_int     : std_logic_vector(31 downto 0);
    signal band4_drc_gain1_int         : std_logic_vector(31 downto 0);
    signal band4_drc_gain2_int         : std_logic_vector(31 downto 0);
    signal band4_drc_exponent_int      : std_logic_vector(31 downto 0);
    signal band4_drc_bypass_int        : std_logic_vector(31 downto 0);
    signal band5_gain_int              : std_logic_vector(31 downto 0);
    signal band5_delay_int             : std_logic_vector(31 downto 0);
    signal band5_drc_threshold_int     : std_logic_vector(31 downto 0);
    signal band5_drc_gain1_int         : std_logic_vector(31 downto 0);
    signal band5_drc_gain2_int         : std_logic_vector(31 downto 0);
    signal band5_drc_exponent_int      : std_logic_vector(31 downto 0);
    signal band5_drc_bypass_int        : std_logic_vector(31 downto 0);


begin

    ------------------------------------------------------------------------
    -- Read from Registers
    ------------------------------------------------------------------------ 
    process(clk)
	begin
		if rising_edge(clk) and (avs_s1_read = '1') then  -- all registers can be read. 
			case avs_s1_address is
                when "000000"  => avs_s1_readdata <= band1_gain_int;         
                when "000001"  => avs_s1_readdata <= band1_delay_int;        
                when "000010"  => avs_s1_readdata <= band1_drc_threshold_int;
                when "000011"  => avs_s1_readdata <= band1_drc_gain1_int;    
                when "000100"  => avs_s1_readdata <= band1_drc_gain2_int;    
                when "000101"  => avs_s1_readdata <= band1_drc_exponent_int; 
                when "000110"  => avs_s1_readdata <= band1_drc_bypass_int;   
                when "000111"  => avs_s1_readdata <= (others => '0'); -- not a register
                when "001000"  => avs_s1_readdata <= band2_gain_int;         
                when "001001"  => avs_s1_readdata <= band2_delay_int;        
                when "001010"  => avs_s1_readdata <= band2_drc_threshold_int;
                when "001011"  => avs_s1_readdata <= band2_drc_gain1_int;    
                when "001100"  => avs_s1_readdata <= band2_drc_gain2_int;    
                when "001101"  => avs_s1_readdata <= band2_drc_exponent_int; 
                when "001110"  => avs_s1_readdata <= band2_drc_bypass_int;   
                when "001111"  => avs_s1_readdata <= (others => '0'); -- not a register
                when "010000"  => avs_s1_readdata <= band3_gain_int;         
                when "010001"  => avs_s1_readdata <= band3_delay_int;        
                when "010010"  => avs_s1_readdata <= band3_drc_threshold_int;
                when "010011"  => avs_s1_readdata <= band3_drc_gain1_int;    
                when "010100"  => avs_s1_readdata <= band3_drc_gain2_int;    
                when "010101"  => avs_s1_readdata <= band3_drc_exponent_int; 
                when "010110"  => avs_s1_readdata <= band3_drc_bypass_int;                   
                when "010111"  => avs_s1_readdata <= (others => '0'); -- not a register
                when "011000"  => avs_s1_readdata <= band4_gain_int;         
                when "011001"  => avs_s1_readdata <= band4_delay_int;        
                when "011010"  => avs_s1_readdata <= band4_drc_threshold_int;
                when "011011"  => avs_s1_readdata <= band4_drc_gain1_int;    
                when "011100"  => avs_s1_readdata <= band4_drc_gain2_int;    
                when "011101"  => avs_s1_readdata <= band4_drc_exponent_int; 
                when "011110"  => avs_s1_readdata <= band4_drc_bypass_int;                   
                when "011111"  => avs_s1_readdata <= (others => '0'); -- not a register
                when "100000"  => avs_s1_readdata <= band5_gain_int;         
                when "100001"  => avs_s1_readdata <= band5_delay_int;        
                when "100010"  => avs_s1_readdata <= band5_drc_threshold_int;
                when "100011"  => avs_s1_readdata <= band5_drc_gain1_int;    
                when "100100"  => avs_s1_readdata <= band5_drc_gain2_int;    
                when "100101"  => avs_s1_readdata <= band5_drc_exponent_int; 
                when "100110"  => avs_s1_readdata <= band5_drc_bypass_int;                   
                when "100111"  => avs_s1_readdata <= (others => '0'); -- not a register
				when others    => avs_s1_readdata <= (others => '0');
            end case;
		end if;
	end process;

    
    
    ------------------------------------------------------------------------
    -- Write to Registers
    ------------------------------------------------------------------------ 
    process(clk)
	begin
        if (reset_n = '0') then
            -- put default reset values here....
		elsif rising_edge(clk) and (avs_s1_write = '1') then  -- write the registers
            case avs_s1_address is
                when "000000"  => band1_gain_int          <= avs_s1_writedata;            
                when "000001"  => band1_delay_int         <= avs_s1_writedata;            
                when "000010"  => band1_drc_threshold_int <= avs_s1_writedata;            
                when "000011"  => band1_drc_gain1_int     <= avs_s1_writedata;            
                when "000100"  => band1_drc_gain2_int     <= avs_s1_writedata;            
                when "000101"  => band1_drc_exponent_int  <= avs_s1_writedata;            
                when "000110"  => band1_drc_bypass_int    <= avs_s1_writedata;            
                when "000111"  => null; -- not a register   
                when "001000"  => band2_gain_int          <= avs_s1_writedata;            
                when "001001"  => band2_delay_int         <= avs_s1_writedata;            
                when "001010"  => band2_drc_threshold_int <= avs_s1_writedata;            
                when "001011"  => band2_drc_gain1_int     <= avs_s1_writedata;            
                when "001100"  => band2_drc_gain2_int     <= avs_s1_writedata;            
                when "001101"  => band2_drc_exponent_int  <= avs_s1_writedata;            
                when "001110"  => band2_drc_bypass_int    <= avs_s1_writedata;            
                when "001111"  => null; -- not a register   
                when "010000"  => band3_gain_int          <= avs_s1_writedata;            
                when "010001"  => band3_delay_int         <= avs_s1_writedata;            
                when "010010"  => band3_drc_threshold_int <= avs_s1_writedata;            
                when "010011"  => band3_drc_gain1_int     <= avs_s1_writedata;            
                when "010100"  => band3_drc_gain2_int     <= avs_s1_writedata;            
                when "010101"  => band3_drc_exponent_int  <= avs_s1_writedata;            
                when "010110"  => band3_drc_bypass_int    <= avs_s1_writedata;            
                when "010111"  => null; -- not a register
                when "011000"  => band4_gain_int          <= avs_s1_writedata;
                when "011001"  => band4_delay_int         <= avs_s1_writedata;
                when "011010"  => band4_drc_threshold_int <= avs_s1_writedata;
                when "011011"  => band4_drc_gain1_int     <= avs_s1_writedata;
                when "011100"  => band4_drc_gain2_int     <= avs_s1_writedata;
                when "011101"  => band4_drc_exponent_int  <= avs_s1_writedata;
                when "011110"  => band4_drc_bypass_int    <= avs_s1_writedata;
                when "011111"  => null; -- not a register                     
                when "100000"  => band5_gain_int          <= avs_s1_writedata;
                when "100001"  => band5_delay_int         <= avs_s1_writedata;
                when "100010"  => band5_drc_threshold_int <= avs_s1_writedata;
                when "100011"  => band5_drc_gain1_int     <= avs_s1_writedata;
                when "100100"  => band5_drc_gain2_int     <= avs_s1_writedata;
                when "100101"  => band5_drc_exponent_int  <= avs_s1_writedata;
                when "100110"  => band5_drc_bypass_int    <= avs_s1_writedata;
                when "100111"  => null; -- not a register                                  
                when others    => null;                     
            end case;
        end if;    
	end process;
      
      
    band1_gain          <= band1_gain_int;         
    band1_delay         <= band1_delay_int;        
    band1_drc_threshold <= band1_drc_threshold_int;
    band1_drc_gain1     <= band1_drc_gain1_int;    
    band1_drc_gain2     <= band1_drc_gain2_int;    
    band1_drc_exponent  <= band1_drc_exponent_int; 
    band1_drc_bypass    <= band1_drc_bypass_int(0);   
    band2_gain          <= band2_gain_int;         
    band2_delay         <= band2_delay_int;        
    band2_drc_threshold <= band2_drc_threshold_int;
    band2_drc_gain1     <= band2_drc_gain1_int;    
    band2_drc_gain2     <= band2_drc_gain2_int;    
    band2_drc_exponent  <= band2_drc_exponent_int; 
    band2_drc_bypass    <= band2_drc_bypass_int(0);   
    band3_gain          <= band3_gain_int;         
    band3_delay         <= band3_delay_int;        
    band3_drc_threshold <= band3_drc_threshold_int;
    band3_drc_gain1     <= band3_drc_gain1_int;    
    band3_drc_gain2     <= band3_drc_gain2_int;    
    band3_drc_exponent  <= band3_drc_exponent_int; 
    band3_drc_bypass    <= band3_drc_bypass_int(0);   
    band4_gain          <= band4_gain_int;         
    band4_delay         <= band4_delay_int;        
    band4_drc_threshold <= band4_drc_threshold_int;
    band4_drc_gain1     <= band4_drc_gain1_int;    
    band4_drc_gain2     <= band4_drc_gain2_int;    
    band4_drc_exponent  <= band4_drc_exponent_int; 
    band4_drc_bypass    <= band4_drc_bypass_int(0);   
    band5_gain          <= band5_gain_int;         
    band5_delay         <= band5_delay_int;        
    band5_drc_threshold <= band5_drc_threshold_int;
    band5_drc_gain1     <= band5_drc_gain1_int;    
    band5_drc_gain2     <= band5_drc_gain2_int;    
    band5_drc_exponent  <= band5_drc_exponent_int; 
    band5_drc_bypass    <= band5_drc_bypass_int(0);   
      
end behavior;

