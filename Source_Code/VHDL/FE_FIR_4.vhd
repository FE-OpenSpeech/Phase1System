--!@file
----------------------------------------------------------------------------------
-- Company:          Flat Earth Inc
-- Author/Engineer:  Raymond Weber
-- 
-- Create Date:    4/14/2017 
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

--! @brief An custom arbitrary length FIR filter block
--!
--! @details This is a arbitrary length FIR filter block for low latency signal processing,
--! The block will take input from a low frequency source and use a high frequency clock to
--! do a pipeline FIR filter operation with minimal first cycle latency and resource utalization.
--!
--! The filtering operation starts on a valid clock edge, and n+1 clock cycles later a filtered
--! value is registered on the output line.
--!
--! The output is registered so it will never go invalid.
--!
--! The clk must be at least n+1 times faster then the signal to filter due to the pipelining that
--! is done internally.  If this is violated, functionality is not garenteed, but will likely result
--! in samples being skipped.
--!
--! Coefficients and the number of coefficients to use are stored in BRAM and accessable via the MEM signals
--! [0]      = 32 bit unsigned integer of the number of samples to use (must be less then MAX_COEFS generic)
--! [1 -> n] = 32 bit fixed point coefficient values
--!
--!
--! @verbatim 
--! Example timing Diagram
--! Valid In   _____|________________________|_______________________
--! Valid Out  ____________|________________________|________________
--! Data In    -----|DataIn0-----------------|DataIn1----------------
--! Data Out   ------------|DataOut0----------------|DataOut1--------
--! @endverbatim
--!



--! Use the standard library
LIBRARY IEEE;
--! Use std_logic elements
USE IEEE.std_logic_1164.all;
--! Use IEEE signed and unsigned numbers
USE IEEE.numeric_std.ALL;

--! Use Altera/Intel Primitives library
LIBRARY altera_mf;
--! Use the altera components
USE altera_mf.altera_mf_components.all;


ENTITY FE_FIR_4 IS
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
    mem_data_in       : in std_logic_vector(31 downto 0);       --! Write Data in to the data registers to set coefficients
    mem_data_out      : out std_logic_vector(31 downto 0);      --! Read Data @todo Doesn't work
    mem_clk           : in std_logic;                           --! @Clock for the memory interface
    mem_addr          : in std_logic_vector(ADDR_WIDTH-1 downto 0);       --! Address to write to in the register space
    mem_wren          : in std_logic;                           --! write enable
    mem_rden          : in std_logic;                           --! read enable
    ------------------------------------------------------------
    -- Streaming Data Interface
    ------------------------------------------------------------  
    data_in           : in std_logic_vector(31 downto 0);       --! Data coming in to the system as a 32 bit integer (non-float).  Fixed point is at developers discretion.
    data_out          : out std_logic_vector(31 downto 0);      --! Data coming in to the system as a 32 bit integer (non-float).  Fixed point place place will match inputs.
    valid_in          : in std_logic;                           --! Single bit wide pulse at clk to specify that new data is present on data_in
    valid_out         : out std_logic                           --! Single bit wide pulse at clk to specify that new data is present on data_out
  );
END FE_FIR_4;

--! Module Architecture for a 4 sample/clock FIR filter (higher performance and resource usage)
ARCHITECTURE FE_FIR_4_ARCH OF FE_FIR_4 IS

TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(31 DOWNTO 0);            --! Type definition of the sfix32_En28 array to hold the circular shift buffer for the input values

