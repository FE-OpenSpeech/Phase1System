-------------------------------------------------------------------
-- Note: This is machine generated code.  Do not hand edit.
--       Modify Matlab function fxpt_exp_vhdl_code_gen.m instead.
--       This file was auto generated on 24-Jun-2017 18:23:26
--       This VDHL file computes the fixed-point exp() function
--       using additive two-sided normalization.
--       This function expects an x domain in y=exp(x) of -1.24 <= x <= 1.56.
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fxpt_exp_compute_W32F28 is
   port (
      clock	: in  std_logic;
      reset	: in  std_logic;
      x	    : in  std_logic_vector(31 downto 0);
      start	: in  std_logic;
      y     : out std_logic_vector(31 downto 0);   -- y=exp(x)  -1.24 <= x <= 1.56
      done  : out std_logic
   );
end entity;

architecture rtl of fxpt_exp_compute_W32F28 is
                                                       
   component fxpt_exp_ROM_bp_coef_W32F28               
      port (                                           
         clock     : in  std_logic;                    
         address   : in  std_logic_vector( 4 downto 0);
         bp_coef   : out std_logic_vector(31 downto 0) 
      );                                               
   end component;                                      
                                                       
   component fxpt_exp_ROM_bn_coef_W32F28               
      port (                                           
         clock     : in  std_logic;                    
         address   : in  std_logic_vector( 4 downto 0);
         bn_coef   : out std_logic_vector(31 downto 0) 
      );                                               
   end component;                                      
                                                       
   component fxpt_exp_ROM_lnbp_coef_W32F28             
      port (                                           
         clock     : in  std_logic;                    
         address   : in  std_logic_vector( 4 downto 0);
         lnbp_coef  : out std_logic_vector(31 downto 0)
      );                                               
   end component;                                      
                                                       
   component fxpt_exp_ROM_lnbn_coef_W32F28             
      port (                                           
         clock     : in  std_logic;                    
         address   : in  std_logic_vector( 4 downto 0);
         lnbn_coef  : out std_logic_vector(31 downto 0)
      );                                               
   end component;                                      

   type state_type is (state_wait, state_start, state_start_diff, state_start_abs, state_start_update, state_compute_start, state_compute_diff, state_compute_abs, state_compute_abs_diff, state_compute_update, state_done);
   signal state : state_type;

   signal xi                  :   signed(31 downto 0);
   signal yi                  :   signed(31 downto 0);
   signal yp                  :   signed(63 downto 0);
   signal yn                  :   signed(63 downto 0);
   signal bp_coef             :   std_logic_vector(31 downto 0);
   signal bn_coef             :   std_logic_vector(31 downto 0);
   signal lnbp_coef           :   std_logic_vector(31 downto 0);
   signal lnbn_coef           :   std_logic_vector(31 downto 0);
   signal bp_coef_z1          :   signed(31 downto 0);
   signal bn_coef_z1          :   signed(31 downto 0);
   signal lnbp_coef_z1        :   signed(31 downto 0);
   signal lnbn_coef_z1        :   signed(31 downto 0);
   signal Dp                  :   signed(31 downto 0);
   signal Dn                  :   signed(31 downto 0);
   signal Dz                  :   signed(31 downto 0);
   signal Dp_abs              :   unsigned(31 downto 0);
   signal Dn_abs              :   unsigned(31 downto 0);
   signal Dz_abs              :   unsigned(31 downto 0);
   signal Snz                 :   std_logic;
   signal Snp                 :   std_logic;
   signal Szp                 :   std_logic;
   signal step_counter        :   unsigned(6 downto 0);
   signal flag_done           :   std_logic;
   signal flag_zero_counter   :   std_logic;
   signal flag_counter_enable :   std_logic;
   signal x0                  :   signed(31 downto 0);
   signal y0                  :   signed(31 downto 0);
   constant count26  :   unsigned(6 downto 0) := "0011010";
 
