function v = fxpt_exp_vhdl_code_gen_ROM_bn_coef( b )
global fxpt_math_home_dir;  

W    = b.WordLength;
F    = b.FractionLength; 
AW = ceil(log2(W));

v.component = [];    
entity1   = ['fxpt_exp_ROM_bn_coef_W' num2str(W) 'F' num2str(F)]; v.entity = entity1;
disp(['Generating VDHL code for : ' entity1]); 
filename1 = [entity1 '.vhd']; v.filename = filename1;
dirpath = [fxpt_math_home_dir '\fxpt_exp\source_code\vhdl\'];
fid = fopen([dirpath filename1],'w');
str = ['-------------------------------------------------------------------']; fprintf(fid,'%s\n',str);
str = ['-- Note: This is machine generated code.  Do not hand edit.']; fprintf(fid,'%s\n',str);
str = ['--       Modify Matlab function ' mfilename '.m instead.']; fprintf(fid,'%s\n',str);
str = ['--       This file was auto generated on ' datestr(now)]; fprintf(fid,'%s\n',str);
str = ['--       This VDHL file creates a ROM of bi=(1-2^-i) coefficients (bn = b_negative) to be used in']; fprintf(fid,'%s\n',str);
str = ['--       calculating the fixed-point exp() function']; fprintf(fid,'%s\n',str);
str = ['--       using additive (2-sided) normalization.']; fprintf(fid,'%s\n',str);
str = ['-------------------------------------------------------------------']; fprintf(fid,'%s\n',str);
str = ['library ieee;']; fprintf(fid,'%s\n',str);
str = ['use ieee.std_logic_1164.all;']; fprintf(fid,'%s\n',str);
str = ['use ieee.numeric_std.all;']; fprintf(fid,'%s\n\n',str);
str = ['entity ' entity1 ' is']; fprintf(fid,'%s\n',str); v.component = char(v.component,['component ' entity1]);
str = ['   port (']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      clock     : in  std_logic;']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      address   : in  std_logic_vector( ' num2str(AW-1) ' downto 0);' ]; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      bn_coef   : out std_logic_vector(' num2str(W-1) ' downto 0)']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['   );']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['end entity;']; fprintf(fid,'%s\n\n',str); v.component = char(v.component,'end component;');
str = ['architecture rtl of ' entity1 ' is']; fprintf(fid,'%s\n',str);
%str = ['   attribute romstyle : string;']; fprintf(fid,'%s\n',str);
%str = ['   attribute romstyle of q : signal is “M9K”;']; fprintf(fid,'%s\n\n',str);
str = ['begin']; fprintf(fid,'%s\n',str);
str = ['   process (clock) is']; fprintf(fid,'%s\n',str);
str = ['   begin']; fprintf(fid,'%s\n',str);
str = ['       if(rising_edge(clock)) then']; fprintf(fid,'%s\n',str);
str = ['           case (address) is  -- i=address;  bi=(1-2^-i) ']; fprintf(fid,'%s\n',str);
for i=0:F+1
    awf = fi(i,0,AW,0);
    ob = b(i+1);
    str = ['              when "' awf.bin '" => bn_coef <= "' ob.bin '";  -- bi ='  fxpt2str(ob)]; fprintf(fid,'%s\n',str);
end
str = ['              when others  => bn_coef <= (others => ''0'');']; fprintf(fid,'%s\n',str);
str = ['           end case;']; fprintf(fid,'%s\n',str);
str = ['        end if;']; fprintf(fid,'%s\n',str);
str = ['     end process;']; fprintf(fid,'%s\n',str);
str = ['end rtl;']; fprintf(fid,'%s\n',str);
    
fclose(fid);

    
