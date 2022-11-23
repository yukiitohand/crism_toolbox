function [sclkdec] = crism_get_frame_sclkdec(hkp_fpath,varargin)
% [sclkdec] = crism_get_frame_sclkdec(hkt)
% [sclkdec] = crism_get_frame_sclkdec(hkt,ttp)
% [sclkdec] = crism_get_frame_sclkdec(hkt,'mean')
% [sclkdec] = crism_get_frame_sclkdec(hkt,'start')
% [sclkdec] = crism_get_frame_sclkdec(hkt,'end')
% [sclkdec] = crism_get_frame_sclkdec(hkt,'stop')
% [sclkdec] = crism_get_frame_sclkdec(hkt,'linspace',5)
% [sclkdec] = crism_get_frame_sclkdec(hkt,{'start','mean','stop'})
% Get sclk time stamps for each of the image frames from house keep table.
%  INPUTS
%   hkt: house keeping table, struct, output of crismHKTread
%   ttp: time type, {'mean','start','end','stop','linspace'},
%        'mean' if not specified
%    With 'linspace', you need additional parameter.
%    You can add multiple ttp among {'mean','start','end','stop'} using a
%    cell array
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

hkp = crism_hkp_get_cols(hkp_fpath,{'EXPOSURE_SCLK_S','EXPOSURE_SCLK_SS', ...
    'EXPOSURE','RATE'});

% convert integ parameter (0-480) (EXPOSIRE) to integration time [ms]
[exp_t] = crism_get_integrationTime(hkp.exposure,hkp.rate);
exp_t = exp_t ./ 1000;


if isempty(varargin)
    ttp = {'MEAN'};
elseif length(varargin)==1
    if ischar(varargin{1})
        ttp = varargin;
    elseif iscell(varargin{1})
        ttp = varargin{1};
    else
        error('The second input is invalid.');
    end
elseif length(varargin)==2
    ttp = varargin{1};
    if ~strcmpi(ttp,'LINSPACE')
        error('The second input %s is invalid.',ttp);
    else
        ttp_val = varargin{2};
    end
else
    error('Invalid parameters');
end

% get sclk seconds in a float decimal type.
t_start = hkp.exposure_sclk_s + hkp.exposure_sclk_ss/(2.^16);

sclkdec = [];
for i=1:length(ttp)
    ttp_i = ttp{i};
    switch upper(ttp_i)
        case 'MEAN'
            sclk_i = t_start + exp_t ./ 2;
        case 'START'
            sclk_i = t_start;
        case {'STOP','END'}
            sclk_i = t_start + exp_t;
        case 'LINSPACE'
            if exist('ttp_val','var')
                n = ttp_val;
            else
                error('Not enough inputs for "linspace" option.');
            end
            tn = (2*(1:n)-1)/(2*n) .* exp_t;
            sclk_i = t_start + tn;
        case 'BETWEEN'
            % This option is added for an experiment.
            t_diff = 0.5*mean(t_start(2:end) - t_start(1:end-1),'omitnan');
            sclk_i = t_start + t_diff;
        otherwise
            error('Invalid time type parameter: %s',ttp_i);
    end
    sclkdec = [ sclkdec sclk_i ];
end


end