begin

  ROM1 : fxpt_exp_ROM_bp_coef_W32F28
     port map (
        clock    => clock,
        address  => std_logic_vector(step_counter(4 downto 0)),
        bp_coef   => bp_coef
     );

  ROM2 : fxpt_exp_ROM_bn_coef_W32F28
     port map (
        clock    => clock,
        address  => std_logic_vector(step_counter(4 downto 0)),
        bn_coef   => bn_coef
     );

  ROM3 : fxpt_exp_ROM_lnbp_coef_W32F28
     port map (
        clock    => clock,
        address  => std_logic_vector(step_counter(4 downto 0)),
        lnbp_coef => lnbp_coef
     );

  ROM4 : fxpt_exp_ROM_lnbn_coef_W32F28
     port map (
        clock    => clock,
        address  => std_logic_vector(step_counter(4 downto 0)),
        lnbn_coef => lnbn_coef
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
                           state <= state_start_diff;
  
                     when state_start_diff =>
                           state <= state_start_abs;
  
                     when state_start_abs =>
                           state <= state_start_update;
  
                     when state_start_update =>
                           state <= state_compute_start;
  
                     when state_compute_start =>
                           state <= state_compute_diff;
  
                     when state_compute_diff =>
                           state <= state_compute_abs;
  
                     when state_compute_abs =>
                           state <= state_compute_abs_diff;
  
                     when state_compute_abs_diff =>
                           state <= state_compute_update;
  
                     when state_compute_update =>
                           if flag_done = '1' then
                                 state <= state_done;
                           else
                                 state <= state_compute_start;
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
      variable Scat : std_logic_vector(2 downto 0);
      variable vp   :   signed(63 downto 0);
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
                           x0                  <= signed(x);  -- x0=x
                           y0                  <= "00010000000000000000000000000000";  -- y0=1
                           bp_coef_z1          <= signed(bp_coef);
                           bn_coef_z1          <= signed(bn_coef);
                           lnbp_coef_z1        <= signed(lnbp_coef);
                           lnbn_coef_z1        <= signed(lnbn_coef);
                           flag_counter_enable <= '1';
  
                     when state_start_diff =>
                           Dp <= x0 - lnbp_coef_z1;
                           Dn <= (others => '0');          -- zero since we have to ignore the undefined case at i=0
                           Dz <= signed(x);
  
                     when state_start_abs =>
                           if Dp(31) = '1' then
                                 Dp_abs <= not(unsigned(Dp)) + 1;
                           else
                                 Dp_abs <= unsigned(Dp);
                           end if;
                           Dn_abs <= (others => '0');          -- zero since we have to ignore the undefined case at i=0
                           if Dz(31) = '1' then
                                 Dz_abs <= not(unsigned(Dz)) + 1;          -- zero since we have to ignore the undefined case at i=0
                           else
                                 Dz_abs <= unsigned(Dz);
                           end if;
  
                     when state_start_update =>
                           if Dz_abs < Dp_abs then    -- Note: Dn is not checked for i=0 since it is undefined
                                 xi <= Dz;
                                 yi <= y0;         -- yi starts with y0=0
                           else 
                                 xi <= Dp; -- just keep current xi
                                 vp := y0 * bp_coef_z1;
                                 yi <= vp( 59 downto 28); -- first product P = Y0 * (1+2^(-i))  (i=0)
                           end if;
  
                     when state_compute_start =>
                           bp_coef_z1          <= signed(bp_coef);
                           bn_coef_z1          <= signed(bn_coef);
                           lnbp_coef_z1        <= signed(lnbp_coef);
                           lnbn_coef_z1        <= signed(lnbn_coef);
                           flag_counter_enable <= '1';
  
                     when state_compute_diff =>
                           Dp <= xi - lnbp_coef_z1;
                           Dn <= xi - lnbn_coef_z1;
                           Dz <= xi;
  
                     when state_compute_abs =>
                           if Dp(31) = '1' then
                                 Dp_abs <= not(unsigned(Dp)) + 1;
                           else
                                 Dp_abs <= unsigned(Dp);
                           end if;
                           if Dn(31) = '1' then
                                 Dn_abs <= not(unsigned(Dn)) + 1;
                           else
                                 Dn_abs <= unsigned(Dn);
                           end if;
                           if Dz(31) = '1' then
                                 Dz_abs <= not(unsigned(Dz)) + 1;
                           else
                                 Dz_abs <= unsigned(Dz);
                           end if;
  
                     when state_compute_abs_diff =>      -- Parallel Compares and Products
                           if Dn_abs < Dz_abs then       -- Check Dn_abs < Dz_abs
                                 Snz <= '1';
                           else
                                 Snz <= '0';
                           end if;
                           if Dn_abs < Dp_abs then       -- Check Dn_abs < Dp_abs
                                 Snp <= '1';
                           else
                                 Snp <= '0';
                           end if;
                           if Dz_abs < Dp_abs then       -- Check Dz_abs < Dp_abs
                                 Szp <= '1';
                           else
                                 Szp <= '0';
                           end if;
                           yp <= yi * bp_coef_z1;   -- Y update for positive case
                           yn <= yi * bn_coef_z1;   -- Y update for negative case
  
                     when state_compute_update =>
                           Scat := Snz & Snp & Szp;
                           case (Scat) is  -- update yi based on which xi operation moved it closest to zero (2-sided update)
                                 when "111" =>        -- order: Dn < Dz < Dp    ->    Dn closest to zero
                                       xi <= Dn;
                                       yi <= yn( 59 downto 28);
                                 when "110" =>        -- order: Dn < Dp < Dz    ->    Dn closest to zero
                                       xi <= Dn;
                                       yi <= yn( 59 downto 28);
                                 when "011" =>        -- order: Dz < Dn < Dp      ->  Dz closest to zero
                                       xi <= Dz;
                                       yi <= yi;
                                 when "100" =>        -- order: Dz < Dp < Dn      ->  Dz closest to zero
                                       xi <= Dz;
                                       yi <= yi;
                                 when "001" =>        -- order: Dp < Dn < Dz    ->    Dp closest to zero
                                       xi <= Dp;
                                       yi <= yp( 59 downto 28);
                                 when "000" =>        -- order: Dp < Dz < Dn    ->    Dp closest to zero
                                       xi <= Dp;
                                       yi <= yp( 59 downto 28);
                                 when others =>       -- do nothing
                           end case;
  
                     when state_done =>
                           done              <= '1';      -- signal that the computation is finished.
                           y                 <= std_logic_vector(yi);

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
                if step_counter >= count26 then 
                      flag_done <= '1';
                end if;
          end if;
   end process;

end rtl;
