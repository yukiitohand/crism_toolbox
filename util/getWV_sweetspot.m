function [wv_sweetspot,is_band_inverse] = getWV_sweetspot(WAdata)
% [wv_sweetspot,is_band_inverse] = getWV_sweetspot(WAdata)
%   Get sweetspot wavelengths for the given WA file.
%   Input: 
%     WAdata: CDR WA data, CRISMdata obj
%   Output: 
%     wv_sweetspot: 1-dimensional vector
%     is_band_inverse: boolean, whether or not wv_sweetspot is inversed or
%     not.
%   

if isempty(WAdata.img), WAdata.readimgi(); end

propWA = getProp_basenameCDR4(WAdata.basename);

switch propWA.sensor_id
    case 'L'
        switch propWA.binning
            case 0
                cc = 270:369;
            case 1
                cc = 135:184;
            otherwise
                error('Please implement for the wavelength binning option %d',propWA.binning);
        end
    case 'S'
        switch propWA.binning
            case '0'
                cc = 260:359;
            case '1'
                cc = 130:179;
            otherwise
                error('Please implement for the wavelength binning option %d',propWA.binning);
        end
end
wv_sweetspot = squeeze(mean(WAdata.img(:,cc,:),2));
is_band_inverse = WAdata.is_img_band_inverse;

end

