function [msldemcc_hdr] = crism_get_msldemcc_hdr_wRadiusMaxMin( ...
    pos_mro_wrt_mars,pmc_fovbndvrtcs,radius_min,radius_max,MSLDEMdata, ...
    msldemc_hdr)
% [msldemcc_hdr] = crism_get_msldemcc_hdr_wRadiusMaxMin( ...
%     pos_mro_wrt_mars,pmc_FOVbound,radius_min,radius_max,MSLDEMdata, ...
%     msldemc_hdr)
% Using the give maximum and minimum radius inside the image region
% that is supposed to include the CRISM image of interest, get more
% restricted, smaller region that encloses the CRISM scan line at the time
% at which the position of the mars is "pos_mro_wrt_mars" and CRISM FOV
% bounds is defined as "pmc_fovbndvrtcs".
%  INPUTS
%   pos_mro_wrt_mars: double [3x1] position of the MRO with respect to Mars
%   pmc_fovbndvrtcs : double [3x4] (P-C) pointing vectors of the four 
%     vertices of the CRISM FOV rectangle. This vector should be defined in
%     the same domain as that of "pos_mro_wrt_mars"
%   radius_min      : double minimum radius within the subimage defind by 
%     msldemc_hdr (needs to be smaller than the actual minimum)
%   radius_max      : double maximum radius within the subimage defind by 
%     msldemc_hdr (needs to be larger than the actual minimum)
%   MSLDEMdata   : MSLGaleMosaicRadius_v3 class obj MSL Radius data.
%   msldemc_hdr: truct with the following four fields
%     'sample_offset', 'line_offset', 'samples', 'lines'
%    The base subimage.
%   
%  OUTPUTS
%   msldemcc_hdr: struct with the following four fields
%     'sample_offset', 'line_offset', 'samples', 'lines'
%    The values of these offsets are based on the subimage, defined by 
%    msldemc_hdr, of the MSLDEMdata.
%
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>


% longitude and latitude intercept with minimum radius assumed.
[r_minb,lon_minb,lat_minb] = cspice_surfpt_reclat_mex( ...
    pos_mro_wrt_mars, ...
    pmc_fovbndvrtcs, ...
    radius_min,radius_min,radius_min);
% longitude and latitude intercept with maximum radius assumed.
[r_maxb,lon_maxb,lat_maxb] = cspice_surfpt_reclat_mex( ...
    pos_mro_wrt_mars, ...
    pmc_fovbndvrtcs, ...
    radius_max,radius_max,radius_max);

% Potential minimum & maximum longitude
% Potential minimum & maximum latitude
lon_min = min([lon_minb,lon_maxb]);
lon_max = max([lon_minb,lon_maxb]);
lat_min = min([lat_minb,lat_maxb]);
lat_max = max([lat_minb,lat_maxb]);

% sample and line pixels associated with "msldem_img"
vsj = [ floor(MSLDEMdata.lon2x(rad2deg(lon_min))); ...
    ceil(MSLDEMdata.lon2x(rad2deg(lon_max))) ] - msldemc_hdr.sample_offset;
vlj = [ floor(MSLDEMdata.lat2y(rad2deg(lat_max))); ...
    ceil(MSLDEMdata.lat2y(rad2deg(lat_min))) ] - msldemc_hdr.line_offset;

% safeguarding by expanding the region one pixel in all directions.
vsj(1) = max(vsj(1)-1,1);
vsj(2) = min(vsj(2)+1,msldemc_hdr.samples);
vlj(1) = max(vlj(1)-1,1);
vlj(2) = min(vlj(2)+1,msldemc_hdr.lines);

msldemcc_hdr = [];
msldemcc_hdr.samples = vsj(2)-vsj(1)+1;
msldemcc_hdr.lines   = vlj(2)-vlj(1)+1;
msldemcc_hdr.sample_offset = vsj(1)-1;
msldemcc_hdr.line_offset   = vlj(1)-1;

end