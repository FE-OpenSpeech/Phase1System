function y = fxpt_exp_ext(x)
global fxptM;

% domain extended version of y=fxpt_exp_2s(x)

% use the precision passed in
W    = x.WordLength;                   % Number of bits in word
F    = x.FractionLength;               % Number of bits in Fraction field
%S    = double(strcmp(x.Signedness,'Signed'));   % S=1 if signed, S=0 if unsigned
S    = 1;
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


log2e = fi(log2(exp(1)),S,W,F,Fm);
ln2   = fi(log(2),S,W,F,Fm);


% state_start
t1 = x*log2e;  % first step in domain extension

%state_c2
%t1.bin
%get Integer and Fraction part of t1
% t1I = Integer part of t1
% t1F = fractional part of t1
if t1 >= 0
    t1I = t1;
    Istr = t1.bin;
    Istr(W-F+1:end)='0';
    t1I.bin = Istr;
    %Istr
    %t1I = t1I.
    
    t1F = t1;
    Fstr = t1.bin;
    Fstr(1:W-F)='0';
    t1F.bin = Fstr;
else
    t1I = abs(t1);
    Istr = t1I.bin;
    Istr(W-F+1:end)='0';
    t1I.bin = Istr;
    t1I = t1I*(-1);
    
    t1F = abs(t1);
    Fstr = t1F.bin;
    Fstr(1:W-F)='0';
    t1F.bin = Fstr;
    t1F = t1F*(-1);
end
%t1F.hex
% t1I
% t1F


%state_c3
t2 = t1F * ln2;  % fraction part mulitplied by ln(2)
%t2
%t2.hex

% resize t2 word lenghth to match specified exp() word size
t2_resized = fi(t2,S,fxptM.exp.W,fxptM.exp.F);
%t2_resized.hex
%state_c5
t3 = fxpt_exp(t2_resized);  % e^t12   (need two sided exp() since t12 can be negative) 
%t3.hex
% resize t3 word lenghth to change back to specified exp_ext() word size
t3_resized = fi(t3,S,fxptM.exp_ext.W,fxptM.exp_ext.F,Fm);
%t3_resized

%state_done
t4 = fi(2^double(t1I),S,fxptM.exp_ext.W,fxptM.exp_ext.F,Fm);
t4 = t3_resized*t4;  % just perform shift in hardware....
%t4


y = t4;

end

