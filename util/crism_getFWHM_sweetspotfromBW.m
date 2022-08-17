function [fwhm_sweetspot,sweetspot_rownum] = crism_getFWHM_sweetspotfromBW(WAdata,varargin)
% [fwhm_sweetspot,sweetspot_rownum] = crism_getFWHM_sweetspotfromBW(WAdata,varargin)
%   Get sCDR SW/BW for the given WA file.
%   Input: 
%     WAdata: CDR WA data, CRISMdata obj
%     acro  : {'SW' or 'BW'}
%   Optinonal input
%    'band_inverse': boolean, whether or not invert bands
%                    (default) false
%    'sensor_id'   : {'S', 'L'}
%            (default) 'L'
%   Output: 
%     fwhm_sweetspot: sweetspot wavelength, 1d-array
%     sweetspot_rownum: ROWNUMTABLE, 1d-array
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

propWA = crism_getProp_basenameCDR4(WAdata.basename);

[WVdata] = crism_getWVfromWA(WAdata);
[BWdata] = crism_getSWBWfromWA(WAdata,'BW');

wv_tab = WVdata.readTAB();
bw_tab = BWdata.readTAB();

switch upper(sensor_id)
    case 'L'
        wv_field = sprintf('IR_FILTER_%d',propWA.wavelength_filter);
    case 'S'
        wv_field = sprintf('VNIR_FILTER_%d',propWA.wavelength_filter);
    otherwise
        error('undefined sensor_id %s',sensor_id);
end
wv_filter = [wv_tab.data.(wv_field)]';
wv_filter = logical(wv_filter);

fwhm_data = bw_tab.data(wv_filter);

switch upper(sensor_id)
    case 'L'
        fwhm_sweetspot = [fwhm_data.SAMPL_FWHM]';
    case 'S'
        fwhm_sweetspot = [fwhm_data.SAMPL_BW]';
    otherwise
        error('undefined sensor_id %s',sensor_id);
end

sweetspot_rownum = [fwhm_data.ROWNUM]';

if is_band_inverse
    fwhm_sweetspot = flip(fwhm_sweetspot);
    sweetspot_rownum = flip(sweetspot_rownum);
end

end