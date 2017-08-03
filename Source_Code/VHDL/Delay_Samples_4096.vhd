--!@file
----------------------------------------------------------------------------------
-- Company:          Flat Earth Inc
-- Author/Engineer:  Ross Snider
-- 
-- Create Date:    7/11/2017
-- Design Name: 
-- Module Name:    
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

--! @brief A time delay block for the streaming audio bus
--!
--! @details This block will delay a streaming audio signal N clock cycles to allow for syncronizing group delays
--! or simply delaying a signal.
--!

--! Use the IEEE libraries
LIBRARY IEEE;

--! Use STD_LOGIC date types
USE IEEE.std_logic_1164.all;

--! Use standard integer data types
USE IEEE.numeric_std.ALL;

ENTITY Delay_Samples_4096 IS
    PORT( 
        Fs_clk              :   IN    std_logic;                        --! Sample rate clock
        reset               :   IN    std_logic;                        --! Active high reset line
        Delay               :   IN    unsigned(11 DOWNTO 0);            --! Number of samples to delay
        samples_in          :   IN    std_logic_vector(31 DOWNTO 0);    --! Streaming data in port
        samples_out         :   OUT   std_logic_vector(31 DOWNTO 0)     --! Streamin data out port
    );
END Delay_Samples_4096;

--! Architecture for a time delay block
ARCHITECTURE Delay_Samples_4096_arch OF Delay_Samples_4096 IS

    --! Memory blocks used to store the data buffer
    component RAM2port_4096x32
        PORT
        (
            clock       : IN STD_LOGIC  := '1';
            data        : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            rdaddress   : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            wraddress   : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            wren        : IN STD_LOGIC  := '0';
            q           : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    end component;
     

    signal write_counter : unsigned(11 DOWNTO 0);                   --! Internal variable to keep track of the write pointer position
    signal write_ptr     : unsigned(11 DOWNTO 0);                   --! Counter to store the position in the buffer to write the next signal to
    signal read_ptr      : unsigned(11 DOWNTO 0);                   --! Counter to store the position in the buffer to read the next signal from
    signal data_out      : std_logic_vector(31 DOWNTO 0);           --! Registered signal containing the data to send out

begin

    with Delay select
        samples_out <= samples_in when "000000000000",
                       data_out   when others;

     
    process (Fs_clk)
    begin
        if reset = '1' then
            write_counter <= (others => '0');
        elsif rising_edge(Fs_clk) then
            write_counter <= write_counter + 1;
        end if;
    end process;
    
    write_ptr <= write_counter;
    read_ptr  <= write_ptr - Delay;  -- there is already one clock delay through dual port memory

    --! Memory instance to store the audio data
    Delay_memory : RAM2port_4096x32 PORT MAP (
        clock       => Fs_clk,
        data        => samples_in,
        rdaddress   => std_logic_vector(read_ptr),
        wraddress   => std_logic_vector(write_ptr),
        wren        => '1',
        q           => data_out
    );
    


end;

