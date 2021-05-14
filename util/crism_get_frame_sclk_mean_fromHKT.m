function [sclk_mean] = crism_get_frame_sclk_mean_fromHKT(hkt)
% [sclk_mean] = crism_get_frame_sclk_mean_fromHKT(hkt)
%  get mean sclk time stamps for each of the image frames from house keep
%  table
%  INPUTS
%   hkt: house keeping table, struct, output of crismHKTread
%  OUTPUTS
%   sclk_mean: L x 1 length vector, storing mean sclk time for each image
%   frame. (L: number of image frames)
% 
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>

% get rate and integ parameter from house keeping table
rate_id = cat(1,hkt.data.RATE);
integ_t = cat(1,hkt.data.EXPOSURE);

% convert integ parameter (0-480) to integration time [ms]
[exp_t] = crism_get_integrationTime(integ_t,rate_id);

% get start sclk time to 
t_start = cat(1,hkt.data.EXPOSURE_SCLK_S)+cat(1,hkt.data.EXPOSURE_SCLK_SS)/(2.^16);

sclk_mean = t_start + exp_t ./1000 ./ 2;

end