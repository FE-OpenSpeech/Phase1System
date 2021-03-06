-------------------------------------------------------------------
-- Note: This is machine generated code.  Do not hand edit.
--       Modify Matlab function fxpt_log_vhdl_code_gen_ROM_b_coef.m instead.
--       This file was auto generated on 08-Jul-2017 16:05:00
--       This VDHL file creates a ROM of bi=(1+2^-i) coefficients to be used in
--       calculating the fixed-point log() function
--       using multiplicative normalization.
-------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fxpt_log_ROM_b_coef_W26F24 is
   port (
      clock     : in  std_logic;
      address   : in  std_logic_vector( 4 downto 0);
      b_coef    : out std_logic_vector(25 downto 0)
   );
end entity;

architecture rtl of fxpt_log_ROM_b_coef_W26F24 is
begin
   process (clock) is
   begin
       if(rising_edge(clock)) then
           case (address) is  -- i=address;  bi=(1+2^-i) 
              when "00000" => b_coef <= "10000000000000000000000000";  -- bi = -0.000000000000000000000000 = 2000000
              when "00001" => b_coef <= "01100000000000000000000000";  -- bi =  1.100000000000000000000000 = 1800000
              when "00010" => b_coef <= "01010000000000000000000000";  -- bi =  1.010000000000000000000000 = 1400000
              when "00011" => b_coef <= "01001000000000000000000000";  -- bi =  1.001000000000000000000000 = 1200000
              when "00100" => b_coef <= "01000100000000000000000000";  -- bi =  1.000100000000000000000000 = 1100000
              when "00101" => b_coef <= "01000010000000000000000000";  -- bi =  1.000010000000000000000000 = 1080000
              when "00110" => b_coef <= "01000001000000000000000000";  -- bi =  1.000001000000000000000000 = 1040000
              when "00111" => b_coef <= "01000000100000000000000000";  -- bi =  1.000000100000000000000000 = 1020000
              when "01000" => b_coef <= "01000000010000000000000000";  -- bi =  1.000000010000000000000000 = 1010000
              when "01001" => b_coef <= "01000000001000000000000000";  -- bi =  1.000000001000000000000000 = 1008000
              when "01010" => b_coef <= "01000000000100000000000000";  -- bi =  1.000000000100000000000000 = 1004000
              when "01011" => b_coef <= "01000000000010000000000000";  -- bi =  1.000000000010000000000000 = 1002000
              when "01100" => b_coef <= "01000000000001000000000000";  -- bi =  1.000000000001000000000000 = 1001000
              when "01101" => b_coef <= "01000000000000100000000000";  -- bi =  1.000000000000100000000000 = 1000800
              when "01110" => b_coef <= "01000000000000010000000000";  -- bi =  1.000000000000010000000000 = 1000400
              when "01111" => b_coef <= "01000000000000001000000000";  -- bi =  1.000000000000001000000000 = 1000200
              when "10000" => b_coef <= "01000000000000000100000000";  -- bi =  1.000000000000000100000000 = 1000100
              when "10001" => b_coef <= "01000000000000000010000000";  -- bi =  1.000000000000000010000000 = 1000080
              when "10010" => b_coef <= "01000000000000000001000000";  -- bi =  1.000000000000000001000000 = 1000040
              when "10011" => b_coef <= "01000000000000000000100000";  -- bi =  1.000000000000000000100000 = 1000020
              when "10100" => b_coef <= "01000000000000000000010000";  -- bi =  1.000000000000000000010000 = 1000010
              when "10101" => b_coef <= "01000000000000000000001000";  -- bi =  1.000000000000000000001000 = 1000008
              when "10110" => b_coef <= "01000000000000000000000100";  -- bi =  1.000000000000000000000100 = 1000004
              when "10111" => b_coef <= "01000000000000000000000010";  -- bi =  1.000000000000000000000010 = 1000002
              when "11000" => b_coef <= "01000000000000000000000001";  -- bi =  1.000000000000000000000001 = 1000001
              when "11001" => b_coef <= "01000000000000000000000000";  -- bi =  1.000000000000000000000000 = 1000000
              when others  => b_coef <= (others => '0');
           end case;
        end if;
     end process;
end rtl;
