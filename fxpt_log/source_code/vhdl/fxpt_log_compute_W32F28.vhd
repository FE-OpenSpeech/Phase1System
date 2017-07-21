-------------------------------------------------------------------
-- Note: This is machine generated code.  Do not hand edit.
--       Modify Matlab function fxpt_log_vhdl_code_gen.m instead.
--       This file was auto generated on 24-Jun-2017 18:23:26
--       This VDHL file computes the fixed-point log() function
--       (natural log) using multiplicative normalization.
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fxpt_log_compute_W32F28 is
   port (
      clock	 : in  std_logic;
      reset	 : in  std_logic;
      x	     : in  std_logic_vector(31 downto 0);
      start	 : in  std_logic;
      y      : out std_logic_vector(31 downto 0);   -- y=ln(x)
      done   : out std_logic
   );
end entity;

architecture rtl of fxpt_log_compute_W32F28 is
                                                       
   component fxpt_log_ROM_b_coef_W32F28                
      port (                                           
         clock     : in  std_logic;                    
         address   : in  std_logic_vector( 4 downto 0);
         b_coef    : out std_logic_vector(31 downto 0) 
      );                                               
   end component;                                      
                                                       
   component fxpt_log_ROM_lnb_coef_W32F28              
      port (                                           
         clock     : in  std_logic;                    
         address   : in  std_logic_vector( 4 downto 0);
         lnb_coef  : out std_logic_vector(31 downto 0) 
      );                                               
   end component;                                      

   type state_type is (state_wait, state_start, state_pcompute, state_xyupdate, state_done);
   signal state : state_type;

   signal xi                :   signed(31 downto 0);
   signal yi                :   signed(31 downto 0);
   signal p                 :   signed(63 downto 0);
   signal b_coef            :   std_logic_vector(31 downto 0);
   signal lnb_coef          :   std_logic_vector(31 downto 0);
   signal lnb_coef_z1       :   signed(31 downto 0);
   signal step_counter      :   unsigned(6 downto 0);
   signal flag_done         :   std_logic;
   signal flag_zero_counter   :   std_logic;
   signal flag_counter_enable :   std_logic;
   constant y0              :   signed(31 downto 0) := (others => '0');
   constant c1              :   signed(63 downto 0) := "0000000100000000000000000000000000000000000000000000000000000000";
   constant c32             :   unsigned(6 downto 0) := "0100000";
 
begin

  ROM1 : fxpt_log_ROM_b_coef_W32F28
     port map (
        clock    => clock,
        address  => std_logic_vector(step_counter(4 downto 0)),
        b_coef => b_coef
     );

  ROM2 : fxpt_log_ROM_lnb_coef_W32F28
     port map (
        clock    => clock,
        address  => std_logic_vector(step_counter(4 downto 0)),
        lnb_coef => lnb_coef
     );

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
                           state <= state_pcompute;
                     when state_pcompute =>
                           state <= state_xyupdate;
                     when state_xyupdate =>
                           if flag_done = '1' then
                                 state <= state_done;
                           else
                                 state <= state_pcompute;
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
   begin
         if (rising_edge(clock)) then
               done                <= '0';
               flag_zero_counter   <= '0';
               flag_counter_enable <= '0';
               y                   <= (others => '0');
               case state is
                     when state_wait => 
                           flag_zero_counter <= '1';
                     when state_start =>
                           xi       <= signed(x);          -- xi starts with x=x
                           yi       <= y0;                 -- yi starts with y=0
                     when state_pcompute =>
                           p                   <= xi * signed(b_coef);  -- first comparison P = X0 * (1+2^(-i))  (i=0)
                           lnb_coef_z1         <= signed(lnb_coef);  -- first comparison P = X0 * (1+2^(-i))  (i=0)
                           flag_counter_enable <= '1';
                     when state_xyupdate =>
                           if p <= c1 then    -- if p is less than 1, except changes
                                 xi <= p( 59 downto 28);
                                 yi <= yi - lnb_coef_z1;
                           else                   -- otherwise result is greater than 1 so don't change and try again with new b coefficent
                                 xi <= xi;
                                 yi <= yi;
                           end if;
                     when state_done =>
                           y                 <= std_logic_vector(yi);
                           done              <= '1';      -- signal that the computation is finished.
                           flag_zero_counter <= '1';
                     when others =>
               end case;
         end if;
   end process;
   -- Convergence step counter
   step_count1 : process (clock) is
   begin
         if(rising_edge(clock)) then
               if flag_zero_counter = '1' then
                     step_counter <= (others => '0');
               elsif flag_counter_enable = '1' then
                     step_counter <= step_counter + 1;
               end if;
         end if;
   end process;

   -- Check when to stop convergence
   step_threshold : process (clock) is
   begin
          if(rising_edge(clock)) then
                flag_done <= '0';
                if step_counter >= c32 then 
                      flag_done <= '1';
                end if;
          end if;
   end process;

end rtl;
