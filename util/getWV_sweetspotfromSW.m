function [wv_sweetspot,wv_sweetspot_rownum] = getWV_sweetspotfromSW(WAdata,varargin)
% [wv_sweetspot,wv_sweetspot_rownum] = getWV_sweetspotfromSW(WAdata,acro)
%   Get sweetspot wavelength for the given WA file.
%   Input: 
%     WAdata: CDR WA data, CRISMdata obj
%     acro  : {'SW' or 'BW'}
%   Optinonal input
%    'band_inverse': boolean, whether or not invert bands
%                    (default) false
%    'sensor_id'   : {'S', 'L'}
%            (default) 'L'
%   Output: 
%     wv_sweetspot: sweetspot wavelength, 1d-array
%     wv_sweetspot_rownum: ROWNUMTABLE, 1d-array
%   
sensor_id = 'L';
is_band_inverse = false;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'BAND_INVERSE'
                is_band_inverse = varargin{i+1};
            case 'SENSOR_ID'
                sensor_id = varargin{i+1};
        end
    end
end

propWA = getProp_basenameCDR4(WAdata.basename);

[WVdata] = getWVfromWA(WAdata);
[SWdata] = getSWBWfromWA(WAdata,'SW');

wv_tab = WVdata.readTAB();
sw_tab = SWdata.readTAB();

switch upper(sensor_id)
    case 'L'
        wv_field = sprintf('IR_FILTER_%d',propWA.wavelength_filter);
    case 'S'
        wv_field = sprintf('VNIR_FILTER_%d',propWA.wavelength_filter);
    otherwise
        error('undefined sensor_id %s',sensor_id);
end
wv_filter = [wv_tab.data.(wv_field)]';
wv_filter = boolean(wv_filter);

wv_sweetspot_data = sw_tab.data(wv_filter);

wv_sweetspot = [wv_sweetspot_data.SAMPL_WAV]';
wv_sweetspot_rownum = [wv_sweetspot_data.ROWNUM]';

if is_band_inverse
    wv_sweetspot = flip(wv_sweetspot);
    wv_sweetspot_rownum = flip(wv_sweetspot_rownum);
end

end