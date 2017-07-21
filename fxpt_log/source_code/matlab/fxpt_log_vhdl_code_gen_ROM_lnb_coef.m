function v = fxpt_log_vhdl_code_gen_ROM_lnb_coef( b )
global fxpt_math_home_dir;  % run setup.m found in \fxpt_math\utilities to set global variable

W    = b.WordLength;
F    = b.FractionLength; 
AW = ceil(log2(W));

v.component = [];       
entity1   = ['fxpt_log_ROM_lnb_coef_W' num2str(W) 'F' num2str(F)]; v.entity = entity1;
disp(['Generating VDHL code for : ' entity1]); 
filename1 = [entity1 '.vhd']; v.filename = filename1;
dirpath = [fxpt_math_home_dir '\fxpt_log\source_code\vhdl\'];
fid = fopen([dirpath filename1],'w');
str = ['-------------------------------------------------------------------']; fprintf(fid,'%s\n',str);
str = ['-- Note: This is machine generated code.  Do not hand edit.']; fprintf(fid,'%s\n',str);
str = ['--       Modify Matlab function ' mfilename '.m instead.']; fprintf(fid,'%s\n',str);
str = ['--       This file was auto generated on ' datestr(now)]; fprintf(fid,'%s\n',str);
str = ['--       This VDHL file creates a ROM of bi=ln(1+2^-i) coefficients to be used in']; fprintf(fid,'%s\n',str);
str = ['--       calculating the fixed-point log() function']; fprintf(fid,'%s\n',str);
str = ['--       using multiplicative normalization.']; fprintf(fid,'%s\n',str);
str = ['-------------------------------------------------------------------']; fprintf(fid,'%s\n',str);
str = ['library ieee;']; fprintf(fid,'%s\n',str);
str = ['use ieee.std_logic_1164.all;']; fprintf(fid,'%s\n',str);
str = ['use ieee.numeric_std.all;']; fprintf(fid,'%s\n\n',str);
str = ['entity ' entity1 ' is']; fprintf(fid,'%s\n',str); v.component = char(v.component,['component ' entity1]);
str = ['   port (']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      clock     : in  std_logic;']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      address   : in  std_logic_vector( '  num2str(AW-1) ' downto 0);' ]; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      lnb_coef  : out std_logic_vector(' num2str(W-1) ' downto 0)']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['   );']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['end entity;']; fprintf(fid,'%s\n\n',str); v.component = char(v.component,'end component;');
str = ['architecture rtl of ' entity1 ' is']; fprintf(fid,'%s\n',str);
%str = ['   attribute romstyle : string;']; fprintf(fid,'%s\n',str);
%str = ['   attribute romstyle of q : signal is “M9K”;']; fprintf(fid,'%s\n\n',str);
str = ['begin']; fprintf(fid,'%s\n',str);
str = ['   rom_proc : process (clock) is']; fprintf(fid,'%s\n',str);
str = ['   begin']; fprintf(fid,'%s\n',str);
str = ['       if(rising_edge(clock)) then']; fprintf(fid,'%s\n',str);
str = ['           case (address) is -- i=address;  bi=ln(1+2^-i) ']; fprintf(fid,'%s\n',str);
for i=0:W-1
    awf = fi(i,0,AW,0);
    ob = b(i+1);
    str = ['              when "' awf.bin '" => lnb_coef <= "' ob.bin '";  -- lnbi = '  fxpt2str(ob) ' = ' ob.hex]; fprintf(fid,'%s\n',str);
end
str = ['              when others  => lnb_coef <= (others => ''0'');']; fprintf(fid,'%s\n',str);
str = ['           end case;']; fprintf(fid,'%s\n',str);
str = ['        end if;']; fprintf(fid,'%s\n',str);
str = ['     end process;']; fprintf(fid,'%s\n',str);
str = ['end rtl;']; fprintf(fid,'%s\n',str);
    
fclose(fid);

    
