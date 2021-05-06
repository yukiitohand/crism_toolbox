function [crismPxl_sranges_ap,crismPxl_lranges_ap] ...
    = crism_get_pxlslranges_wRadiusMaxMin_v2(pos_mro_wrt_mars,...
    pmc_pxlvrtcsCell, ...
    radius_min,radius_max,MSLDEMdata,msldemc_hdr)
% [crismPxl_sranges_ap,crismPxl_lranges_ap] ...
%     = crism_get_pxlslranges_wRadiusMaxMin_v2(pos_mro_wrt_mars,...
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
%   pmc_pxlvrtcsCell : cell array [Ncrism] Each of the cell elements has 
%     double four (P-C) pointing vectors of the vertices of the associated 
%     CRISM pixel rectangle. This vector should be defined in the same 
%     domain as that of "pos_mro_wrt_mars"
%   radius_min      : double minimum radius within the subimage defind by 
%     msldemc_hdr (needs to be smaller than the actual minimum)
%   radius_max      : double maximum radius within the subimage defind by 
%     msldemc_hdr (needs to be larger than the actual minimum)
%   MSLDEMdata   : MSLGaleMosaicRadius_v3 class obj MSL Radius data.
%   msldemc_hdr: struct with the following four fields
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

PROC_MODE = 'MEX';

switch upper(PROC_MODE)
    case 'NORMAL'
        Ncrism = 640;
        lon_min_crism = nan(1,Ncrism); lon_max_crism = nan(1,Ncrism);
        lat_min_crism = nan(1,Ncrism); lat_max_crism = nan(1,Ncrism);
        for n=1:640
            [r_mint,lon_minn,lat_minn] = cspice_surfpt_reclat_mex(pos_mro_wrt_mars, ...
                pmc_pxlvrtcsCell{n},radius_min,radius_min,radius_min);
            [r_maxt,lon_maxn,lat_maxn] = cspice_surfpt_reclat_mex(pos_mro_wrt_mars, ...
                pmc_pxlvrtcsCell{n},radius_max,radius_max,radius_max);
            lat_stack = cat(2,lat_minn,lat_maxn);
            lat_min_crism(n) = min(lat_stack,[],2);
            lat_max_crism(n) = max(lat_stack,[],2);
            lon_stack = cat(2,lon_minn,lon_maxn);
            lon_min_crism(n) = min(lon_stack,[],2);
            lon_max_crism(n)= max(lon_stack,[],2);
        end
        lon_min_crism = rad2deg(lon_min_crism);
        lon_max_crism = rad2deg(lon_max_crism);
        lat_min_crism = rad2deg(lat_min_crism);
        lon_max_crism = rad2deg(lon_max_crism);
    case 'MEX'
        [lon_min_crism,lon_max_crism,lat_min_crism,lat_max_crism] = ...
            crism_gale_get_lonlatwndw_wRadiusMaxMin_mex( ...
            pos_mro_wrt_mars,pmc_pxlvrtcsCell,radius_min,radius_max);
    otherwise
        error('Undefined PROC_MODE %s',PROC_MODE);
end

%         
% this indicies are associated with msldemc_radius.
crismPxl_sranges_ap = [ floor(MSLDEMdata.lon2x(lon_min_crism)); ...
    ceil(MSLDEMdata.lon2x(lon_max_crism)) ] - msldemc_hdr.sample_offset;
crismPxl_lranges_ap = [ floor(MSLDEMdata.lat2y(lat_max_crism)); ...
    ceil(MSLDEMdata.lat2y(lat_min_crism)) ] - msldemc_hdr.line_offset;

% one more pixel is taken in every direction for potential computation of 
% hidden points using the triangulation of DTM.
crismPxl_sranges_ap(1,:) = max(crismPxl_sranges_ap(1,:)-1,1);
crismPxl_sranges_ap(2,:) = min(crismPxl_sranges_ap(2,:)+1,msldemc_hdr.samples);
crismPxl_lranges_ap(1,:) = max(crismPxl_lranges_ap(1,:)-1,1);
crismPxl_lranges_ap(2,:) = min(crismPxl_lranges_ap(2,:)+1,msldemc_hdr.lines);

end
