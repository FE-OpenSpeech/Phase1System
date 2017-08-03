%clear all
%close all
% Domain of y=exp(x):   -1.24 <= x <= 1.56

if exist('fxptM') == 1
    W = fxptM.exp.W;
    F = fxptM.exp.F;
else
    W = 32;  % W = word length in bits
    F = 28;  % F = fractional bits
end
S = 1;   % S = 1 for signed fixed-point, S = 0 of unsigned

Nsteps = 1000;
domain_edge1 = -1.0;  % Domain of y=exp(x):  -1.24 <= x <= 1.56 
domain_edge2 = 1.0;
domain_width = domain_edge2-domain_edge1;
step_size = domain_width/Nsteps;

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

h = waitbar(0,'Number Crunching....');
V(1) = domain_edge1;
for i=1:Nsteps
    x               = fi(V(i),S,W,F,Fm);
    yfxpt           = fxpt_exp(x);
    y               = exp(V(i));
    error(i)        = abs(double(yfxpt)-y);
    V(i+1) = V(i) + step_size;
    waitbar(i/Nsteps,h,['Step ' num2str(i) ' of ' num2str(Nsteps) ' (' num2str(i/Nsteps*100) '%)'])
end
V(Nsteps+1)=[];
close(h)


plot(V,error); hold on
plot(V,error,'.')
xlabel(['Domain ' num2str(domain_edge1) ' <= x <= ' num2str(ceil(domain_edge2))])
ylabel('Error')
title(['Error = abs(fxpt\_exp(x) - exp(x))     W=' num2str(W) 'bits  F=' num2str(F) 'bits'])
a=axis;
h=text(a(1)*1.05, a(4)*0.95,['Fixed-Point Precision = 2\^(-' num2str(F) ') = ' num2str(2^(-F))  '              Average error = ' num2str(mean(error))    ]); 
%set(h,'FontSize', 40)
%h=text(a(1)*1.05, a(4)*0.85,['Average error = ' num2str(mean(error))]); set(h,'FontSize', 46)
%set(gca,'FontSize', 46)


