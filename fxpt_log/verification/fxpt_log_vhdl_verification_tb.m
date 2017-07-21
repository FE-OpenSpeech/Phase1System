function fxpt_log_vhdl_verification_tb
      
% Note:  Run launch_hdl_simulator_fxpt_log_compute_w33f30.m   first
%------------------------------------------------------------
% Note: it appears that the cosimWizard needs to be re-run if
% this is moved to a different machine (VHDL needs to be
% recompile in ModelSim).
%------------------------------------------------------------

% HdlCosimulation System Object creation (this Matlab function was created
% by the cosimWizard).
fxpt_log_hdl = hdlcosim_fxpt_log_compute_w33f30;            

W=33;
F=30;
S=1;
AW = ceil(log2(W));

% Simulate for Nclock rising edges (this will be the length of the
% simulation)

Fm = fimath('RoundingMethod','Floor',...
    'OverflowAction','Wrap',...
    'ProductMode','SpecifyPrecision',...
    'ProductWordLength',W,...
    'ProductFractionLength',F,...
    'SumMode','SpecifyPrecision',...
    'SumWordLength',W,...
    'SumFractionLength',F);


Nvalues = 1000;
xstart = 0.5;
xend   = 1.0;
xstep_size = (xend-xstart)/Nvalues;
max_error =0;
x = xstart;
for i=1:Nvalues
    
    
    
    %x    = 0.5
    x_input = fi(x,S,W,F,Fm) % make the input a fixed point data type
    yfxpt=fxpt_log(x_input);
    disp(['i=' num2str(i) '  x=' num2str(x) '  y=log(x)=' num2str(log(x)) '   y=fxpt_log(x)=' num2str(double(yfxpt))  '=' yfxpt.hex  '   fxpt-double error=' num2str(abs(log(x)-double(yfxpt)))])
    
    
    yout = fi(0,S,W,F,Fm);
    
    compute_clock_edges = 100;
    for clki=1:compute_clock_edges
        %-----------------------------------------------------------------
        % Create our input vector at each clock edge, which must be a
        % fixed-point data type.  The word width of the fixed point data type
        % must match the width of the std_logic_vector input.
        %-----------------------------------------------------------------
        %input_history{clki} = input_vector1;  % capture the inputs
        
        %input_vector1.hex
        
        if clki == 2
            start_signal = fi(1, 0, 1, 0);
        else
            start_signal = fi(0, 0, 1, 0);
        end
        %-----------------------------------------------------------------
        % Push the input(s) into the component using the step function on the
        % system object lzc_hdl
        % If there are multiple I/O, use
        % [out1, out2, out3] = step(lzc_hdl, in1, in2, in3);
        % and understand all I/O data types are fixed-point objects
        % where the inputs can be created by the fi() function.
        %-----------------------------------------------------------------
        
        % entity fxpt_log_compute_debug_W26F24 is
        %    port (
        %       clock	 : in  std_logic;
        %       reset	 : in  std_logic;
        %       x	     : in  std_logic_vector(25 downto 0);
        %       start	 : in  std_logic;
        %       y      : out std_logic_vector(25 downto 0);   -- y=ln(x)
        %       done   : out std_logic
        %    );
        % end entity;
        
        %clki
        [yout, done_signal] = step(fxpt_log_hdl,x_input,start_signal);
        
        %-----------------------------------------------------------------
        % Save the outputs (which are fixed-point objects)
        %-----------------------------------------------------------------                
        if double(done_signal) == 1
            break
        end
    end
    yfxptout = reinterpretcast(yout,numerictype(S,W,F))
    

    %a.hex
    %mdiff = yfxpt-a
    %mdiff.bin
    merror{i}.x_input  = x_input;
    merror{i}.y_matlab = yfxpt;
    merror{i}.y_vhdl = yfxptout;
    merror{i}.error = double(yfxpt-yfxptout);
    
    error1 = abs(merror{i}.error);
    if error1 > max_error
       max_error = error1;
       max_index = i;
    end
    
    disp([yfxptout.hex '  <--> ' yfxpt.hex   '  Error = ' num2str(merror{i}.error)])    
    
    x=x+xstep_size;
end 

max_error
max_index
merror{max_index}.x_input
a=merror{max_index}.y_matlab
a.hex
a.bin
b=merror{max_index}.y_vhdl
b.hex
b.bin
merror{max_index}.error


% return
% 
% for i=1:F
%   a = pd(i);          disp(['p  = ' fxpt2str(a) ' = ' a.hex]);
%   a = xd(i);          disp(['x  = ' fxpt2str(a) ' = ' a.hex]);
%   a = xsd(i);         disp(['xs = ' fxpt2str(a) ' = ' a.hex]);
%   a = yd(i);          disp(['y  = ' fxpt2str(a) ' = ' a.hex]);
%   a = lnb(i);         disp(['lnb= ' fxpt2str(a) ' = ' a.hex]);
%   disp(' ');
% end
% disp(['y=log(x)=' num2str(log(x)) ' = ' fxpt2str(yfxpt)  ' = ' yfxpt.hex])
% disp(' ');
