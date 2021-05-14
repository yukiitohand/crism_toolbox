function [basename_trrx] = crism_get_TRRXbasename(TRRdata,vr)
% [basename_trrx] = crism_get_TRRXbasename(TRRdata,vr)
% Get the basename of the TRR* data.
%  INPUTS
%   TRRdata: CRISMdata object
%   vr: version of the TRR*data. one character in 0-9A-Z
%  OUTPUTS
%   basename_trrx: char, basename of the trrx
% 

if ~isa(TRRdata,'CRISMdata')
    error('Input 1 must be an instance of CRISMdata');
end
if isnumeric(vr)
   if ~isinteger(vr) || vr<0 || vr>9
       error('Input 2 must be one digit number or a one character (A-Z)');
   end
elseif ischar(vr)
    if isempty(regexpi(vr,'^[0-9A-Z]{1}$','once'))
       error('Input 2 must be one digit number or a one character (A-Z)');
    end
end
    
propTRRX = TRRdata.prop;
propTRRX.version = vr;
basename_trrx = crism_get_basenameOBS_fromProp(propTRRX);
end