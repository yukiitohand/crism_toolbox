function [sclk] = crism_get_frame_sclk_fromHKT(hkt,varargin)
% [sclk] = crism_get_frame_sclk_fromHKT(hkt)
% [sclk] = crism_get_frame_sclk_fromHKT(hkt,ttp)
% [sclk] = crism_get_frame_sclk_fromHKT(hkt,'mean')
% [sclk] = crism_get_frame_sclk_fromHKT(hkt,'start')
% [sclk] = crism_get_frame_sclk_fromHKT(hkt,'end')
% [sclk] = crism_get_frame_sclk_fromHKT(hkt,'linspace',5)
%  Get sclk time stamps for each of the image frames from house keep table.
%  INPUTS
%   hkt: house keeping table, struct, output of crismHKTread
%   ttp: time type, {'mean','start','end','linspace'},
%        'mean' if not specified
%    With 'linspace', you need additional parameter.
%  OUTPUTS
%   sclk: L x [] length vector, storing sclk time for each image
%   frame. (L: number of image frames). The number of column is one for the
%   three modes ('mean','start','end') and equal to the number of samples
%   equally spaced with "linspace".s
% 
% Note: 
%  In case of linspase with 5. The time at each "+" below will be sampled
%
%        1       2       3       4       5
%    |---+---|---+---|---+---|---+---|---+---|
%  start                                    end
% 
% 
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>

if isempty(varargin)
    ttp = 'MEAN';
elseif length(varargin)==1
    ttp = varargin{1};
elseif length(varargin)==2
    ttp = varargin{1};
    ttp_val = varargin{2};
    ttp_opt = '';
elseif length(varargin)==3
    ttp = varargin{1};
    ttp_val = varargin{2};
    ttp_opt = varargin{3};
else
    error('Invalid parameters');
end


% get rate and integ parameter from house keeping table
rate_id = cat(1,hkt.data.RATE);
integ_t = cat(1,hkt.data.EXPOSURE);

% convert integ parameter (0-480) to integration time [ms]
[exp_t] = crism_get_integrationTime(integ_t,rate_id);
exp_t = exp_t ./ 1000;

% get start sclk time to 
t_start = cat(1,hkt.data.EXPOSURE_SCLK_S)+cat(1,hkt.data.EXPOSURE_SCLK_SS)/(2.^16);

switch upper(ttp)
    case 'MEAN'
        sclk = t_start + exp_t ./ 2;
    case 'START'
        sclk = t_start;
    case 'END'
        sclk = t_start + exp_t;
    case 'LINSPACE'
        if exist('ttp_val','var')
            n = ttp_val;
        else
            error('Not enough inputs for "linspace" option.');
        end
        tn = (2*(1:n)-1)/(2*n) .* exp_t;
        sclk = t_start + tn;
    otherwise
        error('Invalid optional parameter: %s',ttp);
end


end
