%clear all
%close all
%------------------------------------------------------------------------
% This script tests the fxpt_log() function, compares it to Matlab's
% double-precision results, and plots the results
%------------------------------------------------------------------------

% Domain of y=ln(x):  0.21 <= x <= 3.45

%---------------------------------------------------------------
% Set Fixed-point data size
%---------------------------------------------------------------
if exist('fxptM') == 1
    W = fxptM.log.W;
    F = fxptM.log.F;
else
    W = 32;  % W is the word size, i.e. the total number of bits
    F = 30;  % F is the number of fractional bits
end
S = 1;   % S = 1 for signed fixed-point, S = 0 of unsigned


%---------------------------------------------------------------
% Check the over the domain 0.5 <= x <= 1.0 and compare to
% Matlab's double precision log function
%---------------------------------------------------------------
Nsteps = 1000;
domain_edge1 = 0.5;
domain_edge2 = 1.0;
domain_width = domain_edge2-domain_edge1;
step_size = domain_width/Nsteps;

%---------------------------------------------------------------
% Perform the comparision
%---------------------------------------------------------------
h = waitbar(0,'Number Crunching....');
V(1) = domain_edge1;
for i=1:Nsteps
    x        = fi(V(i),S,W,F);
    yfxpt    = fxpt_log(x);
    y        = log(V(i));
    error(i) = abs(double(yfxpt)-y);
    
    V(i+1) = V(i) + step_size;
    waitbar(i/Nsteps,h,['Step ' num2str(i) ' of ' num2str(Nsteps) ' (' num2str(i/Nsteps*100) '%)'])
end
V(Nsteps+1)=[];
close(h)

%---------------------------------------------------------------
% Plot the results
%---------------------------------------------------------------
plot(V,error); hold on
plot(V,error,'.')
xlabel(['Domain ' num2str(domain_edge1) ' <= x <= ' num2str(ceil(domain_edge2))])
ylabel('Error')
title(['Error = abs(fxpt\_log(x) - log(x))     W=' num2str(W) 'bits  F=' num2str(F) 'bits'])
a=axis;
h=text(a(1)*1.05, a(4)*0.95,['Fixed-Point Precision = 2\^(-' num2str(F) ') = ' num2str(2^(-F))  '              Average error = ' num2str(mean(error))    ]); 
%set(h,'FontSize', 40)
%h=text(a(1)*1.05, a(4)*0.85,['Average error = ' num2str(mean(error))]); set(h,'FontSize', 46)
%set(gca,'FontSize', 46)


