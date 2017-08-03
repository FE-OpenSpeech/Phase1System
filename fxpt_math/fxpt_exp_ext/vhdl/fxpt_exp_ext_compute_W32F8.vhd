-------------------------------------------------------------------
-- Note: This is machine generated code.  Do not hand edit.
--       Modify Matlab function fxpt_exp_ext_vhdl_code_gen.m instead.
--       This file was auto generated on 08-Jul-2017 16:14:09
--       This VDHL file computes the extended domain fixed-point exp() function
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fxpt_exp_ext_compute_W32F8 is
   port (
      clock	: in  std_logic;
      reset	: in  std_logic;
      x	    : in  std_logic_vector(31 downto 0);
      start	: in  std_logic;
      y     : out std_logic_vector(31 downto 0);   -- y=exp(x)  (extended x domain)
      done  : out std_logic
   );
end entity;

architecture rtl of fxpt_exp_ext_compute_W32F8 is
                                                                                     
   component fxpt_exp_compute_W28F24                                                 
      port (                                                                         
         clock	: in  std_logic;                                                      
         reset	: in  std_logic;                                                      
         x	    : in  std_logic_vector(27 downto 0);                                  
         start	: in  std_logic;                                                      
         y     : out std_logic_vector(27 downto 0);   -- y=exp(x)  -1.24 <= x <= 1.56
         done  : out std_logic                                                       
      );                                                                             
   end component;                                                                    

   type state_type is (state_wait, state_start, state_c2, state_c3, state_c4, state_c5, state_exp_wait, state_done);
   signal state : state_type;

   constant log2e           :   signed(31 downto 0) := "00000000000000000000000101110001";  --00000171
   constant ln2             :   signed(31 downto 0) := "00000000000000000000000010110001";  --000000b1
   signal exp_flag_start    :   std_logic;
   signal exp_flag_done     :   std_logic;
   signal t1                :   signed(31 downto 0);
   signal t1_abs            :   unsigned(31 downto 0);
   signal t1I               :   unsigned(23 downto 0);
   signal t1F               :   signed(31 downto 0);
   signal t2                :   signed(31 downto 0);
   signal t2_resized        :   std_logic_vector(27 downto 0);
   signal t3                :   signed(31 downto 0);
   signal t4                :   signed(31 downto 0);
   signal y2                :   std_logic_vector(27 downto 0);
   signal y2_resized        :   signed(31 downto 0);
   signal yo                :   signed(31 downto 0);
 
begin

  EXP1 : fxpt_exp_compute_W28F24
     port map (
        clock    => clock,
        reset    => reset,
        x        => t2_resized,
        start    => exp_flag_start,
        y        => y2,
        done     => exp_flag_done
     );

   t2_resized <= std_logic_vector( t2(11 downto 0) & "0000000000000000" );        -- resize signal to match exp() signal I/O
   y2_resized <= resize(signed(y2(27 downto 16)), y2_resized'length);   -- resize signal to match exp() signal I/O

   process (clock)
   begin
         if rising_edge(clock) and exp_flag_done = '1' then
               t3 <= y2_resized;           -- grab t3=exp(t2) result 

         end if;
   end process;

   -- Logic to advance to the next state
   process (clock, reset)
   begin
         if reset = '1' then
               state <= state_wait;
         elsif (rising_edge(clock)) then
               case state is
                     when state_wait =>
                           if start = '1' then
                                 state <= state_start;
                           else
                                 state <= state_wait;
                           end if;
  
                     when state_start =>
                           state <= state_c2;
  
                     when state_c2 =>
                           state <= state_c3;
  
                     when state_c3 =>
                           state <= state_c4;
  
                     when state_c4 =>
                           state <= state_c5;
  
                     when state_c5 =>
                           state <= state_exp_wait;
  
                     when state_exp_wait =>
                           if exp_flag_done = '1' then
                                 state <= state_done;
                           else
                                 state <= state_exp_wait;
                           end if;
  
                     when state_done =>
                           state <= state_wait;
  
                     when others =>
                           state <= state_wait;
               end case;
         end if;
   end process;

   -- Perform Computations that are state dependent
   compute : process (clock)
      variable t1v   :   signed(63 downto 0);
      variable t2v   :   signed(63 downto 0);
   begin
         if (rising_edge(clock)) then
               done               <= '0';
               exp_flag_start     <= '0';
               case state is
  
                     when state_wait => 
  
                     when state_start =>
                           t1v := signed(x)*log2e;
                           t1 <= t1v( 39 downto 8);
  
                     when state_c2 =>
                           if t1(31) = '1' then
                                 t1_abs <= not(unsigned(t1)) + 1;
                           else
                                 t1_abs <= unsigned(t1);
                           end if;
  
                     when state_c3 =>
                           t1I <= t1_abs(31 downto 8);   -- Integer bits 
                           if t1(31) = '0' then
                                 t1F <= signed("000000000000000000000000" & t1_abs(7 downto 0));    -- Fractional bits
                           else
                                 t1F <= signed(not("000000000000000000000000" & t1_abs(7 downto 0))+1);    -- Fractional bits
                           end if;
  
                     when state_c4 =>
                           t2v := t1F * ln2;
                           t2 <= t2v( 39 downto 8);
  
                     when state_c5 =>
                           exp_flag_start <= '1';  -- start y=exp(t2) computation now that -1.24 <= t2 <= 1.56
  
                     when state_exp_wait =>    -- wait for y=exp(t2) computation to finish
  
                     when state_done =>
                           done <= '1';        -- signal that the computation is finished.
                           if t1(31) = '0' then
                                 yo <=  shift_left(t3, to_integer(t1I));
                           else
                                 yo <=  shift_right(t3, to_integer(t1I));
                           end if;
  
                     when others =>
               end case;
         end if;
   end process;
   y <= std_logic_vector(yo);

end rtl;
