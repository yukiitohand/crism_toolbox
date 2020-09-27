function [wv_sweetspot,is_band_inverse,colsw] = getWV_sweetspot(WAdata)
% [wv_sweetspot,is_band_inverse] = getWV_sweetspot(WAdata)
%   Get sweetspot wavelengths for the given WA file.
%   Input: 
%     WAdata: CDR WA data, CRISMdata obj
%   Output: 
%     wv_sweetspot: 1-dimensional vector
%     is_band_inverse: boolean, whether or not wv_sweetspot is inversed or
%     not.
%     colsw: columns used for the SW.
%   

if isempty(WAdata.img), WAdata.readimgi(); end

propWA = getProp_basenameCDR4(WAdata.basename);

[colsw] = crism_get_columns_sweetspot_wavelength(propWA.sensor_id,propWA.binning);

wv_sweetspot = squeeze(mean(WAdata.img(:,colsw,:),2));
is_band_inverse = WAdata.is_img_band_inverse;

end

