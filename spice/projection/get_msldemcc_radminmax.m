function [msldemcc_hdr,radius_minij,radius_maxij] = ... 
    get_msldemcc_radminmax(rotate,pmc_fovbndvrtcs,pos_mro_wrt_mars, ...
    radius_min,radius_max,MSLDEMdata,msldemc_hdr, ...
    radius_min_l,radius_min_c,radius_max_l,radius_max_c)
% [msldemcc_hdr,radius_minij,radius_maxij] = ... 
%     get_msldemcc_radminmax(rotate,pmc_fovbndvrtcs,pos_mro_wrt_mars, ...
%     radius_min,radius_max,MSLDEMdata,msldemc_hdr, ...
%     radius_min_l,radius_min_c,radius_max_l,radius_max_c)
%
% INPUTS
%   rotate: 3 x 3 rotation matrix
%     convert "pmc_fov_bndvrtcs" to the IAU_Mars coordinate system.
%   pmc_fovbndvrtcs: 3 x 4 vectors
%     columns are vertex vectors of the total FOV in the sensor fixed
%     coordinate system.
%   pos_mro_wrt_mars: 3 dimensional vector
%     position of the MRO in the IAU_Mars coordinate system.
%   radius_min: scalar
%     lower bound of the radius in the image region
%   radius_max: scalar
%     upper boudn of the radius in the image region
%   MSLDEMdata: MSLGaleMosaic obj
%   msldemc_hdr: struct having following fields
%     samples
%     lines
%     sample_offset
%     line_offset
%   radius_min_l: vector with the length of msldemc_hdr.lines
%     minimum radii along lines
%   radius_min_c: vector with the length of msldemc_hdr.samples
%     minimum radii along columns
%   radius_max_l: vector with the length of msldemc_hdr.lines
%     maximum radii along lines
%   radius_max_c: vector with the length of msldemc_hdr.samples
%     maximum radii along columns
% 
% OUTPUTS
%   msldemcc_hdr: struct having following fields
%      samples
%      lines
%      sample_offset
%      line_offset
%     offsets are based on msldemc
%   radius_minij: scalar, 
%     updated lower bound of the radius in the image region
%   radius_maxij: scalar, 
%     updated upper bound of the radius in the image region


% rotate FOV boundary vertices
pmc_fovbndvrtcs_iaumars_etemit = rotate * pmc_fovbndvrtcs;
% tic; 
[msldemcc_hdr] = crism_get_msldemcc_hdr_wRadiusMaxMin( ...
    pos_mro_wrt_mars,pmc_fovbndvrtcs_iaumars_etemit, ...
    radius_min,radius_max,MSLDEMdata, ...
    msldemc_hdr);
% further refine max and min radius based on the smaller enclosing
% region.
msldemcc_s1   = msldemcc_hdr.sample_offset+1;
msldemcc_send = msldemcc_hdr.sample_offset+msldemcc_hdr.samples;
msldemcc_l1   = msldemcc_hdr.line_offset+1;
msldemcc_lend = msldemcc_hdr.line_offset+msldemcc_hdr.lines;
radius_minij = max(min(radius_min_l(msldemcc_l1:msldemcc_lend)),min(radius_min_c(msldemcc_s1:msldemcc_send)));
radius_maxij = min(max(radius_max_l(msldemcc_l1:msldemcc_lend)),max(radius_max_c(msldemcc_s1:msldemcc_send)));

end