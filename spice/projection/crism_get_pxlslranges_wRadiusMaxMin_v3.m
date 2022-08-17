function [msldemcc_hdr,crismPxl_smplofst_ap, crismPxl_smpls_ap,  ...
    crismPxl_lineofst_ap, crismPxl_lines_ap] ...
    = crism_get_pxlslranges_wRadiusMaxMin_v3(pos_mro_wrt_mars,...
    rotate, pmc_pxlvrtcsCell,radius_min,radius_max,MSLDEMdata,msldemc_hdr)
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
%   rotate: 3 x 3 rotation matrix
%     convert "pmc_fov_bndvrtcs" to the IAU_Mars coordinate system.
%   pmc_pxlvrtcsCell: 1 x 640 cell
%     each cell stores the vertex vectors of the FOV in the sensor fixed
%     coordinate system.
%   radius_min      : double minimum radius within the subimage defind by 
%     msldemc_hdr (needs to be smaller than the actual minimum)
%   radius_max      : double maximum radius within the subimage defind by 
%     msldemc_hdr (needs to be larger than the actual minimum)
%   MSLDEMdata   : MSLGaleMosaicRadius_v3 class obj MSL Radius data.
%   msldemc_hdr: struct having following fields
%     samples
%     lines
%     sample_offset
%     line_offset
%   
%  OUTPUTS
%   msldemcc_hdr: struct having following fields
%      samples
%      lines
%      sample_offset
%      line_offset
%     offsets are based to MSLDEMdata
%  crismPxl_smplofst_ap: int32 [1 x 640], sample offset for each pixel window
%  crismPxl_smpls_ap: int32 [1 x 640], # of samples for each pixel window
%  crismPxl_lineofst_ap: int32 [1 x 640], line offset for each pixel window
%  crismPxl_lines_ap: int32 [1 x 640], # of lines for each pixel window
%     offsets are based to msldemcc_hdr
%
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>


pmc_pxlvrtcsCell_iaumars_etemit = crism_rotate_pmcFOVcell(pmc_pxlvrtcsCell,rotate);

PROC_MODE = 'MEX';

switch upper(PROC_MODE)
    case 'NORMAL'
        Ncrism = 640;
        lon_min_crism = nan(1,Ncrism); lon_max_crism = nan(1,Ncrism);
        lat_min_crism = nan(1,Ncrism); lat_max_crism = nan(1,Ncrism);
        for n=1:640
            [r_mint,lon_minn,lat_minn] = cspice_surfpt_reclat_mex(pos_mro_wrt_mars, ...
                pmc_pxlvrtcsCell_iaumars_etemit{n},radius_min,radius_min,radius_min);
            [r_maxt,lon_maxn,lat_maxn] = cspice_surfpt_reclat_mex(pos_mro_wrt_mars, ...
                pmc_pxlvrtcsCell_iaumars_etemit{n},radius_max,radius_max,radius_max);
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
            pos_mro_wrt_mars,pmc_pxlvrtcsCell_iaumars_etemit,radius_min,radius_max);
    otherwise
        error('Undefined PROC_MODE %s',PROC_MODE);
end
  
% Corresponding MSLDEM image indices are calculated from latitude and
% longitude
crismPxl_srngs_ap = [ floor(MSLDEMdata.lon2x(lon_min_crism)); ...
    ceil(MSLDEMdata.lon2x(lon_max_crism)) ];
crismPxl_lrngs_ap = [ floor(MSLDEMdata.lat2y(lat_max_crism)); ...
    ceil(MSLDEMdata.lat2y(lat_min_crism)) ];

% Get the sample line ranges of msldemc_hdr
s1c   = msldemc_hdr.sample_offset + 1;
sendc = msldemc_hdr.sample_offset + msldemc_hdr.samples;
l1c   = msldemc_hdr.line_offset   + 1;
lendc = msldemc_hdr.line_offset   + msldemc_hdr.lines;

% one more pixel is taken in every direction for potential computation of 
% hidden points using the triangulation of DTM, and cut the outside of
% the subimage defined by msldemc_hdr. msldemc_hdr is considered as a hard 
% boundary.
crismPxl_srngs_ap(1,:) = max(crismPxl_srngs_ap(1,:)-1, s1c  );
crismPxl_srngs_ap(2,:) = min(crismPxl_srngs_ap(2,:)+1, sendc);
crismPxl_lrngs_ap(1,:) = max(crismPxl_lrngs_ap(1,:)-1, l1c  );
crismPxl_lrngs_ap(2,:) = min(crismPxl_lrngs_ap(2,:)+1, lendc);

% so far, crismPxl_srngs_ap and crismPxl_lrngs_ap indices are based to
% MSLDEMdata.

%% create msldemcc_hdr
msldemcc_hdr = [];

% Find out the total region of crismPxl sample line ranges
ss = crismPxl_srngs_ap(:); ll = crismPxl_lrngs_ap(:);
s1cc = min(ss); sendcc = max(ss); l1cc = min(ll); lendcc = max(ll);

% create msldemcc_hdr
msldemcc_hdr.sample_offset = s1cc-1;
msldemcc_hdr.line_offset = l1cc-1;
msldemcc_hdr.samples = sendcc-s1cc+1;
msldemcc_hdr.lines = lendcc-l1cc+1;

% crism pixel sample 
crismPxl_smplofst_ap = int32(crismPxl_srngs_ap(1,:) - s1cc);
crismPxl_lineofst_ap = int32(crismPxl_lrngs_ap(1,:) - l1cc);

crismPxl_smpls_ap = int32(crismPxl_srngs_ap(2,:) - crismPxl_srngs_ap(1,:) + 1);
crismPxl_lines_ap = int32(crismPxl_lrngs_ap(2,:) - crismPxl_lrngs_ap(1,:) + 1);


end