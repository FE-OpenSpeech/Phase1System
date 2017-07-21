function [yfxpt]=fxpt_log(xi)
% FXPT_LOG - Computes the Natural Logarithm on the fixed-point data type
% xi.
%
% Syntax:  y = fxpt_log(x)
%
% Inputs:
%    Input1 - A fixed-point object created by the x=fi(V,S,W,F) function
%             from the Fixed-Point Designer Toolbox.  The value V must be in
%             the domain of y=fxpt_log(x) and is restricted to 0.21 <= x <= 3.45
%
%    Fimath properties will be set as:
%             Fm = fimath('OverflowAction','Wrap',...
%                'RoundingMethod','Floor',...
%                'ProductMode','SpecifyPrecision',...
%                'ProductWordLength',W,...
%                'ProductFractionLength',F,...
%                'SumMode','SpecifyPrecision',...
%                'SumWordLength',W,...
%                'SumFractionLength',F);
%
% Outputs:
%    Output1 - Returns the natural log of x (same data type)
% 
%
%
% Examples: 
%    Example 1:  Input = 0.5
%                a=fi(0.5,1,32,30)
%                          a = 0.5
%                          DataTypeMode: Fixed-point: binary point scaling
%                          Signedness: Signed
%                          WordLength: 32
%                          FractionLength: 30
%                 a.bin = 00100000000000000000000000000000    
%                 fxpt2str(a) = 0.100000000000000000000000000000
%
%                 Output = fxpt_log(a)
%                        = -0.6931
%                        = 11010011101000110111101000000000
%                        = -0.101100010111001000011000000000
%
% Matlab R2017a
% Toolbox required: Fixed-Point Designer
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% Author:   Ross Snider, PhD
% Address1: ECE Dept. 610 Cobleigh Hall, Montana State University, Bozeman, MT 59717 
% Address2: Flat Earth Inc. 985 Technology Blvd Bozeman, MT 59718
% Email:    ross.snider@montana.edu
% Website:  http://www.montana.edu/rksnider
% Date:     November 2016; Last revision: 14-Mar-2017
% License:  The MIT License (MIT)  See description of MIT License at the end of this file.
%
%------------------------ BEGINNING OF CODE -------------------------------
if ((0.21 <= xi) & (xi <= 3.46))  % Domain of y=ln(x):  0.21 <= x <= 3.45
    
    % use the precision passed in
    W    = xi.WordLength;                   % Number of bits in word
    F    = xi.FractionLength;               % Number of bits in Fraction field
    Sign = xi.Signedness;                   % Get sign ('Signed' or 'Unsigned')
    S    = double(strcmp(Sign,'Signed'));   % S=1 if signed, S=0 if unsigned
    I    = W-F-S;                           % Number of bits in Integer field
    
    if W-F < 2
       error(['Wordlength (W=' num2str(W) ') must be at least 2 greater than fraction length (F='  num2str(F) ')  i.e. W should be at least ' num2str(F+2)])
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
    
    % create fixed-point objects
    x0 = fi(double(xi),S,W,F,Fm);  % X0
    y0 = fi(0,S,W,F,Fm);  % Y0
    xd(1) = x0;
    yd(1) = y0;
    
    %-----------------------------------------------------------------------
    % Create the bi coefficients and ln(bi) coefficients with F fractional
    % bits of precision (First two columns of Table 9.1 on page 166.)
    % We ignore the last two columns since we will use the one sided
    % selection rule (see paragraph following equation (9.10).
    %-----------------------------------------------------------------------
    for i=0:F+1
        b(i+1) = fi(1+2^(-i),S,W,F);          %disp(['b(' num2str(i+1,'% 2d') ') = ' fxpt2str(b(i+1))])
        lnb(i+1) = fi(log(1+2^(-i)),S,W,F);   %disp(['lnb(' num2str(i+1,'% 2d') ') = ' fxpt2str(lnb(i+1))])
    end
        
    %-------------------------------------------------------------------------
    % Perform the one-side selection rule (see page 165, paragraph following
    % equation 9.10)
    %-------------------------------------------------------------------------
    P = x0 * b(1); % first product D = X0 * (1+2^(-i))  (i=0)
    x = x0;
    y = y0;
    a=b(1);
    %disp(['i=' num2str(i,'%02d') ' xi=' fxpt2str(x) ' yi=' fxpt2str(y)  ' P=' fxpt2str(P)  ' bi=' fxpt2str(a)])
    for i=1:F+2
        if P <= 1 % if product is less than 1
            x2 = P;            % x(i+1) is set to the product P
            y2 = y - lnb(i);
            si = 1;
        else % difference is negative so do nothing but make assignments
            x2 = x;
            y2 = y;
            si = 0;
        end
        xd(i+1) = x2;  % save values for display
        yd(i+1) = y2;
        sd(i)   = si;
        % perform updates and get new product
        if i < F+2
            x = x2;
            y = y2;
            P = x * b(i+1);
            a=b(i+1);
            %disp(['i=' num2str(i,'%02d') ' xi=' fxpt2str(x) ' yi=' fxpt2str(y)  ' P=' fxpt2str(P)  ' bi=' fxpt2str(a)])
            %pause
        end
    end
    
    yfxpt = yd(F+1);
    
else
    error(['Error: Domain of x0 (x=' num2str(xi) ') is out of range [0.21 3.46] in function fxpt_log().'])
end
%---------------------------- END OF CODE ---------------------------------
% Please send suggestions for improvement of the function 
% to Ross Snider at this email address: ross.snider@montana.edu
%
% License:
% The MIT License (MIT)
% Copyright (c) 2016  Ross Snider 
%
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files 
% (the "Software"), to deal in the Software without restriction, 
% including without limitation the rights to use, copy, modify, merge, 
% publish, distribute, sublicense, and/or sell copies of the Software, 
% and to permit persons to whom the Software is furnished to do so, 
% subject to the following conditions:
%
% The above copyright notice and this permission notice shall be 
% included in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.





