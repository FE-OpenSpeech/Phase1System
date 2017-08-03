function v=fxpt_exp_ext_vhdl_code_gen()
%function [yfxpt]=fxpt_log_vhdl_code_gen(xi)
global fxpt_math_home_dir;   % NOTE: run \fxpt_math\setup.m to setup global dir, paths, and word length W and fraction length F
global fxptM;
W = fxptM.exp_ext.W;
F = fxptM.exp_ext.F;


 
    % use the precision passed in
   % W    = 32;                   % Number of bits in word
  %  F    = W-2;
%     F    = xi.FractionLength;               % Number of bits in Fraction field
%     Sign = xi.Signedness;                   % Get sign ('Signed' or 'Unsigned')
%     S    = double(strcmp(Sign,'Signed'));   % S=1 if signed, S=0 if unsigned
   %  S = 1;  % force unsigned since xi must be positive
     S = 1;
     %I    = W-F-S;                           % Number of bits in Integer field
%-------------------------------------------------------------------
% Setup local fimath properties
%-------------------------------------------------------------------
Fm = fimath('OverflowAction','Wrap',...
    'RoundingMethod','Floor',...
    'ProductMode','SpecifyPrecision',...
    'ProductWordLength',W,...
    'ProductFractionLength',F,...
    'SumMode','SpecifyPrecision',...
    'SumWordLength',W,...
    'SumFractionLength',F);

%     % create fixed-point objects
%     x0 = fi(double(xi),S,W+S,F,Fm);  % X0
%     y0 = fi(0,S,W+S,F,Fm);  % Y0
%     xd(1) = x0;
%     yd(1) = y0;
%
%-----------------------------------------------------------------------
% Create the bi coefficients and ln(bi) coefficients with F fractional
% bits of precision (First two columns of Table 9.1 on page 166.)
% We ignore the last two columns since we will use the one sided
% selection rule (see paragraph following equation (9.10).
%-----------------------------------------------------------------------

log2e = fi(log2(exp(1)),S,W,F,Fm);
ln2   = fi(log(2),S,W,F,Fm);
%disp(['log2e = ' num2str(log2(exp(1))) '  = ' fxpt2str(log2e)])
%disp(['ln2   = ' num2str(log(2)) ' = ' fxpt2str(ln2)])

v_exp = fxpt_exp_vhdl_code_gen();

AW = ceil(log2(W));

%-----------------------------------------------------------------------
% Generate the computation VHDL code
%-----------------------------------------------------------------------
v.component = [];    
entity1   = ['fxpt_exp_ext_compute_W' num2str(W) 'F' num2str(F)]; v.entity = entity1;
disp(['Generating VDHL code for : ' entity1]); 
filename1 = [entity1 '.vhd'];
dirpath = [fxpt_math_home_dir '\fxpt_exp_ext\source_code\vhdl\'];
fid = fopen([dirpath filename1],'w');
str = ['-------------------------------------------------------------------']; fprintf(fid,'%s\n',str);
str = ['-- Note: This is machine generated code.  Do not hand edit.']; fprintf(fid,'%s\n',str);
str = ['--       Modify Matlab function ' mfilename '.m instead.']; fprintf(fid,'%s\n',str);
str = ['--       This file was auto generated on ' datestr(now)]; fprintf(fid,'%s\n',str);
str = ['--       This VDHL file computes the extended domain fixed-point exp() function']; fprintf(fid,'%s\n',str);
str = ['-------------------------------------------------------------------']; fprintf(fid,'%s\n',str);
str = ['library ieee;']; fprintf(fid,'%s\n',str);
str = ['use ieee.std_logic_1164.all;']; fprintf(fid,'%s\n',str);
str = ['use ieee.numeric_std.all;']; fprintf(fid,'%s\n\n',str);
str = ['entity ' entity1 ' is']; fprintf(fid,'%s\n',str); v.component = char(v.component,['component ' entity1]);
str = ['   port (']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      clock	: in  std_logic;']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      reset	: in  std_logic;']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      x	    : in  std_logic_vector(' num2str(W-1) ' downto 0);' ]; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      start	: in  std_logic;' ]; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      y     : out std_logic_vector(' num2str(W-1) ' downto 0);   -- y=exp(x)  (extended x domain)']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      done  : out std_logic']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['   );']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['end entity;']; fprintf(fid,'%s\n\n',str); v.component = char(v.component,'end component;');
str = ['architecture rtl of ' entity1 ' is']; fprintf(fid,'%s\n',str);

% insert fxpt_exp_compute_WnFm component declaration  
S = size(v_exp.component);
for i=1:S(1)
   fprintf(fid,'%s\n',[blanks(3) v_exp.component(i,:)]);
end

fprintf(fid,'\n');

