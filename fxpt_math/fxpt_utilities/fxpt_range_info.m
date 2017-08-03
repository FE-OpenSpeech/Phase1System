function info = fxpt_range_info(S,W,F)
% This function reports the range and precision of a fixed-point data type
% and reports them as double-precision floating-point values
% Warning: There could be loss of precision and/or range when converting to
% double-precision.
% Requires the fixed-point toolbox

a = fi(0,S,W,F);  % create fixed-point object

info.DataTypeMode   = a.DataTypeMode;
info.Signedness     = a.Signedness;
info.WordLength     = a.WordLength;
info.FractionLength = a.FractionLength;

bit_string_zeros = repmat('0',1,W);  % create character string of zeros
bit_string_ones  = repmat('1',1,W);  % create character string of zeros

if S == 1  % signed
    % Get precision
    bit_string = bit_string_zeros;
    bit_string(end) = '1';
    a.bin = bit_string;
    info.precision = double(a);
    % Get largest positive value
    bit_string = bit_string_ones;
    bit_string(1) = '0';
    a.bin = bit_string;
    info.largest_positive = double(a);
    % Get least negative value
    bit_string = bit_string_zeros;
    bit_string(1) = '1';
    a.bin = bit_string;
    info.most_negative = double(a);
   % Get dynamic range
   info.dynamic_range = info.largest_positive - info.most_negative;
elseif S==0 % unsigned
    % Get precision
    bit_string = bit_string_zeros;
    bit_string(end) = '1';
    a.bin = bit_string;
    info.precision = double(a);
    % Get largest positive value
    bit_string = bit_string_ones;
    a.bin = bit_string;
    info.largest_positive = double(a);
    % Get least negative value
    bit_string = bit_string_zeros;
    a.bin = bit_string;
    info.most_negative = double(a);
   % Get dynamic range
   info.dynamic_range = info.largest_positive - info.most_negative;    
else
    error('Sign value not valid');
end

%info

end

