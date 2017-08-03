function v=fxpt_exp_vhdl_code_gen()
global fxpt_math_home_dir;    % NOTE: run \fxpt_math\setup.m to setup global dir and paths and word length W and fraction length F
global fxptM;
W = fxptM.exp.W;
F = fxptM.exp.F;

% Domain of y=exp(x):   -1.24 <= x <= 1.56

S=1;
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
%
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
for i=0:F+1
    bp(i+1)   = fi(1+2^(-i),S,W,F,Fm);
    bn(i+1)   = fi(1-2^(-i),S,W,F,Fm);
    lnbp(i+1) = fi(log(1+2^(-i)),S,W,F,Fm);
    if i==0
        lnbn(i+1) = fi(0,S,W,F,Fm);  % undefined case for log(0)=-inf so set to zero when i=0 (we won't use this case...)
    else
        lnbn(i+1) = fi(log(1-2^(-i)),S,W,F,Fm);
    end
end

AW = ceil(log2(W));

%-----------------------------------------------------------------------
% Generate ROM VHDL code for the b and lnb coefficients
%-----------------------------------------------------------------------
v_ROM_bp   = fxpt_exp_vhdl_code_gen_ROM_bp_coef(bp);
v_ROM_bn   = fxpt_exp_vhdl_code_gen_ROM_bn_coef(bn);
v_ROM_lnbp = fxpt_exp_vhdl_code_gen_ROM_lnbp_coef(lnbp);
v_ROM_lnbn = fxpt_exp_vhdl_code_gen_ROM_lnbn_coef(lnbn);

%-----------------------------------------------------------------------
% Generate the computation VHDL code
%-----------------------------------------------------------------------
v.component = [];    
entity1   = ['fxpt_exp_compute_W' num2str(W) 'F' num2str(F)]; v.entity = entity1;
disp(['Generating VDHL code for : ' entity1]); 
filename1 = [entity1 '.vhd'];
dirpath = [fxpt_math_home_dir '\fxpt_exp\source_code\vhdl\'];
fid = fopen([dirpath filename1],'w');
str = ['-------------------------------------------------------------------']; fprintf(fid,'%s\n',str);
str = ['-- Note: This is machine generated code.  Do not hand edit.']; fprintf(fid,'%s\n',str);
str = ['--       Modify Matlab function ' mfilename '.m instead.']; fprintf(fid,'%s\n',str);
str = ['--       This file was auto generated on ' datestr(now)]; fprintf(fid,'%s\n',str);
str = ['--       This VDHL file computes the fixed-point exp() function']; fprintf(fid,'%s\n',str);
str = ['--       using additive two-sided normalization.']; fprintf(fid,'%s\n',str);
str = ['--       This function expects an x domain in y=exp(x) of -1.24 <= x <= 1.56.']; fprintf(fid,'%s\n',str);
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
str = ['      y     : out std_logic_vector(' num2str(W-1) ' downto 0);   -- y=exp(x)  -1.24 <= x <= 1.56']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['      done  : out std_logic']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['   );']; fprintf(fid,'%s\n',str); v.component = char(v.component,str);
str = ['end entity;']; fprintf(fid,'%s\n\n',str); v.component = char(v.component,'end component;');
str = ['architecture rtl of ' entity1 ' is']; fprintf(fid,'%s\n',str);

% insert ROM bp component declaration
S = size(v_ROM_bp.component);
for i=1:S(1)
   fprintf(fid,'%s\n',[blanks(3) v_ROM_bp.component(i,:)]);
end

% insert ROM bn component declaration
S = size(v_ROM_bn.component);
for i=1:S(1)
   fprintf(fid,'%s\n',[blanks(3) v_ROM_bn.component(i,:)]);
end

% insert ROM lnbp component declaration
S = size(v_ROM_lnbp.component);
for i=1:S(1)
   fprintf(fid,'%s\n',[blanks(3) v_ROM_lnbp.component(i,:)]);
end

% insert ROM lnbn component declaration
S = size(v_ROM_lnbn.component);
for i=1:S(1)
   fprintf(fid,'%s\n',[blanks(3) v_ROM_lnbn.component(i,:)]);
end

fprintf(fid,'\n');

% states for state machine
str = ['   type state_type is (state_wait, state_start, state_start_diff, state_start_abs, state_start_update, state_compute_start, state_compute_diff, state_compute_abs, state_compute_abs_diff, state_compute_update, state_done);']; fprintf(fid,'%s\n',str);
str = ['   signal state : state_type;']; fprintf(fid,'%s\n\n',str);
str = ['   signal xi                  :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal yi                  :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal yp                  :   signed(' num2str(2*W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal yn                  :   signed(' num2str(2*W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal bp_coef             :   std_logic_vector(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal bn_coef             :   std_logic_vector(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal lnbp_coef           :   std_logic_vector(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal lnbn_coef           :   std_logic_vector(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal bp_coef_z1          :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal bn_coef_z1          :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal lnbp_coef_z1        :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal lnbn_coef_z1        :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal Dp                  :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal Dn                  :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal Dz                  :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal Dp_abs              :   unsigned(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal Dn_abs              :   unsigned(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal Dz_abs              :   unsigned(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal Snz                 :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal Snp                 :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal Szp                 :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal step_counter        :   unsigned(' num2str(AW+1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal flag_done           :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal flag_zero_counter   :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal flag_counter_enable :   std_logic;']; fprintf(fid,'%s\n',str);
str = ['   signal x0                  :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
str = ['   signal y0                  :   signed(' num2str(W-1) ' downto 0);']; fprintf(fid,'%s\n',str);
count_threshold = F-2;
%count_threshold = F+2;
b = fi(count_threshold,0,AW+2,0);
str = ['   constant count' num2str(count_threshold) '  :   unsigned(' num2str(AW+1) ' downto 0) := "' b.bin  '";']; fprintf(fid,'%s\n',str);
str = [' ']; fprintf(fid,'%s\n',str);


str = ['begin']; fprintf(fid,'%s\n\n',str);

% insert ROM bp component port mapping
str = ['  ROM1 : ' v_ROM_bp.entity]; fprintf(fid,'%s\n',str);
str = ['     port map (']; fprintf(fid,'%s\n',str);
str = ['        clock    => clock,']; fprintf(fid,'%s\n',str);
str = ['        address  => std_logic_vector(step_counter(' num2str(AW-1) ' downto 0)),']; fprintf(fid,'%s\n',str);
str = ['        bp_coef   => bp_coef']; fprintf(fid,'%s\n',str);
str = ['     );']; fprintf(fid,'%s\n\n',str);

% insert ROM bn component port mapping
str = ['  ROM2 : ' v_ROM_bn.entity]; fprintf(fid,'%s\n',str);
str = ['     port map (']; fprintf(fid,'%s\n',str);
str = ['        clock    => clock,']; fprintf(fid,'%s\n',str);
str = ['        address  => std_logic_vector(step_counter(' num2str(AW-1) ' downto 0)),']; fprintf(fid,'%s\n',str);
str = ['        bn_coef   => bn_coef']; fprintf(fid,'%s\n',str);
str = ['     );']; fprintf(fid,'%s\n\n',str);


% insert ROM b component port mapping
str = ['  ROM3 : ' v_ROM_lnbp.entity]; fprintf(fid,'%s\n',str);
str = ['     port map (']; fprintf(fid,'%s\n',str);
str = ['        clock    => clock,']; fprintf(fid,'%s\n',str);
str = ['        address  => std_logic_vector(step_counter(' num2str(AW-1) ' downto 0)),']; fprintf(fid,'%s\n',str);
str = ['        lnbp_coef => lnbp_coef']; fprintf(fid,'%s\n',str);
str = ['     );']; fprintf(fid,'%s\n\n',str);

% insert ROM b component port mapping
str = ['  ROM4 : ' v_ROM_lnbn.entity]; fprintf(fid,'%s\n',str);
str = ['     port map (']; fprintf(fid,'%s\n',str);
str = ['        clock    => clock,']; fprintf(fid,'%s\n',str);
str = ['        address  => std_logic_vector(step_counter(' num2str(AW-1) ' downto 0)),']; fprintf(fid,'%s\n',str);
str = ['        lnbn_coef => lnbn_coef']; fprintf(fid,'%s\n',str);
str = ['     );']; fprintf(fid,'%s\n\n',str);

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
str = ['                           state <= state_start_diff;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_start_diff =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_start_abs;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_start_abs =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_start_update;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_start_update =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_compute_start;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_compute_start =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_compute_diff;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_compute_diff =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_compute_abs;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_compute_abs =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_compute_abs_diff;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_compute_abs_diff =>']; fprintf(fid,'%s\n',str);
str = ['                           state <= state_compute_update;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);
str = ['                     when state_compute_update =>']; fprintf(fid,'%s\n',str);
str = ['                           if flag_done = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_done;']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 state <= state_compute_start;']; fprintf(fid,'%s\n',str);
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
str = ['      variable Scat : std_logic_vector(2 downto 0);']; fprintf(fid,'%s\n',str);
str = ['      variable vp   :   signed(' num2str(2*W-1) ' downto 0);']; fprintf(fid,'%s\n',str);

str = ['   begin']; fprintf(fid,'%s\n',str);
str = ['         if (rising_edge(clock)) then']; fprintf(fid,'%s\n',str);
str = ['               done                <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['               flag_zero_counter   <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['               flag_counter_enable <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['               y                   <= (others => ''0'');']; fprintf(fid,'%s\n',str);
str = ['               case state is']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);

str = ['                     when state_wait => ']; fprintf(fid,'%s\n',str);
str = ['                           flag_zero_counter <= ''1'';']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);

str = ['                     when state_start =>']; fprintf(fid,'%s\n',str);
str = ['                           x0                  <= signed(x);  -- x0=x']; fprintf(fid,'%s\n',str);
a = fi(1.0,1,W,F,Fm);  % y0=1 (signed)
str = ['                           y0                  <= "' a.bin '";  -- y0=1']; fprintf(fid,'%s\n',str);
str = ['                           bp_coef_z1          <= signed(bp_coef);']; fprintf(fid,'%s\n',str);
str = ['                           bn_coef_z1          <= signed(bn_coef);']; fprintf(fid,'%s\n',str);
str = ['                           lnbp_coef_z1        <= signed(lnbp_coef);']; fprintf(fid,'%s\n',str);
str = ['                           lnbn_coef_z1        <= signed(lnbn_coef);']; fprintf(fid,'%s\n',str);
str = ['                           flag_counter_enable <= ''1'';']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);

str = ['                     when state_start_diff =>']; fprintf(fid,'%s\n',str);
str = ['                           Dp <= x0 - lnbp_coef_z1;']; fprintf(fid,'%s\n',str);
str = ['                           Dn <= (others => ''0'');          -- zero since we have to ignore the undefined case at i=0']; fprintf(fid,'%s\n',str);
str = ['                           Dz <= signed(x);']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);

str = ['                     when state_start_abs =>']; fprintf(fid,'%s\n',str);
str = ['                           if Dp(' num2str(W-1) ') = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                                 Dp_abs <= not(unsigned(Dp)) + 1;']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 Dp_abs <= unsigned(Dp);']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['                           Dn_abs <= (others => ''0'');          -- zero since we have to ignore the undefined case at i=0']; fprintf(fid,'%s\n',str);
str = ['                           if Dz(' num2str(W-1) ') = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                                 Dz_abs <= not(unsigned(Dz)) + 1;          -- zero since we have to ignore the undefined case at i=0']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 Dz_abs <= unsigned(Dz);']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);

str = ['                     when state_start_update =>']; fprintf(fid,'%s\n',str);
str = ['                           if Dz_abs < Dp_abs then    -- Note: Dn is not checked for i=0 since it is undefined']; fprintf(fid,'%s\n',str);
str = ['                                 xi <= Dz;']; fprintf(fid,'%s\n',str);
str = ['                                 yi <= y0;         -- yi starts with y0=0']; fprintf(fid,'%s\n',str);
str = ['                           else ']; fprintf(fid,'%s\n',str);
str = ['                                 xi <= Dp; -- just keep current xi']; fprintf(fid,'%s\n',str);
str = ['                                 vp := y0 * bp_coef_z1;']; fprintf(fid,'%s\n',str);
str = ['                                 yi <= vp( ' num2str(Wstart) ' downto ' num2str(Wend) '); -- first product P = Y0 * (1+2^(-i))  (i=0)']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);

str = ['                     when state_compute_start =>']; fprintf(fid,'%s\n',str);
str = ['                           bp_coef_z1          <= signed(bp_coef);']; fprintf(fid,'%s\n',str);
str = ['                           bn_coef_z1          <= signed(bn_coef);']; fprintf(fid,'%s\n',str);
str = ['                           lnbp_coef_z1        <= signed(lnbp_coef);']; fprintf(fid,'%s\n',str);
str = ['                           lnbn_coef_z1        <= signed(lnbn_coef);']; fprintf(fid,'%s\n',str);
str = ['                           flag_counter_enable <= ''1'';']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);

str = ['                     when state_compute_diff =>']; fprintf(fid,'%s\n',str);
str = ['                           Dp <= xi - lnbp_coef_z1;']; fprintf(fid,'%s\n',str);
str = ['                           Dn <= xi - lnbn_coef_z1;']; fprintf(fid,'%s\n',str);
str = ['                           Dz <= xi;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);

str = ['                     when state_compute_abs =>']; fprintf(fid,'%s\n',str);
str = ['                           if Dp(' num2str(W-1) ') = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                                 Dp_abs <= not(unsigned(Dp)) + 1;']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 Dp_abs <= unsigned(Dp);']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['                           if Dn(' num2str(W-1) ') = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                                 Dn_abs <= not(unsigned(Dn)) + 1;']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 Dn_abs <= unsigned(Dn);']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['                           if Dz(' num2str(W-1) ') = ''1'' then']; fprintf(fid,'%s\n',str);
str = ['                                 Dz_abs <= not(unsigned(Dz)) + 1;']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 Dz_abs <= unsigned(Dz);']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);

str = ['                     when state_compute_abs_diff =>      -- Parallel Compares and Products']; fprintf(fid,'%s\n',str);
str = ['                           if Dn_abs < Dz_abs then       -- Check Dn_abs < Dz_abs']; fprintf(fid,'%s\n',str);
str = ['                                 Snz <= ''1'';']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 Snz <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['                           if Dn_abs < Dp_abs then       -- Check Dn_abs < Dp_abs']; fprintf(fid,'%s\n',str);
str = ['                                 Snp <= ''1'';']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 Snp <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['                           if Dz_abs < Dp_abs then       -- Check Dz_abs < Dp_abs']; fprintf(fid,'%s\n',str);
str = ['                                 Szp <= ''1'';']; fprintf(fid,'%s\n',str);
str = ['                           else']; fprintf(fid,'%s\n',str);
str = ['                                 Szp <= ''0'';']; fprintf(fid,'%s\n',str);
str = ['                           end if;']; fprintf(fid,'%s\n',str);
str = ['                           yp <= yi * bp_coef_z1;   -- Y update for positive case']; fprintf(fid,'%s\n',str);
str = ['                           yn <= yi * bn_coef_z1;   -- Y update for negative case']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);

str = ['                     when state_compute_update =>']; fprintf(fid,'%s\n',str);
str = ['                           Scat := Snz & Snp & Szp;']; fprintf(fid,'%s\n',str);
str = ['                           case (Scat) is  -- update yi based on which xi operation moved it closest to zero (2-sided update)']; fprintf(fid,'%s\n',str);
str = ['                                 when "111" =>        -- order: Dn < Dz < Dp    ->    Dn closest to zero']; fprintf(fid,'%s\n',str);
str = ['                                       xi <= Dn;']; fprintf(fid,'%s\n',str);
str = ['                                       yi <= yn( ' num2str(Wstart) ' downto ' num2str(Wend) ');']; fprintf(fid,'%s\n',str);
str = ['                                 when "110" =>        -- order: Dn < Dp < Dz    ->    Dn closest to zero']; fprintf(fid,'%s\n',str);
str = ['                                       xi <= Dn;']; fprintf(fid,'%s\n',str);
str = ['                                       yi <= yn( ' num2str(Wstart) ' downto ' num2str(Wend) ');']; fprintf(fid,'%s\n',str);
str = ['                                 when "011" =>        -- order: Dz < Dn < Dp      ->  Dz closest to zero']; fprintf(fid,'%s\n',str);
str = ['                                       xi <= Dz;']; fprintf(fid,'%s\n',str);
str = ['                                       yi <= yi;']; fprintf(fid,'%s\n',str);
str = ['                                 when "100" =>        -- order: Dz < Dp < Dn      ->  Dz closest to zero']; fprintf(fid,'%s\n',str);
str = ['                                       xi <= Dz;']; fprintf(fid,'%s\n',str);
str = ['                                       yi <= yi;']; fprintf(fid,'%s\n',str);
str = ['                                 when "001" =>        -- order: Dp < Dn < Dz    ->    Dp closest to zero']; fprintf(fid,'%s\n',str);
str = ['                                       xi <= Dp;']; fprintf(fid,'%s\n',str);
str = ['                                       yi <= yp( ' num2str(Wstart) ' downto ' num2str(Wend) ');']; fprintf(fid,'%s\n',str);
str = ['                                 when "000" =>        -- order: Dp < Dz < Dn    ->    Dp closest to zero']; fprintf(fid,'%s\n',str);
str = ['                                       xi <= Dp;']; fprintf(fid,'%s\n',str);
str = ['                                       yi <= yp( ' num2str(Wstart) ' downto ' num2str(Wend) ');']; fprintf(fid,'%s\n',str);
str = ['                                 when others =>       -- do nothing']; fprintf(fid,'%s\n',str);
str = ['                           end case;']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);

str = ['                     when state_done =>']; fprintf(fid,'%s\n',str);
str = ['                           done              <= ''1'';      -- signal that the computation is finished.']; fprintf(fid,'%s\n',str);
str = ['                           y                 <= std_logic_vector(yi);']; fprintf(fid,'%s\n\n',str);
str = ['                           flag_zero_counter <= ''1'';']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);

str = ['                     when others =>']; fprintf(fid,'%s\n',str);
str = ['  ']; fprintf(fid,'%s\n',str);

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
str = ['                if step_counter >= count' num2str(count_threshold) ' then ' ]; fprintf(fid,'%s\n',str);
str = ['                      flag_done <= ''1'';']; fprintf(fid,'%s\n',str);
str = ['                end if;']; fprintf(fid,'%s\n',str);
str = ['          end if;']; fprintf(fid,'%s\n',str);
str = ['   end process;']; fprintf(fid,'%s\n\n',str);

str = ['end rtl;']; fprintf(fid,'%s\n',str);
    
fclose(fid);


