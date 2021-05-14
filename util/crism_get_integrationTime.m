function [t] = crism_get_integrationTime(integ,rate,varargin)
% [t] = crism_get_integrationTime(integ,varargin)
% [t] = crism_get_integrationTime(integ,rate,'Hz')
%  Calculate integration time [milliseconds] from the 'integ' parameter
%  and frame rate [Hz]
% Input Parameters
%   integ: integer, integ parameter (0-480)
%   rate: integer, ID of frame rate (0-4)
%         if 'Hz' is inputed, then rate is supposed to be frequency [Hz]
% Output Parameters
%   t: integration time, [milli seconds]
%
% Usage
%   >> [t] = crism_get_integrationTime(integ,rate)
%   >> [t] = crism_get_integrationTime(integ,rate,'Hz')
%  

% Detail
% t[ms]=1000 * ((502-floor((502/480)*(480-integ)))/(502*[frame rate]))
%  I think there is a mistake in the document
%  

rateUnit = 'none';

if length(varargin)==1
    rateUnit=varargin{1};
elseif length(varargin)>2
    error('Invalid length of varargin');
end
    
switch rateUnit
    case 'none'
        rateHz = crism_get_frame_rate(rate);
    case 'Hz'
        rateHz = rate;
    otherwise
        error('invalid unit of rate');
end

t = 1000.*( (502 - floor((502/480)*(480-integ)) ) ./ (502*rateHz) );

end
