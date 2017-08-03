-------------------------------------------------------------------
-- Note: This is machine generated code.  Do not hand edit.
--       Modify Matlab function fxpt_exp_vhdl_code_gen_ROM_lnbp_coef.m instead.
--       This file was auto generated on 08-Jul-2017 16:14:09
--       This VDHL file creates a ROM of bi=ln(1+2^-i) coefficients (lnbp = ln(b_positive)) to be used in
--       calculating the fixed-point exp() function
--       using additive (2-sided) normalization.
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fxpt_exp_ROM_lnbp_coef_W28F24 is
   port (
      clock     : in  std_logic;
      address   : in  std_logic_vector( 4 downto 0);
      lnbp_coef  : out std_logic_vector(27 downto 0)
   );
end entity;

architecture rtl of fxpt_exp_ROM_lnbp_coef_W28F24 is
begin
   rom_proc : process (clock) is
   begin
       if(rising_edge(clock)) then
           case (address) is -- i=address;  bi=ln(1+2^-i) 
              when "00000" => lnbp_coef <= "0000101100010111001000010111";  -- bi = 000.101100010111001000010111
              when "00001" => lnbp_coef <= "0000011001111100110010001111";  -- bi = 000.011001111100110010001111
              when "00010" => lnbp_coef <= "0000001110010001111111101111";  -- bi = 000.001110010001111111101111
              when "00011" => lnbp_coef <= "0000000111100010011100000111";  -- bi = 000.000111100010011100000111
              when "00100" => lnbp_coef <= "0000000011111000010100011000";  -- bi = 000.000011111000010100011000
              when "00101" => lnbp_coef <= "0000000001111110000010100110";  -- bi = 000.000001111110000010100110
              when "00110" => lnbp_coef <= "0000000000111111100000010101";  -- bi = 000.000000111111100000010101
              when "00111" => lnbp_coef <= "0000000000011111111000000010";  -- bi = 000.000000011111111000000010
              when "01000" => lnbp_coef <= "0000000000001111111110000000";  -- bi = 000.000000001111111110000000
              when "01001" => lnbp_coef <= "0000000000000111111111100000";  -- bi = 000.000000000111111111100000
              when "01010" => lnbp_coef <= "0000000000000011111111111000";  -- bi = 000.000000000011111111111000
              when "01011" => lnbp_coef <= "0000000000000001111111111110";  -- bi = 000.000000000001111111111110
              when "01100" => lnbp_coef <= "0000000000000000111111111111";  -- bi = 000.000000000000111111111111
              when "01101" => lnbp_coef <= "0000000000000000011111111111";  -- bi = 000.000000000000011111111111
              when "01110" => lnbp_coef <= "0000000000000000001111111111";  -- bi = 000.000000000000001111111111
              when "01111" => lnbp_coef <= "0000000000000000000111111111";  -- bi = 000.000000000000000111111111
              when "10000" => lnbp_coef <= "0000000000000000000011111111";  -- bi = 000.000000000000000011111111
              when "10001" => lnbp_coef <= "0000000000000000000001111111";  -- bi = 000.000000000000000001111111
              when "10010" => lnbp_coef <= "0000000000000000000000111111";  -- bi = 000.000000000000000000111111
              when "10011" => lnbp_coef <= "0000000000000000000000011111";  -- bi = 000.000000000000000000011111
              when "10100" => lnbp_coef <= "0000000000000000000000001111";  -- bi = 000.000000000000000000001111
              when "10101" => lnbp_coef <= "0000000000000000000000000111";  -- bi = 000.000000000000000000000111
              when "10110" => lnbp_coef <= "0000000000000000000000000011";  -- bi = 000.000000000000000000000011
              when "10111" => lnbp_coef <= "0000000000000000000000000001";  -- bi = 000.000000000000000000000001
              when others  => lnbp_coef <= (others => '0');
           end case;
        end if;
     end process;
end rtl;
