% fxpt_power_tb
% clear all
% close all

% Set the Word Length (W) and number of Fraction bits (F) in the word
% and set the sign bit (S) for the fixed-point representation.
global fxptM;
if exist('fxptM') == 1
    W = fxptM.power.W;
    F = fxptM.power.F;
else
    W = 48;  % W = word length in bits
    F = 24;  % F = fractional bits
end
S=1;

fxpt_info = fxpt_range_info(S,W,F)


Nxsteps = 100;
Nysteps = 4;

xstart = 1;
xstop  = fxpt_info.largest_positive;

ystart = 0.2;
ystop  = 0.9;

Xdomain_width = xstop-xstart;
Xstep_size = Xdomain_width/Nxsteps;
Ydomain_width = ystop-ystart;
Ystep_size = Ydomain_width/Nysteps;

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

Vx=zeros(1,Nxsteps);
Vy=zeros(1,Nysteps);
error=zeros(Nxsteps, Nysteps);

Vx(1) = xstart;
h = waitbar(0,'Number Crunching....');
for ix=1:Nxsteps
    Vy(1) = ystart;
    for iy=1:Nysteps
        z        = Vx(ix)^Vy(iy);
        %[ix iy Vx(ix) Vy(iy)]
            
        x        = fi(Vx(ix),S,W,F,Fm);
        y        = fi(Vy(iy),S,W,F,Fm);
        zfxpt    = fxpt_power(x,y);
        %z
        %double(zfxpt)
        
        error(ix,iy) = abs(double(zfxpt)-z)/double(zfxpt);
        %abs(double(zfxpt)-z)
        %pause
        
        Vy(iy+1) = Vy(iy) + Ystep_size;
        
    end
    Vx(ix+1) = Vx(ix) + Xstep_size;
    waitbar(ix/Nxsteps,h,['X step ' num2str(ix) ' of ' num2str(Nxsteps) ' (' num2str(ix/Nxsteps*100) '%)'])
end
close(h)
Vx(end)=[];
Vy(end)=[];

size(Vx)
size(Vy)
size(error)

surf(Vy,Vx,error)
ylabel('x')
xlabel('exponent y')
zlabel('Normalized error')
title('Error = abs(fxpt\_power(x,y) - x\^y)')
%h=text(a(1)*0.95, a(4)*0.95,['Fixed-Point Precision = 2\^(-' num2str(F) ') = ' num2str(2^(-F))  '              Average error = ' num2str(mean(error))    ]); set(h,'FontSize', 22)
%h=text(['Fixed-Point Precision = 2\^(-' num2str(F) ') = ' num2str(2^(-F))  '              Average error = ' num2str(mean(error(:)))    ]); set(h,'FontSize', 22)
%axis([-2 2 0 5 0 2^(-F+6)])
set(gca,'FontSize', 24)

