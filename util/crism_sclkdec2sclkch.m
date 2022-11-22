function [sclkch] = crism_sclkdec2sclkch(sclkdec,partition)
% [sclkch] = crism_sclkdec2sclkch(sclkdec,partition)
%  Convert a numeric form of sclk to a valid char/string form for an input
%  to spice-mice functions.
%  INPUTS:
%    sclkdec: decimal format of sclk
%  OUTPUTS:
%    sclkch: cell (if length(sclk_num)>1) of char (if sclk_num is a scalar.
%    Its element is the form of 
%      p...p/xxx...x:sss...s
%    p...p   : partition number
%    xxx...x : integer part of sclk
%    sss...s : integer representation of the decimal part of sclk. One
%    corrsponds to (1/2^16).
%
% Copyright (C) 2022 Yuki Itoh <yukiitohand@gmail.com>
%

sclk_S  = floor(sclkdec);
sclk_SS = round((sclkdec-sclk_S)*65536);

if length(sclkdec)==1
    sclkch = sprintf('%d/%d:%d',partition,sclk_S,sclk_SS);
else
    sclkch = arrayfun( ...
        @(s,ss) sprintf('%d/%d:%d',partition,s,ss), sclk_S, sclk_SS, ...
        'UniformOutput',false);
end

end