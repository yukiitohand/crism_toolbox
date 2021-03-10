function [rgb_bands] = crism_get_default_bands(WAdata,varargin)
% [rgb_bands] = crism_get_default_bands(WAdata,varargin)
%  get default rgb aands from Wavelength file
%   INPUTS
%    WAdata: CRISMdata obj, CDR WA
%   OUTPUTS
%    rgb_bands: [r,g,b]
%   OPTIONAL Parameters
%    "MODE": magic number for rgb wavelength mode for S data
%      (default) 1
% 

mode4S = 1;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MODE'
                mode4S = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

% Get SWeet Spot Wavelength
[sw] = crism_get_sw(WAdata);

% use different functions for different 
switch upper(crismdata_obj.prop.sensor_id)
    case 'S'
        [rgb_bands] = crism_get_default_bands_S(sw,mode4S);
    case 'L'
        [rgb_bands] = crism_get_default_bands_L(sw);
    otherwise
        error('Undefined sensor_id %s.',lbl.MRO_SENSOR_ID);
end


end