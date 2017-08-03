function v = fxpt_log_vhdl_code_gen()
global fxpt_math_home_dir;   % NOTE: run \fxpt_math\setup.m to setup global dir, paths, and word length W and fraction length F
global fxptM;
W = fxptM.log.W;
F = fxptM.log.F;


%function [yfxpt]=fxpt_log_vhdl_code_gen(xi)
% Domain of y=ln(x):  0.21 <= x <= 3.45
if W < F+3
    disp(['Warning: fxpt_log() has been design for fixedpoint word lengths of W=S+I+F where S=1, I=2'])
    disp(['         W should be: ' num2str(F+3) ' since we need I=2 and S=1.'])
    disp(['         The fixed-point data type passed in has W = ' num2str(W) ' and F = ' num2str(F)]);
end

S = 1;  % 

%-------------------------------------------------------------------
% Setup local fimath properties
%-------------------------------------------------------------------
   Fm = fimath('ProductMode','SpecifyPrecision',...
        'OverflowAction','Wrap',...
        'RoundingMethod','Floor',...
        'ProductWordLength',W,...
        'ProductFractionLength',F,...
        'SumMode','SpecifyPrecision',...
        'SumWordLength',W,...
        'SumFractionLength',F);

%-----------------------------------------------------------------------
% Create the bi coefficients and ln(bi) coefficients with F fractional
% bits of precision (First two columns of Table 9.1 on page 166.)
% We ignore the last two columns since we will use the one sided
% selection rule (see paragraph following equation (9.10).
%-----------------------------------------------------------------------
for i=0:W-1
    b(i+1) = fi(1+2^(-i),S,W,F,Fm);
    lnb(i+1) = fi(log(1+2^(-i)),S,W,F,Fm);
end

AW = ceil(log2(W));

%-----------------------------------------------------------------------
% Generate ROM VHDL code for the b and lnb coefficients
%-----------------------------------------------------------------------
v_ROM_b   = fxpt_log_vhdl_code_gen_ROM_b_coef(b);
v_ROM_lnb = fxpt_log_vhdl_code_gen_ROM_lnb_coef(lnb);

%-----------------------------------------------------------------------
% Generate the computation VHDL code
%-----------------------------------------------------------------------
v.component = [];    
entity1   = ['fxpt_log_compute_W' num2str(W) 'F' num2str(F)]; v.entity = entity1;
disp(['Generating VDHL code for : ' entity1]); 
filename1 = [entity1 '.vhd'];
dirpath = [fxpt_math_home_dir '\fxpt_log\source_code\vhdl\'];
fid = fopen([dirpath filename1],'w');
str = ['-------------------------------------------------------------------']; fprintf(fid,'%s\n',str);
str = ['-- Note: This is machine generated code.  Do not hand edit.']; fprintf(fid,'%s\n',str);
str = ['--       Modify Matlab function ' mfilename '.m instead.']; fprintf(fid,'%s\n',str);
str = ['--       This file was auto generated on ' datestr(now)]; fprintf(fid,'%s\n',str);
str = ['--       This VDHL file computes the fixed-point log() function']; fprintf(fid,'%s\n',str);
str = ['--       (natural log) using multiplicative normalization.']; fprintf(fid,'%s\n',str);
str = ['-------------------------------------------------------------------']; fprintf(fid,'%s\n',str);
str = ['library ieee;']; fprintf(fid,'%s\n',str);
str = ['use ieee.std_logic_1164.all;']; fprintf(fid,'%s\n',str);
str = ['use ieee.numeric_std.all;']; fprintf(fid,'%s\n\n',str);
str = ['entity ' entity1 ' is']; fprintf(fid,'%s\n',str); v.component = char(v.component,['component ' entity1]);
str = ['   port (']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      clock	 : in  std_logic;']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      reset	 : in  std_logic;']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      x	     : in  std_logic_vector(' num2str(W-1) ' downto 0);' ]; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      start	 : in  std_logic;' ]; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      y      : out std_logic_vector(' num2str(W-1) ' downto 0);   -- y=ln(x)']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      done   : out std_logic']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['   );']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['end entity;']; fprintf(fid,'%s\n\n',str); v.component = char(v.component,'end component;');
str = ['architecture rtl of ' entity1 ' is']; fprintf(fid,'%s\n',str);

% insert ROM b component declaration
S = size(v_ROM_b.component);
for i=1:S(1)
   fprintf(fid,'%s\n',[blanks(3) v_ROM_b.component(i,:)]);
end