W2 = W*2;
F2 = F*2;
I = W-F;
I2 = I*2;
Wstart = W2-I-1;
Wend   = Wstart - W + 1;
Istart = W2-I-1;  
Iend   = Istart - I - 1;
% states for state machine
str = ['   type state_type is (state_wait, state_start, state_c2, state_c3, state_c4, state_c5, state_exp_wait, state_done);']; fprintf(fid,'%s\n',str);
str = ['   signal state : state_type;']; fprintf(fid,'%s\n\n',str);
str = ['   constant log2e           :   signed(' num2str(W-1) ' downto 0) := "' log2e.bin '";  --' log2e.hex]; fprintf(fid,'%s\n',str);
str = ['   constant ln2             :   signed(' num2str(W-1) ' downto 0) := "' ln2.bin '";  --' ln2.hex]; fprintf(fid,'%s\n',str);
str = ['   signal exp_flag_start    :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal exp_flag_done     :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal t1                :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal t1_abs            :   unsigned(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal t1I               :   unsigned(' num2str(W-F-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal t1F               :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal t2                :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal t2_resized        :   std_logic_vector(' num2str(fxptM.exp.W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal t3                :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal t4                :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal y2                :   std_logic_vector(' num2str(fxptM.exp.W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal y2_resized        :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal yo                :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);

str = [' ']; fprintf(fid,'%s\n',str);

str = ['begin']; fprintf(fid,'%s\n\n',str);

% insert exp_compute component port mapping
str = ['  EXP1 : ' v_exp.entity]; fprintf(fid,'%s\n',str);
str = ['     port map (']; fprintf(fid,'%s\n',str);
str = ['        clock    => clock,']; fprintf(fid,'%s\n',str);
str = ['        reset    => reset,']; fprintf(fid,'%s\n',str);
str = ['        x        => t2_resized,']; fprintf(fid,'%s\n',str);
str = ['        start    => exp_flag_start,']; fprintf(fid,'%s\n',str);
str = ['        y        => y2,']; fprintf(fid,'%s\n',str);
str = ['        done     => exp_flag_done']; fprintf(fid,'%s\n',str);
str = ['     );']; fprintf(fid,'%s\n\n',str);

% resize signals
Fdiff = fxptM.exp.F - fxptM.exp_ext.F;
expI = fxptM.exp.W - fxptM.exp.F;
af = fi(0,0,Fdiff,Fdiff);
if Fdiff >= 0
    str = ['   t2_resized <= std_logic_vector( t2(' num2str(fxptM.exp_ext.F+expI-1) ' downto 0) & "' af.bin '" );        -- resize signal to match exp() signal I/O']; fprintf(fid,'%s\n',str);
    str = ['   y2_resized <= resize(signed(y2(' num2str(fxptM.exp.W-1) ' downto ' num2str(Fdiff) ')), y2_resized''length);   -- resize signal to match exp() signal I/O']; fprintf(fid,'%s\n\n',str);
else
   error('this case has not been implemented yet...') 
end

% latch y2=exp(t2) when exp computation completed
str = ['   process (clock)']; fprintf(fid,'%s\n',str);
str = ['   begin']; fprintf(fid,'%s\n',str);
str = ['         if rising_edge(clock) and exp_flag_done = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['               t3 <= y2_resized;           -- grab t3=exp(t2) result ']; fprintf(fid,'%s\n\n',str);
str = ['         end if;']; fprintf(fid,'%s\n',str);
str = ['   end process;']; fprintf(fid,'%s\n\n',str);

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
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_start =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_c2;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c2 =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_c3;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c3 =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_c4;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c4 =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_c5;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c5 =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_exp_wait;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_exp_wait =>']; fprintf(fid,'%s\n',str);
str = ['                           if exp_flag_done = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_done;']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_exp_wait;']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_done =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_wait;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
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
str = ['      variable t1v   :   signed(' num2str(2*W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['      variable t2v   :   signed(' num2str(2*W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   begin']; fprintf(fid,'%s\n',str);
str = ['         if (rising_edge(clock)) then']; fprintf(fid,'%s\n',str);
str = ['               done               <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['               exp_flag_start     <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['               case state is']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_wait => ']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_start =>']; fprintf(fid,'%s\n',str);
str = ['                           t1v := signed(x)*log2e;']; fprintf(fid,'%s\n',str);
str = ['                           t1 <= t1v( ' num2str(Wstart) ' downto ' num2str(Wend) ');']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c2 =>']; fprintf(fid,'%s\n',str);
str = ['                           if t1(' num2str(W-1) ') = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                                 t1_abs <= not(unsigned(t1)) + 1;']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 t1_abs <= unsigned(t1);']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c3 =>']; fprintf(fid,'%s\n',str);
str = ['                           t1I <= t1_abs(' num2str(W-1) ' downto ' num2str(F) ');   -- Integer bits ']; fprintf(fid,'%s\n',str);
str = ['                           if t1(' num2str(W-1) ') = ''0'' then']; fprintf(fid,'%s\n',str);
str = ['                                 t1F <= signed("' repmat('0',1,W-F) '" & t1_abs('  num2str(F-1) ' downto 0));    -- Fractional bits']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 t1F <= signed(not("' repmat('0',1,W-F) '" & t1_abs('  num2str(F-1) ' downto 0))+1);    -- Fractional bits']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c4 =>']; fprintf(fid,'%s\n',str);
str = ['                           t2v := t1F * ln2;']; fprintf(fid,'%s\n',str);
str = ['                           t2 <= t2v( ' num2str(Wstart) ' downto ' num2str(Wend) ');']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c5 =>']; fprintf(fid,'%s\n',str);
str = ['                           exp_flag_start <= ''1'';  -- start y=exp(t2) computation now that -1.24 <= t2 <= 1.56']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_exp_wait =>    -- wait for y=exp(t2) computation to finish']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_done =>']; fprintf(fid,'%s\n',str);
str = ['                           done <= ''1'';        -- signal that the computation is finished.']; fprintf(fid,'%s\n',str);
str = ['                           if t1(' num2str(W-1) ') = ''0'' then']; fprintf(fid,'%s\n',str);
str = ['                                 yo <=  shift_left(t3, to_integer(t1I));']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 yo <=  shift_right(t3, to_integer(t1I));']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when others =>']; fprintf(fid,'%s\n',str);
str = ['               end case;']; fprintf(fid,'%s\n',str);
str = ['         end if;']; fprintf(fid,'%s\n',str);
str = ['   end process;']; fprintf(fid,'%s\n',str);
str = ['   y <= std_logic_vector(yo);']; fprintf(fid,'%s\n\n',str);



str = ['end rtl;']; fprintf(fid,'%s\n',str);
    
fclose(fid);