signal delay_pipeline : delay_pipeline_type(0 TO MAX_COEFS);                            --! Array of 32b28f signed values of the inputs, shift buffer
signal add_temp2      : std_logic_vector(63 downto 0) := (others=>'0');                 --! Casted the accumulator register to a std_logic_vector so bits can be extracted @todo eliminate this signal
signal add_temp4_1      : signed(63 downto 0) := to_signed(0,64);                         --! Temp signal to hold the accumulated
signal add_temp4_2      : signed(63 downto 0) := to_signed(0,64);                         --! Temp signal to hold the accumulated
signal add_temp4_3      : signed(63 downto 0) := to_signed(0,64);                         --! Temp signal to hold the accumulated
signal add_temp4_4      : signed(63 downto 0) := to_signed(0,64);                         --! Temp signal to hold the accumulated count of the fir filter
signal mult_count     : integer range 0 to MAX_COEFS := 0;                              --! Counter for the current pipeline element
signal numCoefs       : integer range 0 to MAX_COEFS-1 := 8;                           --! Number of coefficients to use
signal address_a      : std_logic_vector(ADDR_WIDTH-1 downto 0);                        --! Address going into the bram block for the internal logic
signal address_a_reg  : std_logic_vector(ADDR_WIDTH-1 downto 0);                        --! Address delayed by 1 clk cycle, so this is the address of what is coming out of the BRAM
signal data_a         : std_logic_vector(127 downto 0);                                  --! Data register to hold data coming out of the BRAM to be used inside the process


