function fxpt_power_vhdl_code_gen()
global fxpt_math_home_dir;   % NOTE: run \fxpt_math\setup.m to setup global dir, paths, and word length W and fraction length F
global fxptM;
W = fxptM.power.W;
F = fxptM.power.F;



%if ((0.21 <= xi) & (xi <= 3.46))
    
    % use the precision passed in
%     W    = 32;                   % Number of bits in word
%     F    = 25;
%     F    = xi.FractionLength;               % Number of bits in Fraction field
%     Sign = xi.Signedness;                   % Get sign ('Signed' or 'Unsigned')
%     S    = double(strcmp(Sign,'Signed'));   % S=1 if signed, S=0 if unsigned
     S = 1;  % force unsigned since xi must be positive
     I    = W-F-S;                           % Number of bits in Integer field
%     
%     %-------------------------------------------------------------------
%     % Setup local fimath properties
%     %-------------------------------------------------------------------
%     Fm = fimath('ProductMode','SpecifyPrecision',...
%         'ProductWordLength',W,...
%         'ProductFractionLength',F,...
%         'SumMode','SpecifyPrecision',...
%         'SumWordLength',W,...
%         'SumFractionLength',F);
%
%     % create fixed-point objects
%     x0 = fi(double(xi),S,W+S,F,Fm);  % X0
%     y0 = fi(0,S,W+S,F,Fm);  % Y0
%     xd(1) = x0;
%     yd(1) = y0;
%
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


ln2_n   = fi(-log(2),S,W,F,Fm);

%-----------------------------------------------------------------------
% Generate component VHDL code
%-----------------------------------------------------------------------
v_lzc     = fxpt_lzc_code_gen(W);
v_exp_ext = fxpt_exp_ext_vhdl_code_gen();
v_log     = fxpt_log_vhdl_code_gen();  

