function [bbl] = create_crism_bbl(wv_sweetspot,sensor_id,varargin)
% [bbl] = create_crism_bbl(wv_sweetspot,sensor_id)
%   refer 'create_crism_bbl.pro' and 'crism_bad_bands.pro' in CAT
%  Input
%   wv_sweetspot: wavelength at sweet spot
%   sensor_id: 'S' or 'L'
%  Optinonal input
%    'band_inverse': boolean, whether or not invert bands
%                    (default) false
%  Output
%   bbl: boolean vector, same size as wv_sweetspot

is_band_inverse = false;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'BAND_INVERSE'
                is_band_inverse = varargin{i+1};
        end
    end
end

bbl = true(size(wv_sweetspot));

bbl(isnan(wv_sweetspot)) = false;

switch sensor_id
    case 'L'
        bbl(wv_sweetspot<1021) = false;
        bbl(and(wv_sweetspot>2692,wv_sweetspot<2703)) = false;
        bbl(wv_sweetspot>3926) = false;
    case 'S'
        bbl(wv_sweetspot<407) = false;
        bbl(and(wv_sweetspot>641,wv_sweetspot<686)) = false;
        bbl(wv_sweetspot>1025) = false;
end

if is_band_inverse
    bbl = flip(bbl);
end

end