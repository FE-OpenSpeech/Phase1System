function yfxpt=fxpt_exp(xi)
% Domain of y=exp(x):  -1.24 <= x <= 1.56 
    %persistent b;   % The b coefficients don't need to be recreated each time the function is called.
    %persistent lnb;
    % one sided selection rule
    
if ((-1.24 < xi) && (xi < 1.56))
    
    % use the precision passed in
    W    = xi.WordLength;                   % Number of bits in word
    F    = xi.FractionLength;               % Number of bits in Fraction field
    S= 1;  %Sign = xi.Signedness;                   % Get sign ('Signed' or 'Unsigned')
    %S    = double(strcmp(Sign,'Signed'));   % S=1 if signed, S=0 if unsigned
    I    = W-F-S;                           % Number of bits in Integer field
    
    
    if W-F < 4
       error(['Wordlength (W=' num2str(W) ') must be at least 4 greater than fraction length (F='  num2str(F) ')  i.e. W should be at least ' num2str(F+4)])
    end

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
            lnbn(i+1) = fi(0,S,W,F,Fm);  % undefined case log(0)=-inf so set to zero for i=0 case (we won't use this...)
        else
            lnbn(i+1) = fi(log(1-2^(-i)),S,W,F,Fm);
        end
    end
      
    
    %-------------------------------------------------------------------------
    % Perform the two-side selection rule (see page 167, top paragraph )
    %-------------------------------------------------------------------------
    
    % state_start
    % create fixed-point objects
    x(1) = fi(double(xi),S,W,F,Fm);  % X0 = x
    y(1) = fi(1,S,W,F,Fm);           % Y0 = 1
    si = 1;
   
    % state_start_diff
    Dp = x(1) - lnbp(1);
    %Dn = x(1) + 0; % this case is +inf so don't ever select at i=0 iteration
    Dn = 0; % this case is +inf so don't ever select at i=0 iteration
    Dz = x(1);
     
    % state_start_abs
    Dp_abs = abs(Dp);
    Dn_abs = abs(Dn);
    Dz_abs = abs(Dz);
     
    % state_start_update
    if Dz_abs < Dp_abs % find case that moves x toward zero (Not considering Dn for i=0)
        s(1) = 0;
        x(2) = Dz;
        y(2) = y(1);
    else
        s(1) = 1;
        x(2) = Dp;
        y(2) = y(1)*bp(1);
    end
      
    for i=2:F+2
        
           
        % state_compute_diff
        Dp = x(i) - lnbp(i);
        Dn = x(i) - lnbn(i);
        Dz = x(i);
          
        % state_compute_abs
        Dp_abs = abs(Dp);
        Dn_abs = abs(Dn);
        Dz_abs = abs(Dz);
         
        % state_compute_abs_diff
        yp = y(i)*bp(i);
        yn = y(i)*bn(i);
        yz = y(i);
        if Dn_abs < Dz_abs
            Snz = 1;
        else
            Snz = 0;
        end
        if Dn_abs < Dp_abs
            Snp = 1;
        else
            Snp = 0;
        end
        if Dz_abs < Dp_abs
            Szp = 1;
        else
            Szp = 0;
        end
 
        % state_compute_update
        sp = 1;
        sn = -1;
        sz = 0;
        if abs(Dp) < abs(Dn)  % get min between Dp and Dn
            Di = Dp;
            yi = yp;
            siv = sp;
        else
            Di = Dn;
            yi = yn;
            siv = sn;
        end
        if abs(Di) < abs(Dz)  % get min between Di=min(Dp,Dn) and Dz
            Di = Di;
            yi = yi;
            siv = siv;
        else
            Di = Dz;
            yi = yz;
            siv = sz;
        end
        x(i+1) = Di;
        y(i+1) = yi;
        s(i)   = siv;
 
       
    end
    
    yfxpt = y(F+3);
    
else
    error(['Error: Domain of xi=' num2str(xi) ' out of range [-1.24 1.56] in function fxpt_exp().'])
end