%-----------------------------------------------------------------------
% Generate the computation VHDL code
%-----------------------------------------------------------------------
entity1   = ['fxpt_power_compute_W' num2str(W) 'F' num2str(F)];
filename1 = [entity1 '.vhd'];
dirpath = [fxpt_math_home_dir '\fxpt_power\source_code\vhdl\'];
fid = fopen([dirpath filename1],'w');
disp(['Generating VDHL code for : ' entity1]); 
str = ['-------------------------------------------------------------------']; fprintf(fid,'%s\n',str);
str = ['-- Note: This is machine generated code.  Do not hand edit.']; fprintf(fid,'%s\n',str);
str = ['--       Modify Matlab function ' mfilename '.m instead.']; fprintf(fid,'%s\n',str);
str = ['--       This file was auto generated on ' datestr(now)]; fprintf(fid,'%s\n',str);
str = ['--       This VDHL file computes the fixed-point power function w = power(x,y) = x^y']; fprintf(fid,'%s\n',str);
str = ['-------------------------------------------------------------------']; fprintf(fid,'%s\n',str);
str = ['library ieee;']; fprintf(fid,'%s\n',str);
str = ['use ieee.std_logic_1164.all;']; fprintf(fid,'%s\n',str);
str = ['use ieee.numeric_std.all;']; fprintf(fid,'%s\n\n',str);
str = ['entity ' entity1 ' is']; fprintf(fid,'%s\n',str);
str = ['   port (']; fprintf(fid,'%s\n',str);
str = ['      clock	: in  std_logic;']; fprintf(fid,'%s\n',str);
str = ['      reset	: in  std_logic;']; fprintf(fid,'%s\n',str);
str = ['      x	    : in  std_logic_vector(' num2str(W-1) ' downto 0);   -- x in: w = power(x,y) = x^y']; fprintf(fid,'%s\n',str);
str = ['      y	    : in  std_logic_vector(' num2str(W-1) ' downto 0);   -- y in: w = power(x,y) = x^y']; fprintf(fid,'%s\n',str);
str = ['      start	: in  std_logic;   -- start computation (set to ''1'' for one clock period)']; fprintf(fid,'%s\n',str);
str = ['      w     : out std_logic_vector(' num2str(W-1) ' downto 0);   -- w in: w = power(x,y) = x^y']; fprintf(fid,'%s\n',str);
str = ['      done  : out std_logic    -- computation is done (set to ''1'' for one clock period)']; fprintf(fid,'%s\n',str);
str = ['   );']; fprintf(fid,'%s\n',str);
str = ['end entity;']; fprintf(fid,'%s\n\n',str);
str = ['architecture rtl of ' entity1 ' is']; fprintf(fid,'%s\n',str);

% insert fxpt_lzc_Wn component declaration  
S = size(v_lzc.component);
for i=1:S(1)
   fprintf(fid,'%s\n',[blanks(3) v_lzc.component(i,:)]);
end

% insert fxpt_exp_compute_WnFm component declaration  
S = size(v_exp_ext.component);
for i=1:S(1)
   fprintf(fid,'%s\n',[blanks(3) v_exp_ext.component(i,:)]);
end

% insert fxpt_log_compute_Wn component declaration  
S = size(v_log.component);
for i=1:S(1)
   fprintf(fid,'%s\n',[blanks(3) v_log.component(i,:)]);
end

fprintf(fid,'\n');


% states for state machine
str = ['   type state_type is (state_wait, state_start, state_lzc, state_xshift_amount, state_xshifted, state_LOG_start, state_LOG_wait, state_c1, state_EXP1_start, state_EXP1_wait, state_c2, state_EXP2_start, state_EXP2_wait, state_c3, state_done);']; fprintf(fid,'%s\n',str);
str = ['   signal state : state_type;']; fprintf(fid,'%s\n\n',str);
str = ['   signal vlzc_count         :   std_logic_vector(' num2str(v_lzc.Nbisects-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal lzc_count          :   signed(' num2str(v_lzc.Nbisects) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal shiftx_amount     :   signed(' num2str(v_lzc.Nbisects) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal xcaptured         :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal ycaptured         :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal xshifted          :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal xshifted_resized  :   std_logic_vector(' num2str(fxptM.log.W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal ylnxhat           :   std_logic_vector(' num2str(fxptM.log.W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal ylnxhat_resized   :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal lnxhat            :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal lnxy              :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal yt1               :   std_logic_vector(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal t1                :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal yt2               :   std_logic_vector(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal t2                :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal t3                :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal yhat              :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal wo                :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);

str = ['   signal flag_LOG_start    :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal flag_LOG_done     :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal flag_EXP1_start   :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal flag_EXP1_done    :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal flag_EXP2_start   :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal flag_EXP2_done    :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   constant ln2_n           :   signed(' num2str(W-1) ' downto 0) := "' ln2_n.bin '";']; fprintf(fid,'%s\n',str);

str = [' ']; fprintf(fid,'%s\n',str);

str = ['begin']; fprintf(fid,'%s\n\n',str);

% insert lzc component port mapping
str = ['  LZC1 : ' v_lzc.entity]; fprintf(fid,'%s\n',str);
str = ['     port map (']; fprintf(fid,'%s\n',str);
str = ['        clock      => clock,']; fprintf(fid,'%s\n',str);
str = ['        lzc_vector => std_logic_vector(xcaptured),']; fprintf(fid,'%s\n',str);
str = ['        lzc_count  => vlzc_count']; fprintf(fid,'%s\n',str);
str = ['     );']; fprintf(fid,'%s\n',str);
str = ['  lzc_count <= signed(''0'' & vlzc_count);  -- count is positive so sign extend with zero']; fprintf(fid,'%s\n\n',str);

% insert EXP1 component port mapping
str = ['  EXP1 : ' v_exp_ext.entity]; fprintf(fid,'%s\n',str);
str = ['     port map (']; fprintf(fid,'%s\n',str);
str = ['        clock    => clock,']; fprintf(fid,'%s\n',str);
str = ['        reset    => reset,']; fprintf(fid,'%s\n',str);
str = ['        x        => std_logic_vector(lnxy),']; fprintf(fid,'%s\n',str);
str = ['        start    => flag_EXP1_start,']; fprintf(fid,'%s\n',str);
str = ['        y        => yt1,']; fprintf(fid,'%s\n',str);
str = ['        done     => flag_EXP1_done']; fprintf(fid,'%s\n',str);
str = ['     );']; fprintf(fid,'%s\n\n',str);

% latch t1=exp_ext(lnxy) when exp computation completed
str = ['   process (clock)']; fprintf(fid,'%s\n',str);
str = ['   begin']; fprintf(fid,'%s\n',str);
str = ['         if rising_edge(clock) and flag_EXP1_done = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['               t1 <= signed(yt1);           -- grab t1=exp_ext(lnxy) result ']; fprintf(fid,'%s\n',str);
str = ['         end if;']; fprintf(fid,'%s\n',str);
str = ['   end process;']; fprintf(fid,'%s\n\n',str);


% insert EXP2 component port mapping
str = ['  EXP2 : ' v_exp_ext.entity]; fprintf(fid,'%s\n',str);
str = ['     port map (']; fprintf(fid,'%s\n',str);
str = ['        clock    => clock,']; fprintf(fid,'%s\n',str);
str = ['        reset    => reset,']; fprintf(fid,'%s\n',str);
str = ['        x        => std_logic_vector(yhat),']; fprintf(fid,'%s\n',str);
str = ['        start    => flag_EXP2_start,']; fprintf(fid,'%s\n',str);
str = ['        y        => yt2,']; fprintf(fid,'%s\n',str);
str = ['        done     => flag_EXP2_done']; fprintf(fid,'%s\n',str);
str = ['     );']; fprintf(fid,'%s\n\n',str);

% latch t2=exp_ext(yhat) when exp computation completed
str = ['   process (clock)']; fprintf(fid,'%s\n',str);
str = ['   begin']; fprintf(fid,'%s\n',str);
str = ['         if rising_edge(clock) and flag_EXP2_done = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['               t2 <= signed(yt2);           -- grab t2=exp_ext(yhat) result ']; fprintf(fid,'%s\n',str);
str = ['         end if;']; fprintf(fid,'%s\n',str);
str = ['   end process;']; fprintf(fid,'%s\n\n',str);

% insert LOG1 component port mapping
str = ['  LOG1 : ' v_log.entity]; fprintf(fid,'%s\n',str);
str = ['     port map (']; fprintf(fid,'%s\n',str);
str = ['        clock    => clock,']; fprintf(fid,'%s\n',str);
str = ['        reset    => reset,']; fprintf(fid,'%s\n',str);
str = ['        x        => xshifted_resized,']; fprintf(fid,'%s\n',str);
str = ['        start    => flag_LOG_start,']; fprintf(fid,'%s\n',str);
str = ['        y        => ylnxhat,']; fprintf(fid,'%s\n',str);
str = ['        done     => flag_LOG_done']; fprintf(fid,'%s\n',str);
str = ['     );']; fprintf(fid,'%s\n\n',str);

% resize signals
Fdiff = fxptM.log.F - fxptM.power.F;
logI = fxptM.log.W - fxptM.log.F;
af = fi(0,0,Fdiff,Fdiff);
if Fdiff >= 0
    str = ['   xshifted_resized <= std_logic_vector( xshifted(' num2str(fxptM.power.F+logI-1) ' downto 0) & "' af.bin '" );        -- resize signal to match exp() signal I/O']; fprintf(fid,'%s\n',str);
    str = ['   ylnxhat_resized <= resize(signed(ylnxhat(' num2str(fxptM.log.W-1) ' downto ' num2str(Fdiff) ')), ylnxhat_resized''length);   -- resize signal to match exp() signal I/O']; fprintf(fid,'%s\n\n',str);
else
   error('this case has not been implemented yet...') 
end

% latch lnxhat=log(xshifted) when exp computation completed
str = ['   process (clock)']; fprintf(fid,'%s\n',str);
str = ['   begin']; fprintf(fid,'%s\n',str);
str = ['         if rising_edge(clock) and flag_LOG_done = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['               lnxhat <= ylnxhat_resized;           -- grab lnxhat=log(xshifted) result ']; fprintf(fid,'%s\n',str);
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
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_wait =>']; fprintf(fid,'%s\n',str);
str = ['                           if start = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_start;']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_wait;']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_start =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_lzc;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_lzc =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_xshift_amount;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_xshift_amount =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_xshifted;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_xshifted =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_LOG_start;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_LOG_start =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_LOG_wait;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_LOG_wait =>']; fprintf(fid,'%s\n',str);
str = ['                           if flag_LOG_done = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_c1;']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_LOG_wait;']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c1 =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_EXP1_start;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_EXP1_start =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_c2;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c2 =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_EXP2_start;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_EXP2_start =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_EXP2_wait;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_EXP2_wait =>']; fprintf(fid,'%s\n',str);
str = ['                           if flag_EXP2_done = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_c3;']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_EXP2_wait;']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c3 =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_done;']; fprintf(fid,'%s\n',str);
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
Nbisects = v_lzc.Nbisects;
WNbisects = W + Nbisects;
% insert computation process 
str = ['   -- Perform Computations that are state dependent']; fprintf(fid,'%s\n',str);
str = ['   compute : process (clock)']; fprintf(fid,'%s\n',str);
str = ['        variable lnxyv   :   signed(' num2str(2*W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['        variable t3v     :   signed(' num2str(2*W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['        variable yhatv   :   signed(' num2str(WNbisects) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['        variable wov     :   signed(' num2str(2*W-1) ' downto 0);']; fprintf(fid,'%s\n',str);

str = ['   begin']; fprintf(fid,'%s\n',str);
str = ['         if (rising_edge(clock)) then']; fprintf(fid,'%s\n',str);
str = ['               done              <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['               flag_LOG_start    <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['               flag_EXP1_start   <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['               flag_EXP2_start   <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['               case state is']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_wait => ']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_start =>']; fprintf(fid,'%s\n',str);
str = ['                           xcaptured <= signed(x);']; fprintf(fid,'%s\n',str);
str = ['                           ycaptured <= signed(y);']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_lzc =>        -- determine leading zero count in xcaptured']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_xshift_amount =>']; fprintf(fid,'%s\n',str);
str = ['                           shiftx_amount <= lzc_count - ' num2str(W-F) ';  -- the number of bits to shift the leading 1 of x to the 2^-1=0.5 location']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_xshifted =>']; fprintf(fid,'%s\n',str);
str = ['                           if shiftx_amount(' num2str(v_lzc.Nbisects) ') = ''0'' then']; fprintf(fid,'%s\n',str);
str = ['                                 xshifted <= shift_left(xcaptured, to_integer(shiftx_amount));']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 xshifted <= shift_right(xcaptured, to_integer(not(unsigned(shiftx_amount))+1));   -- convert negative shiftx_amount to positive and shift right']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_LOG_start =>     -- start lnxhat=log(xshifted)']; fprintf(fid,'%s\n',str);
str = ['                           flag_LOG_start <= ''1'';']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_LOG_wait =>']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c1 =>']; fprintf(fid,'%s\n',str);
str = ['                           lnxyv := ycaptured * lnxhat;']; fprintf(fid,'%s\n',str);
str = ['                           lnxy  <= lnxyv(' num2str(Wstart) ' downto ' num2str(Wend) ');']; fprintf(fid,'%s\n',str);
str = ['                           t3v   := ycaptured * ln2_n;']; fprintf(fid,'%s\n',str);
str = ['                           t3    <= t3v(' num2str(Wstart) ' downto ' num2str(Wend) ');']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_EXP1_start =>   --  start t1=exp_ext(lnxy)']; fprintf(fid,'%s\n',str);
str = ['                           flag_EXP1_start <= ''1'';']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c2 =>']; fprintf(fid,'%s\n',str);
str = ['                           yhatv := t3*shiftx_amount;']; fprintf(fid,'%s\n',str);
str = ['                           yhat  <= yhatv(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_EXP2_start =>   --  start t2=exp_ext(yhat)']; fprintf(fid,'%s\n',str);
str = ['                           flag_EXP2_start <= ''1'';']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_EXP2_wait =>   -- wait for t2=exp(yhat) result (Note: t1=exp_ext(lnxy) will also be completed)']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_c3 =>']; fprintf(fid,'%s\n',str);
str = ['                           wov := t1*t2;']; fprintf(fid,'%s\n',str);
str = ['                           wo  <= wov(' num2str(Wstart) ' downto ' num2str(Wend) ');']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_done =>']; fprintf(fid,'%s\n',str);
str = ['                           done <= ''1'';']; fprintf(fid,'%s\n',str);

str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when others =>']; fprintf(fid,'%s\n',str);

str = ['               end case;']; fprintf(fid,'%s\n',str);
str = ['         end if;']; fprintf(fid,'%s\n',str);
str = ['   end process;']; fprintf(fid,'%s\n',str);
str = ['   w <= std_logic_vector(wo);']; fprintf(fid,'%s\n\n',str);

str = ['end rtl;']; fprintf(fid,'%s\n',str);
    
fclose(fid);