% insert ROM lnb component declaration
S = size(v_ROM_lnb.component);
for i=1:S(1)
   fprintf(fid,'%s\n',[blanks(3) v_ROM_lnb.component(i,:)]);
end
fprintf(fid,'\n');

% states for state machine
str = ['   type state_type is (state_wait, state_start, state_pcompute, state_xyupdate, state_done);']; fprintf(fid,'%s\n',str);
str = ['   signal state : state_type;']; fprintf(fid,'%s\n\n',str);
str = ['   signal xi                :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal yi                :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal p                 :   signed(' num2str(2*W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal b_coef            :   std_logic_vector(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal lnb_coef          :   std_logic_vector(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal lnb_coef_z1       :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal step_counter      :   unsigned(' num2str(AW+1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal flag_done         :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal flag_zero_counter   :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal flag_counter_enable :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   constant y0              :   signed(' num2str(W-1) ' downto 0) := (others => ''0'');']; fprintf(fid,'%s\n',str);
b = fi(1,1,2*W,2*F);
str = ['   constant c1              :   signed(' num2str(2*W-1) ' downto 0) := "' b.bin  '";']; fprintf(fid,'%s\n',str);
b = fi(W,1,AW+2,0)
str = ['   constant c' num2str(W) '             :   unsigned(' num2str(AW+1) ' downto 0) := "' b.bin  '";']; fprintf(fid,'%s\n',str);
str = [' ']; fprintf(fid,'%s\n',str);


str = ['begin']; fprintf(fid,'%s\n\n',str);

% insert ROM b component port mapping
str = ['  ROM1 : ' v_ROM_b.entity]; fprintf(fid,'%s\n',str);
str = ['     port map (']; fprintf(fid,'%s\n',str);
str = ['        clock    => clock,']; fprintf(fid,'%s\n',str);
str = ['        address  => std_logic_vector(step_counter(' num2str(AW-1) ' downto 0)),']; fprintf(fid,'%s\n',str);
str = ['        b_coef => b_coef']; fprintf(fid,'%s\n',str);
str = ['     );']; fprintf(fid,'%s\n\n',str);

% insert ROM lnb component port mapping
str = ['  ROM2 : ' v_ROM_lnb.entity]; fprintf(fid,'%s\n',str);
str = ['     port map (']; fprintf(fid,'%s\n',str);
str = ['        clock    => clock,']; fprintf(fid,'%s\n',str);
str = ['        address  => std_logic_vector(step_counter(' num2str(AW-1) ' downto 0)),']; fprintf(fid,'%s\n',str);
str = ['        lnb_coef => lnb_coef']; fprintf(fid,'%s\n',str);
str = ['     );']; fprintf(fid,'%s\n\n',str);


% insert State Machine - next state logic
str = ['   -- Logic to advance to the next state']; fprintf(fid,'%s\n',str);
str = ['   process (clock, reset)']; fprintf(fid,'%s\n',str);
str = ['   begin']; fprintf(fid,'%s\n',str);
str = ['         if reset = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['               state <= state_wait;']; fprintf(fid,'%s\n',str);
str = ['         elsif (rising_edge(clock)) then']; fprintf(fid,'%s\n',str);
str = ['               case state is']; fprintf(fid,'%s\n',str);
str = ['                     when state_wait =>']; fprintf(fid,'%s\n',str);
str = ['                           if start = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_start;']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_wait;']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['                     when state_start =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_pcompute;']; fprintf(fid,'%s\n',str);
str = ['                     when state_pcompute =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_xyupdate;']; fprintf(fid,'%s\n',str);
str = ['                     when state_xyupdate =>']; fprintf(fid,'%s\n',str);
str = ['                           if flag_done = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_done;']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_pcompute;']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['                     when state_done =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_wait;']; fprintf(fid,'%s\n',str);
str = ['                     when others =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_wait;']; fprintf(fid,'%s\n',str);
str = ['               end case;']; fprintf(fid,'%s\n',str);
str = ['         end if;']; fprintf(fid,'%s\n',str);
str = ['   end process;']; fprintf(fid,'%s\n\n',str);

W2 = W*2;
F2 = F*2;
I = W-F;
I2 = I*2;
Wstart = W2-I-1;
Wend   = Wstart - W + 1;
% insert computation process 
str = ['   -- Perform Computations that are state dependent']; fprintf(fid,'%s\n',str);
str = ['   compute : process (clock)']; fprintf(fid,'%s\n',str);
str = ['   begin']; fprintf(fid,'%s\n',str);
str = ['         if (rising_edge(clock)) then']; fprintf(fid,'%s\n',str);
str = ['               done                <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['               flag_zero_counter   <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['               flag_counter_enable <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['               y                   <= (others => ''0'');']; fprintf(fid,'%s\n',str);
str = ['               case state is']; fprintf(fid,'%s\n',str);
str = ['                     when state_wait => ']; fprintf(fid,'%s\n',str);
str = ['                           flag_zero_counter <= ''1'';']; fprintf(fid,'%s\n',str);
str = ['                     when state_start =>']; fprintf(fid,'%s\n',str);
str = ['                           xi       <= signed(x);          -- xi starts with x=x']; fprintf(fid,'%s\n',str);
str = ['                           yi       <= y0;                 -- yi starts with y=0']; fprintf(fid,'%s\n',str);
str = ['                     when state_pcompute =>']; fprintf(fid,'%s\n',str);
str = ['                           p                   <= xi * signed(b_coef);  -- first comparison P = X0 * (1+2^(-i))  (i=0)']; fprintf(fid,'%s\n',str);
str = ['                           lnb_coef_z1         <= signed(lnb_coef);  -- first comparison P = X0 * (1+2^(-i))  (i=0)']; fprintf(fid,'%s\n',str);
str = ['                           flag_counter_enable <= ''1'';']; fprintf(fid,'%s\n',str);
str = ['                     when state_xyupdate =>']; fprintf(fid,'%s\n',str);
str = ['                           if p <= c1 then    -- if p is less than 1, except changes']; fprintf(fid,'%s\n',str);
str = ['                                 xi <= p( ' num2str(Wstart) ' downto ' num2str(Wend) ');']; fprintf(fid,'%s\n',str);
str = ['                                 yi <= yi - lnb_coef_z1;']; fprintf(fid,'%s\n',str);
str = ['                           else                   -- otherwise result is greater than 1 so don''t change and try again with new b coefficent']; fprintf(fid,'%s\n',str);
str = ['                                 xi <= xi;']; fprintf(fid,'%s\n',str);
str = ['                                 yi <= yi;']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['                     when state_done =>']; fprintf(fid,'%s\n',str);
str = ['                           y                 <= std_logic_vector(yi);']; fprintf(fid,'%s\n',str);
str = ['                           done              <= ''1'';      -- signal that the computation is finished.']; fprintf(fid,'%s\n',str);
str = ['                           flag_zero_counter <= ''1'';']; fprintf(fid,'%s\n',str);
str = ['                     when others =>']; fprintf(fid,'%s\n',str);
str = ['               end case;']; fprintf(fid,'%s\n',str);
str = ['         end if;']; fprintf(fid,'%s\n',str);
str = ['   end process;']; fprintf(fid,'%s\n',str);

% insert convergence step counter
str = ['   -- Convergence step counter']; fprintf(fid,'%s\n',str);
str = ['   step_count1 : process (clock) is']; fprintf(fid,'%s\n',str);
str = ['   begin']; fprintf(fid,'%s\n',str);
str = ['         if(rising_edge(clock)) then']; fprintf(fid,'%s\n',str);
str = ['               if flag_zero_counter = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                     step_counter <= (others => ''0'');']; fprintf(fid,'%s\n',str);
str = ['               elsif flag_counter_enable = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                     step_counter <= step_counter + 1;']; fprintf(fid,'%s\n',str);
str = ['               end if;']; fprintf(fid,'%s\n',str);
str = ['         end if;']; fprintf(fid,'%s\n',str);
str = ['   end process;']; fprintf(fid,'%s\n\n',str);

% insert threshold comparison
str = ['   -- Check when to stop convergence']; fprintf(fid,'%s\n',str);
str = ['   step_threshold : process (clock) is']; fprintf(fid,'%s\n',str);
str = ['   begin']; fprintf(fid,'%s\n',str);
str = ['          if(rising_edge(clock)) then']; fprintf(fid,'%s\n',str);
str = ['                flag_done <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['                if step_counter >= c' num2str(W) ' then ' ]; fprintf(fid,'%s\n',str);
str = ['                      flag_done <= ''1'';']; fprintf(fid,'%s\n',str);
str = ['                end if;']; fprintf(fid,'%s\n',str);
str = ['          end if;']; fprintf(fid,'%s\n',str);
str = ['   end process;']; fprintf(fid,'%s\n\n',str);

str = ['end rtl;']; fprintf(fid,'%s\n',str);
    
fclose(fid);


