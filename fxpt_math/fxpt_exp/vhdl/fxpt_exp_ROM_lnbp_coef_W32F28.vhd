-------------------------------------------------------------------
-- Note: This is machine generated code.  Do not hand edit.
--       Modify Matlab function fxpt_exp_vhdl_code_gen_ROM_lnbp_coef.m instead.
--       This file was auto generated on 24-Jun-2017 18:23:26
--       This VDHL file creates a ROM of bi=ln(1+2^-i) coefficients (lnbp = ln(b_positive)) to be used in
--       calculating the fixed-point exp() function
--       using additive (2-sided) normalization.
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fxpt_exp_ROM_lnbp_coef_W32F28 is
   port (
      clock     : in  std_logic;
      address   : in  std_logic_vector( 4 downto 0);
      lnbp_coef  : out std_logic_vector(31 downto 0)
   );
end entity;

architecture rtl of fxpt_exp_ROM_lnbp_coef_W32F28 is
begin
   rom_proc : process (clock) is
   begin
       if(rising_edge(clock)) then
           case (address) is -- i=address;  bi=ln(1+2^-i) 
              when "00000" => lnbp_coef <= "00001011000101110010000101111111";  -- bi = 000.1011000101110010000101111111
              when "00001" => lnbp_coef <= "00000110011111001100100011111011";  -- bi = 000.0110011111001100100011111011
              when "00010" => lnbp_coef <= "00000011100100011111111011111000";  -- bi = 000.0011100100011111111011111000
              when "00011" => lnbp_coef <= "00000001111000100111000001110110";  -- bi = 000.0001111000100111000001110110
              when "00100" => lnbp_coef <= "00000000111110000101000110000110";  -- bi = 000.0000111110000101000110000110
              when "00101" => lnbp_coef <= "00000000011111100000101001101100";  -- bi = 000.0000011111100000101001101100
              when "00110" => lnbp_coef <= "00000000001111111000000101010001";  -- bi = 000.0000001111111000000101010001
              when "00111" => lnbp_coef <= "00000000000111111110000000101010";  -- bi = 000.0000000111111110000000101010
              when "01000" => lnbp_coef <= "00000000000011111111100000000101";  -- bi = 000.0000000011111111100000000101
              when "01001" => lnbp_coef <= "00000000000001111111111000000000";  -- bi = 000.0000000001111111111000000000
              when "01010" => lnbp_coef <= "00000000000000111111111110000000";  -- bi = 000.0000000000111111111110000000
              when "01011" => lnbp_coef <= "00000000000000011111111111100000";  -- bi = 000.0000000000011111111111100000
              when "01100" => lnbp_coef <= "00000000000000001111111111111000";  -- bi = 000.0000000000001111111111111000
              when "01101" => lnbp_coef <= "00000000000000000111111111111110";  -- bi = 000.0000000000000111111111111110
              when "01110" => lnbp_coef <= "00000000000000000011111111111111";  -- bi = 000.0000000000000011111111111111
              when "01111" => lnbp_coef <= "00000000000000000001111111111111";  -- bi = 000.0000000000000001111111111111
              when "10000" => lnbp_coef <= "00000000000000000000111111111111";  -- bi = 000.0000000000000000111111111111
              when "10001" => lnbp_coef <= "00000000000000000000011111111111";  -- bi = 000.0000000000000000011111111111
              when "10010" => lnbp_coef <= "00000000000000000000001111111111";  -- bi = 000.0000000000000000001111111111
              when "10011" => lnbp_coef <= "00000000000000000000000111111111";  -- bi = 000.0000000000000000000111111111
              when "10100" => lnbp_coef <= "00000000000000000000000011111111";  -- bi = 000.0000000000000000000011111111
              when "10101" => lnbp_coef <= "00000000000000000000000001111111";  -- bi = 000.0000000000000000000001111111
              when "10110" => lnbp_coef <= "00000000000000000000000000111111";  -- bi = 000.0000000000000000000000111111
              when "10111" => lnbp_coef <= "00000000000000000000000000011111";  -- bi = 000.0000000000000000000000011111
              when "11000" => lnbp_coef <= "00000000000000000000000000001111";  -- bi = 000.0000000000000000000000001111
              when "11001" => lnbp_coef <= "00000000000000000000000000000111";  -- bi = 000.0000000000000000000000000111
              when "11010" => lnbp_coef <= "00000000000000000000000000000011";  -- bi = 000.0000000000000000000000000011
              when "11011" => lnbp_coef <= "00000000000000000000000000000001";  -- bi = 000.0000000000000000000000000001
              when others  => lnbp_coef <= (others => '0');
           end case;
        end if;
     end process;
end rtl;