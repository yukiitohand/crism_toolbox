function [p,sclk_s,sclk_ss] = crism_lbl_get_sclk(lbl,varargin)
% [p,sclk_s,sclk_ss] = crism_lbl_get_sclk(lbl,varargin)
% Get partition, number of seconds and number of (1/2^16) subseconds are
% obtained from either of fields, SPACECRAFT_CLOCK_START_COUNT or
% SPACECRAFT_CLOCK_STOP_COUNT in the LBL file.
% Usage
%  [p,sclk_s,sclk_ss] = crism_lbl_get_sclk(lbl,'start');
%  [p,sclk_s,sclk_ss] = crism_lbl_get_sclk(lbl,'stop'); 

if isempty(varargin)
    t = 'start';
elseif length(varargin)==1
    t = varargin{1};
end

switch upper(t)
    case 'START'
        sclkch = lbl.SPACECRAFT_CLOCK_START_COUNT;
    case {'END','STOP'}
        sclkch = lbl.SPACECRAFT_CLOCK_STOP_COUNT;
    otherwise
        error('%s is not specified.',t);
end

sclk = sscanf(sclkch,'%d/%d:%d');
if length(sclk)~=3
    sclk = sscanf(sclkch,'%d/%d.%d');
end

if length(sclk)==3
    p = sclk(1);
    sclk_s = sclk(2);
    sclk_ss = sclk(3);
else
    error('%s does not follow the required format.',sclkch);
end

end