begin
  --! Rotate the data down the delay pipeline 1 slot every time a valid signal appears and insert new data
  Delay_Pipeline_process : PROCESS (clk, reset_n, valid_in)
  BEGIN
    IF reset_n = '0' THEN
      delay_pipeline(0 TO MAX_COEFS-1) <= (OTHERS => (OTHERS => '0'));                  -- Empty the pipeline on reset
    ELSIF rising_edge(clk) THEN
      IF valid_in = '1' then
        delay_pipeline(0) <= signed(data_in);                                           -- Add the new data to the pipeline
        delay_pipeline(1 TO MAX_COEFS-1) <= delay_pipeline(0 TO MAX_COEFS-2);           -- Shift old data down the pipeline
       END IF;
    END IF; 
 END PROCESS Delay_Pipeline_process;
 
 
  --! Increment the pipeline counter and register the data at the completion of the pipeline
  --! Create a valid pulse at the end of the pipeline
  Counter_process : PROCESS (clk, reset_n, numCoefs, mult_count)
  BEGIN
    IF reset_n = '0' THEN
      mult_count <= 0;                                              -- Clear the variable on reset
      --numCoefs <= 32;
    ELSIF clk'event AND clk = '1' THEN
      IF mult_count >= numCoefs + 4 THEN  
        valid_out <='0';
        IF valid_in = '1' then                                      -- If at the max coefficient...
          mult_count <= 0;                                          --   Reset the counter to 0
        END IF;
      ELSIF mult_count = numCoefs+3 then
        valid_out <='1';                                            --   Toggle the valid flag
        add_temp2 <= std_logic_vector(resize(add_temp4_1 + add_temp4_2 + add_temp4_3 + add_temp4_4, add_temp2'length));              --   And update the output
        mult_count <= mult_count + 4;                               --   Increment to the next position in the counter
      ELSE                                                          -- Otherwise
        mult_count <= mult_count + 4;                               --   Increment to the next position in the counter
        valid_out <= '0';                                           --   And leave the valid signal low
      END IF;
    END IF;
  END PROCESS Counter_process;


  --And pull of the bits that are significant
  data_out <= add_temp2(59 downto 28);


  --! Do the multiply accumulate for the FIR filter processing
  Mult_pipeline_process : PROCESS (clk, reset_n)
  BEGIN
    IF reset_n = '0' THEN
      add_temp4_1 <= (others => '0');                             -- Clear the accumulator on reset
      add_temp4_2 <= (others => '0');                             -- Clear the accumulator on reset
      add_temp4_3 <= (others => '0');                             -- Clear the accumulator on reset
      add_temp4_4 <= (others => '0');                             -- Clear the accumulator on reset
    ELSIF clk'event AND clk = '1' THEN
      IF to_integer(unsigned(address_a_reg)) = 0 then           -- Address 0 is getting the max count, so use that as a period to reset the accumulator
        add_temp4_1 <= (others=>'0');
        add_temp4_2 <= (others=>'0');
        add_temp4_3 <= (others=>'0');
        add_temp4_4 <= (others=>'0');
      ELSE
        add_temp4_1 <= add_temp4_1 + resize(delay_pipeline(to_integer(unsigned(address_a_reg))-1) * signed(data_a(31 downto 0) ), add_temp2'length);  --On successive elements, add the previous sum to the current multiplication result
        add_temp4_2 <= add_temp4_2 + resize(delay_pipeline(to_integer(unsigned(address_a_reg))-1) * signed(data_a(63 downto 32) ), add_temp2'length);  --On successive elements, add the previous sum to the current multiplication result
        add_temp4_3 <= add_temp4_3 + resize(delay_pipeline(to_integer(unsigned(address_a_reg))-1) * signed(data_a(95 downto 64) ), add_temp2'length);  --On successive elements, add the previous sum to the current multiplication result
        add_temp4_4 <= add_temp4_4 + resize(delay_pipeline(to_integer(unsigned(address_a_reg))-1) * signed(data_a(127 downto 96) ), add_temp2'length);  --On successive elements, add the previous sum to the current multiplication result
      END IF;
    END IF; 
  END PROCESS Mult_pipeline_process;
    
   
  address_a <=  std_logic_vector(to_unsigned(mult_count, address_a'length));    --! Current address desired read by the FIR filter itself
  

  --! Get the number of coefs to use from the BRAM block @todo, this might make sense to combine with Mult_pipeline_process
  Get_from_BRAM_process : PROCESS (mem_clk, reset_n)
  BEGIN
    IF reset_n = '0' then
      numCoefs <= 0;
    ELSIF rising_edge(clk) then
      address_a_reg <= address_a;                         -- The outputs are delayed by 1 clock cycle, so this is the address of whatever is on data_a
      IF to_integer(unsigned(address_a_reg)) = 0 then     -- If the address is 0, this is the number of coeffs to process
        IF to_integer(unsigned(data_a))>5 then            -- If the number of coeffs requested is to small, then ignore it @todo This is larger then I atually need, but just being safe for now....
          numCoefs <= to_integer(unsigned(data_a));
        END IF;
      END IF;
    END IF;
  END PROCESS;


 
  --Port 1/a = Internal connections to the FIR Filter
  --Port 2/b = Memory mapped in linux for setup
  altsyncram_component : altsyncram
  GENERIC MAP (
    address_reg_b => "CLOCK1",
    clock_enable_input_a => "BYPASS",
    clock_enable_input_b => "BYPASS",
    clock_enable_output_a => "BYPASS",
    clock_enable_output_b => "BYPASS",
    indata_reg_b => "CLOCK1",
    init_file => INIT_FILENAME,
    intended_device_family => "Cyclone V",
    lpm_type => "altsyncram",
    numwords_a => MAX_COEFS,  --512
    numwords_b => MAX_COEFS,  --512
    operation_mode => "BIDIR_DUAL_PORT",
    outdata_aclr_a => "NONE",
    outdata_aclr_b => "NONE",
    outdata_reg_a => "UNREGISTERED",
    outdata_reg_b => "UNREGISTERED",
    power_up_uninitialized => "FALSE",
    ram_block_type => "M10K",
    read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
    read_during_write_mode_port_b => "NEW_DATA_NO_NBE_READ",
    widthad_a => ADDR_WIDTH,    --numwords_a = (2^widthad_a)
    widthad_b => ADDR_WIDTH,
    width_a => 32*4,
    width_b => 32,
    width_byteena_a => 1,
    width_byteena_b => 1,
    wrcontrol_wraddress_reg_b => "CLOCK1"
  )
  PORT MAP (
    address_a => address_a,
    address_b => mem_addr,
    clock0 => clk,
    clock1 => mem_clk,
    data_a => (others=>'0'),
    data_b => mem_data_in,
    rden_a => '1',
    rden_b => mem_rden,
    wren_a => '0',
    wren_b => mem_wren,
    q_a => data_a,
    q_b => mem_data_out
  );

 
end architecture;
