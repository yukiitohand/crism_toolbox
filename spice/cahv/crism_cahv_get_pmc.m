function [pmc] = crism_cahv_get_pmc(xy,crism_camera_info,cahv_mdl,varargin)
% [pmc] = crism_cahv_get_pmc(xy,crism_camera_info,cahv_mdl,varargin)
% Get (P-C) vectors for given xy coordinate in the angular pixel coordinate
% in the x (cross-track) direction and planar coordinate in the y 
% (vertical) direction. The coordinate is defined by the a0 and a1
% parameters stored in the crism_camera_info. 
% INPUTS
%  xy: [1 x 2] vector or [ * x 2] vector, x and y coordinate for which
%      (P-C) is calculated.
%  crism_camera_info: struct, output of "crism_ik_kernel_load"
%  cahv_mdl         : CAHV_MODEL class obj, cahv_mdl for the measurement
% OUTPUTS
%  pmc: [1 x 3] or [ * x 3]
%      (P-C) vector, normalized vectors.
%   ""

if any(cahv_mdl.A~=[0 0 1]) || any(cahv_mdl.Hdash~=[1 0 0])
    error(['CAHV_MDL needs to be defined in the CRISM IR coordinate' ...
        'A=[0 0 1] Hd=[1 0 0] Vd=[0 1 0]' ...
        'Since this function uses rotational matrix for rotation.']);
end

if length(xy)==2 && isrow(xy)
    xy_isrow = true;
    xy = reshape(xy,2,1);
else
    xy_isrow = false;
end

Npmc = size(xy,2);

a0_ref = crism_camera_info.ref_camera_coeff(2);
a1_ref = crism_camera_info.ref_camera_coeff(3);

% line of sight angles
los_angles = a0_ref + a1_ref * xy(1,:);

pmc = nan(3,Npmc);
for si = 1:Npmc
    losa = los_angles(si);
    cos_losa = cosd(losa); sin_losa = sind(losa);
    rot_mat_losa = [...
        cos_losa   0   sin_losa;
               0   1          0;
       -sin_losa   0   cos_losa];
    pmc(:,si) = rot_mat_losa * cahv_mdl.A';
end

pmc = pmc ./ (cahv_mdl.A*pmc);

v = xy(2,:) ./ cahv_mdl.vs .* cahv_mdl.Vdash';

pmc = pmc + v;

pmc = pmc ./ sqrt(sum(pmc.^2,1));

if xy_isrow
    pmc = reshape(pmc,1,3);
end


end