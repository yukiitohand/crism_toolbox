function [sclkch] = crism_spice_build_sclkch(partition,sclk_s,sclk_ss)
% [sclkch] = crism_spice_build_sclkch(partition,sclk_s,sclk_ss)
%  Build a char form of sclk for an input to spice-mice functions.
%  INPUTS:
%    partition: partition number 
%    sclk_s: integer, number of seconds
%    sclk_ss: integer, number of (1/2^16) subseconds 
%  OUTPUTS:
%    sclkch: cell (if length(sclk_s)>1) of char.
%    Its element is the form of 
%      p...p/xxx...x:sss...s
%    p...p   : partition number
%    xxx...x : integer part of sclk
%    sss...s : integer representation of the decimal part of sclk. One
%    corrsponds to (1/2^16).
%
% Copyright (C) 2022 Yuki Itoh <yukiitohand@gmail.com>
%

if length(sclk_s) ~= length(sclk_ss)
    error('sclk_s and sclk_ss has different lengths.');
end

sclkch = arrayfun(@(s,ss) sprintf('%d/%d:%d',partition,s,ss), ...
    sclk_s,sclk_ss,'UniformOutput',false);

end