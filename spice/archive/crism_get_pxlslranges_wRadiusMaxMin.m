function [crismPxl_sranges_ap,crismPxl_lranges_ap] ...
    = crism_get_pxlslranges_wRadiusMaxMin(pos_mro_wrt_mars,...
    pmc_pxlvrtcs_top,pmc_pxlvrtcs_btm,Ncrism, ...
    radius_min,radius_max,MSLDEMdata,msldemc_hdr)
% [crismPxl_sranges_ap,crismPxl_lranges_ap] ...
%     = crism_get_pxlslranges_wRadiusMaxMin(pos_mro_wrt_mars,...
%     pmc_pxlvrtcs_top,pmc_pxlvrtcs_btm,Ncrism, ...
%     radius_min,radius_max,MSLDEMdata,msldemc_hdr)
% Using the give maximum and minimum radius inside the image region
% that is supposed to include the CRISM image of interest, get more
% restricted, smaller region of each pixel that encloses the pixel of the 
% CRISM scan line at the time at which the position of the mars is 
% "pos_mro_wrt_mars" and CRISM pixel boundray vectors are defined by 
% "pmc_pxlvrtcs_top" and "pmc_pxlvrtcs_btm"
%  INPUTS
%   pos_mro_wrt_mars: double [3x1] position of the MRO with respect to Mars
%   pmc_pxlvrtcs_top : double [3x(Ncrism+1)] (P-C) pointing vectors of the 
%     vertices (with y=-0.5) of the CRISM pixel boundries. This vector 
%     should be defined in the same domain as that of "pos_mro_wrt_mars"
%   pmc_pxlvrtcs_btm : double [3x(Ncrism+1)] (P-C) pointing vectors of the 
%     vertices (with y=+0.5) of the CRISM pixel boundries. This vector 
%     should be defined in the same domain as that of "pos_mro_wrt_mars"
%   Ncrism: the number of CRISM cross-track pixels. (640 with no binning)
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
%   crismPxl_sranges_ap: [2 x Ncrism] 
%     crismPxl_sranges_ap(1,i):crismPxl_sranges_ap(2,i) is the sample range 
%     enclosing pixel i. The sample index values are based on the subimage,
%     defined by msldemc_hdr, of the MSLDEMdata.
%   crismPxl_lranges_ap: [2 x Ncrism] 
%     crismPxl_lranges_ap(1,i):crismPxl_lranges_ap(2,i) is the line range 
%     enclosing pixel i. The line index values are based on the subimage,
%     defined by msldemc_hdr, of the MSLDEMdata.
%
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>

[r_mint,lon_mint,lat_mint] = cspice_surfpt_reclat_mex(pos_mro_wrt_mars, ...
    pmc_pxlvrtcs_top,radius_min,radius_min,radius_min);
[r_maxt,lon_maxt,lat_maxt] = cspice_surfpt_reclat_mex(pos_mro_wrt_mars, ...
    pmc_pxlvrtcs_top,radius_max,radius_max,radius_max);
[r_minb,lon_minb,lat_minb] = cspice_surfpt_reclat_mex(pos_mro_wrt_mars, ...
    pmc_pxlvrtcs_btm,radius_min,radius_min,radius_min);
[r_maxb,lon_maxb,lat_maxb] = cspice_surfpt_reclat_mex(pos_mro_wrt_mars, ...
    pmc_pxlvrtcs_btm,radius_max,radius_max,radius_max);

lat_stack = cat(1,lat_mint,lat_maxt,lat_minb,lat_maxb);
lat_min = min(lat_stack,[],1);
lat_max = max(lat_stack,[],1);
lon_stack = cat(1,lon_mint,lon_maxt,lon_minb,lon_maxb);
lon_min = min(lon_stack,[],1);
lon_max = max(lon_stack,[],1);

lon_min_crism = nan(1,Ncrism); lon_max_crism = nan(1,Ncrism);
lat_min_crism = nan(1,Ncrism); lat_max_crism = nan(1,Ncrism);
for n=1:640
    lon_min_crism(n) = min(lon_min(n),lon_min(n+1));
    lon_max_crism(n) = max(lon_max(n),lon_max(n+1));
    lat_min_crism(n) = min(lat_min(n),lat_min(n+1));
    lat_max_crism(n) = max(lat_max(n),lat_max(n+1));
end
%         
% this indicies are associated with msldemc_radius.
crismPxl_sranges_ap = [ floor(MSLDEMdata.lon2x(rad2deg(lon_min_crism))); ...
    ceil(MSLDEMdata.lon2x(rad2deg(lon_max_crism))) ] - msldemc_hdr.sample_offset;
crismPxl_lranges_ap = [ floor(MSLDEMdata.lat2y(rad2deg(lat_max_crism))); ...
    ceil(MSLDEMdata.lat2y(rad2deg(lat_min_crism))) ] - msldemc_hdr.line_offset;
crismPxl_sranges_ap(1,:) = max(crismPxl_sranges_ap(1,:)-1,1);
crismPxl_sranges_ap(2,:) = min(crismPxl_sranges_ap(2,:)+1,msldemc_hdr.samples);
crismPxl_lranges_ap(1,:) = max(crismPxl_lranges_ap(1,:)-1,1);
crismPxl_lranges_ap(2,:) = min(crismPxl_lranges_ap(2,:)+1,msldemc_hdr.lines);

end