-------------------------------------------------------------------
-- Note: This is machine generated code.  Do not hand edit.
--       Modify Matlab function fxpt_log_vhdl_code_gen_ROM_lnb_coef.m instead.
--       This file was auto generated on 07-Jul-2017 15:00:37
--       This VDHL file creates a ROM of bi=ln(1+2^-i) coefficients to be used in
--       calculating the fixed-point log() function
--       using multiplicative normalization.
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fxpt_log_ROM_lnb_coef_W24F24 is
   port (
      clock     : in  std_logic;
      address   : in  std_logic_vector( 4 downto 0);
      lnb_coef  : out std_logic_vector(23 downto 0)
   );
end entity;

architecture rtl of fxpt_log_ROM_lnb_coef_W24F24 is
begin
   rom_proc : process (clock) is
   begin
       if(rising_edge(clock)) then
           case (address) is -- i=address;  bi=ln(1+2^-i) 
              when "00000" => lnb_coef <= "101100010111001000010111";  -- lnbi = -.010011101000110111101001 = b17217
              when "00001" => lnb_coef <= "011001111100110010001111";  -- lnbi =  .011001111100110010001111 = 67cc8f
              when "00010" => lnb_coef <= "001110010001111111101111";  -- lnbi =  .001110010001111111101111 = 391fef
              when "00011" => lnb_coef <= "000111100010011100000111";  -- lnbi =  .000111100010011100000111 = 1e2707
              when "00100" => lnb_coef <= "000011111000010100011000";  -- lnbi =  .000011111000010100011000 = 0f8518
              when "00101" => lnb_coef <= "000001111110000010100110";  -- lnbi =  .000001111110000010100110 = 07e0a6
              when "00110" => lnb_coef <= "000000111111100000010101";  -- lnbi =  .000000111111100000010101 = 03f815
              when "00111" => lnb_coef <= "000000011111111000000010";  -- lnbi =  .000000011111111000000010 = 01fe02
              when "01000" => lnb_coef <= "000000001111111110000000";  -- lnbi =  .000000001111111110000000 = 00ff80
              when "01001" => lnb_coef <= "000000000111111111100000";  -- lnbi =  .000000000111111111100000 = 007fe0
              when "01010" => lnb_coef <= "000000000011111111111000";  -- lnbi =  .000000000011111111111000 = 003ff8
              when "01011" => lnb_coef <= "000000000001111111111110";  -- lnbi =  .000000000001111111111110 = 001ffe
              when "01100" => lnb_coef <= "000000000000111111111111";  -- lnbi =  .000000000000111111111111 = 000fff
              when "01101" => lnb_coef <= "000000000000011111111111";  -- lnbi =  .000000000000011111111111 = 0007ff
              when "01110" => lnb_coef <= "000000000000001111111111";  -- lnbi =  .000000000000001111111111 = 0003ff
              when "01111" => lnb_coef <= "000000000000000111111111";  -- lnbi =  .000000000000000111111111 = 0001ff
              when "10000" => lnb_coef <= "000000000000000011111111";  -- lnbi =  .000000000000000011111111 = 0000ff
              when "10001" => lnb_coef <= "000000000000000001111111";  -- lnbi =  .000000000000000001111111 = 00007f
              when "10010" => lnb_coef <= "000000000000000000111111";  -- lnbi =  .000000000000000000111111 = 00003f
              when "10011" => lnb_coef <= "000000000000000000011111";  -- lnbi =  .000000000000000000011111 = 00001f
              when "10100" => lnb_coef <= "000000000000000000001111";  -- lnbi =  .000000000000000000001111 = 00000f
              when "10101" => lnb_coef <= "000000000000000000000111";  -- lnbi =  .000000000000000000000111 = 000007
              when "10110" => lnb_coef <= "000000000000000000000011";  -- lnbi =  .000000000000000000000011 = 000003
              when "10111" => lnb_coef <= "000000000000000000000001";  -- lnbi =  .000000000000000000000001 = 000001
              when others  => lnb_coef <= (others => '0');
           end case;
        end if;
     end process;
end rtl;
