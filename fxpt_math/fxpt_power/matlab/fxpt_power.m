function wo = fxpt_power(xi,yi)
global fxptM;
% fixed point power function z=x^y
% that is computed using the identity x^y = exp(y*log(x))

% use the precision passed in
Wx    = xi.WordLength;                   % Number of bits in word
Fx    = xi.FractionLength;               % Number of bits in Fraction field
Sx    = double(strcmp(xi.Signedness,'Signed'));   % S=1 if signed, S=0 if unsigned
Ix    = Wx-Fx-Sx;                           % Number of bits in Integer field

Wy    = yi.WordLength;                   % Number of bits in word
Fy    = yi.FractionLength;               % Number of bits in Fraction field
Sy    = double(strcmp(yi.Signedness,'Signed'));   % S=1 if signed, S=0 if unsigned
Iy    = Wy-Fy-Sy;                           % Number of bits in Integer field


%-------------------------------------------------------------------
% Setup local fimath properties
%-------------------------------------------------------------------
Fm = fimath('OverflowAction','Wrap',...
    'RoundingMethod','Floor',...
    'ProductMode','SpecifyPrecision',...
    'ProductWordLength',Wx,...
    'ProductFractionLength',Fx,...
    'SumMode','SpecifyPrecision',...
    'SumWordLength',Wx,...
    'SumFractionLength',Fx);
%

if xi < 0
    error(['The x value in z=fxpt_power(x,y) = x^y must be positive.  The x value entered was ' num2str(xi)  ]);
end

%disp(['xi = ' fxpt2str(xi)])
ln2   = fi(log(2),1,Wx,Fx,Fm);
ln2_n = fi(-log(2),1,Wx,Fx,Fm);

% state_start

% state_lzc
% shift x so that 0.5 <= xhat < 1.0
lzcx = fxpt_lzc(xi);  % leading zero count

%state_xshift_amount
shiftx_amount  = lzcx - (Wx - Fx);

%state_xshifted
xshifted = xi*2^shiftx_amount;

% resize t2 word lenghth to match specified exp() word size
xshifted_resized = fi(xshifted,Sx,fxptM.log.W,fxptM.log.F,Fm);
% state_LOG_start
lnxhat = fxpt_log(xshifted_resized);
% resize lnxhat word lenghth to change back to specified power() word size
lnxhat_resized = fi(lnxhat,Sx,fxptM.power.W,fxptM.power.F,Fm);


%state_c1
lnxy = yi*lnxhat_resized;
t3   = yi*ln2_n;

% state_EXP1_start
t1 = fxpt_exp_ext(lnxy);

%state_c2
yhat = t3*shiftx_amount;

% state_EXP2_start
t2 = fxpt_exp_ext(yhat);

% state_EXP2_wait

%state_c3
wo = t1*t2;

% state_done



end

