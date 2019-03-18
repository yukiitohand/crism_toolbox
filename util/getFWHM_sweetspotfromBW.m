function [fwhm_sweetspot,sweetspot_rownum] = getFWHM_sweetspotfromBW(WAdata,varargin)
% [fwhm,sweetspot_rownum] = getFWHM_sweetspotfromBW(WAdata,acro)
%   Get sCDR SW/BW for the given WA file.
%   Input: 
%     WAdata: CDR WA data, CRISMdata obj
%     acro  : {'SW' or 'BW'}
%   Optinonal input
%    'band_inverse': boolean, whether or not invert bands
%                    (default) false
%   Output: 
%     fwhm_sweetspot: sweetspot wavelength, 1d-array
%     sweetspot_rownum: ROWNUMTABLE, 1d-array
%   

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

propWA = getProp_basenameCDR4(WAdata.basename);

[WVdata] = getWVfromWA(WAdata);
[BWdata] = getSWBWfromWA(WAdata,'BW');

wv_tab = WVdata.readTAB();
bw_tab = BWdata.readTAB();

wv_field = sprintf('IR_FILTER_%d',propWA.wavelength_filter);
wv_filter = [wv_tab.data.(wv_field)]';
wv_filter = boolean(wv_filter);

fwhm_data = bw_tab.data(wv_filter);

fwhm_sweetspot = [fwhm_data.SAMPL_FWHM]';
sweetspot_rownum = [fwhm_data.ROWNUM]';

if is_band_inverse
    fwhm_sweetspot = flip(fwhm_sweetspot);
    sweetspot_rownum = flip(sweetspot_rownum);
end

end