-------------------------------------------------------------------
-- Note: This is machine generated code.  Do not hand edit.
--       Modify Matlab function fxpt_exp_vhdl_code_gen_ROM_lnbn_coef.m instead.
--       This file was auto generated on 08-Jul-2017 16:14:09
--       This VDHL file creates a ROM of bi=ln(1-2^-i) coefficients (lnbn = ln(b_negative)) to be used in
--       calculating the fixed-point exp() function
--       using additive (2-sided) normalization.
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fxpt_exp_ROM_lnbn_coef_W28F24 is
   port (
      clock     : in  std_logic;
      address   : in  std_logic_vector( 4 downto 0);
      lnbn_coef  : out std_logic_vector(27 downto 0)
   );
end entity;

architecture rtl of fxpt_exp_ROM_lnbn_coef_W28F24 is
begin
   rom_proc : process (clock) is
   begin
       if(rising_edge(clock)) then
           case (address) is -- i=address;  bi=ln(1-2^-i) 
              when "00000" => lnbn_coef <= "0000000000000000000000000000";  -- bi = 000.000000000000000000000000
              when "00001" => lnbn_coef <= "1111010011101000110111101000";  -- bi =-000.101100010111001000011000
              when "00010" => lnbn_coef <= "1111101101100101101001110111";  -- bi =-000.010010011010010110001001
              when "00011" => lnbn_coef <= "1111110111011101000011100010";  -- bi =-000.001000100010111100011110
              when "00100" => lnbn_coef <= "1111111011110111101001100111";  -- bi =-000.000100001000010110011001
              when "00101" => lnbn_coef <= "1111111101111101111101010001";  -- bi =-000.000010000010000010101111
              when "00110" => lnbn_coef <= "1111111110111111011111101010";  -- bi =-000.000001000000100000010110
              when "00111" => lnbn_coef <= "1111111111011111110111111101";  -- bi =-000.000000100000001000000011
              when "01000" => lnbn_coef <= "1111111111101111111101111111";  -- bi =-000.000000010000000010000001
              when "01001" => lnbn_coef <= "1111111111110111111111011111";  -- bi =-000.000000001000000000100001
              when "01010" => lnbn_coef <= "1111111111111011111111110111";  -- bi =-000.000000000100000000001001
              when "01011" => lnbn_coef <= "1111111111111101111111111101";  -- bi =-000.000000000010000000000011
              when "01100" => lnbn_coef <= "1111111111111110111111111111";  -- bi =-000.000000000001000000000001
              when "01101" => lnbn_coef <= "1111111111111111011111111111";  -- bi =-000.000000000000100000000001
              when "01110" => lnbn_coef <= "1111111111111111101111111111";  -- bi =-000.000000000000010000000001
              when "01111" => lnbn_coef <= "1111111111111111110111111111";  -- bi =-000.000000000000001000000001
              when "10000" => lnbn_coef <= "1111111111111111111011111111";  -- bi =-000.000000000000000100000001
              when "10001" => lnbn_coef <= "1111111111111111111101111111";  -- bi =-000.000000000000000010000001
              when "10010" => lnbn_coef <= "1111111111111111111110111111";  -- bi =-000.000000000000000001000001
              when "10011" => lnbn_coef <= "1111111111111111111111011111";  -- bi =-000.000000000000000000100001
              when "10100" => lnbn_coef <= "1111111111111111111111101111";  -- bi =-000.000000000000000000010001
              when "10101" => lnbn_coef <= "1111111111111111111111110111";  -- bi =-000.000000000000000000001001
              when "10110" => lnbn_coef <= "1111111111111111111111111011";  -- bi =-000.000000000000000000000101
              when "10111" => lnbn_coef <= "1111111111111111111111111101";  -- bi =-000.000000000000000000000011
              when others  => lnbn_coef <= (others => '0');
           end case;
        end if;
     end process;
end rtl;
