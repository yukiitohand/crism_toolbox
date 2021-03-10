function [sclk_str] = crism_get_sclkstr4spice(hkt,varargin)
% [sclk_str] = crism_get_sclkstr4spice(hkt)
% [sclk_str] = crism_get_sclkstr4spice(hkt,ttp)
%  get mean sclk time stamps for each of the image frames from house keep
%  table
%  INPUTS
%   hkt: house keeping table, struct, output of crismHKTread
%   ttp: time type, {'mean','start','end'}, 'mean' if not specified
%  OUTPUTS
%   sclk_str: L x 1 length vector, storing sclk string time for each image
%   frame. (L: number of image frames)
% 
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>

% if isempty(varargin)
%     ttp = 'MEAN';
% elseif length(varargin)==1
%     ttp = varargin{1};
% else
%     error('Invalid parameters');
% end

[sclk_num] = crism_get_frame_sclk_fromHKT(hkt,varargin{:});
[sclk_str] = spice_sclk_num2str(sclk_num);

% switch upper(ttp)
%     case 'MEAN'
%         [sclk_num] =  crism_get_frame_sclk_fromHKT(hkt,'mean');
%         [sclk_str] = spice_sclk_num2str(sclk_num);
%     case 'START'
%         sclk_str = cellfun( @(x,y) sprintf('%d:%d',x,y), ...
%             cat(1,hkt.data.EXPOSURE_SCLK_S), ...
%             cat(1,hkt.data.EXPOSURE_SCLK_SS), ...
%             'UniformOutput',false);
%     case 'END'
%         [sclk_num] =  crism_get_frame_sclk_fromHKT(hkt,'end');
%         [sclk_str] = spice_sclk_num2str(sclk_num);
%     otherwise
%         error('Invalid optional parameter: %s',ttp);
% end

end