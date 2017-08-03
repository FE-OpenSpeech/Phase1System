%fxpt_exp_ext_tb
%clear all
%close all

global fxptM;
if exist('fxptM') == 1
    W = fxptM.exp_ext.W;
    F = fxptM.exp_ext.F;
else
    W = 32;  % W = word length in bits
    F = 28;  % F = fractional bits
end
S=1;

fxpt_info = fxpt_range_info(S,W,F);

range_partition = 2;  % 1->negative values,  2->positive values 

Nsteps = 10;
if range_partition == 1
%     domain_edge1 = fxpt_info.most_negative/1.5;   % divide by 1.5 to avoid negative wrap around since this will be multiplied by log2(exp(1))=1.442695040888963
%     domain_edge2 =  0;
    domain_edge1 = 10;   % divide by 1.5 to avoid negative wrap around since this will be multiplied by log2(exp(1))=1.442695040888963
    domain_edge2 = 11;
else
    domain_edge1 = 0;   % divide by 1.5 to avoid negative wrap around since this will be multiplied by log2(exp(1))=1.442695040888963
    domain_edge2 = log(double(realmax(fi(0,1,W,F))));
end
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
    yfxpt           = fxpt_exp_ext(x);
    y               = exp(double(V(i)));
    error(i)        = abs(double(yfxpt)-y)/y;
    V(i+1) = V(i) + step_size;
    waitbar(i/Nsteps,h,['Step ' num2str(i) ' of ' num2str(Nsteps) ' (' num2str(i/Nsteps*100) '%)'])
end
V(Nsteps+1)=[];
close(h)


plot(V,error); hold on
plot(V,error,'b.')
xlabel(['Domain ' num2str(domain_edge1) ' <= x <= ' num2str(ceil(domain_edge2))])
ylabel('Error')
title(['Normalized Error = abs(fxpt\_exp\_ext(x) - exp(x))/exp(x)     W=' num2str(W) 'bits  F=' num2str(F) 'bits'])
a=axis;
h=text(a(1)*0.95, a(4)*0.95,['Fixed-Point Precision = 2\^(-' num2str(F) ') = ' num2str(2^(-F))  '              Average error = ' num2str(mean(error))    ]); set(h,'FontSize', 22)
%h=text(a(1)*1.05, a(4)*0.85,['Average error = ' num2str(mean(error))]); set(h,'FontSize', 46)
set(gca,'FontSize', 24)


