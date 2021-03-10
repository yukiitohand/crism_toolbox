function [pmc] = crism_cahv_get_pmc(xy,crism_camera_info,cahv_mdl,varargin)
% [pmc] = crism_cahv_get_pmc(xy,crism_camera_info,cahv_mdl,varargin)
% Get (P-C) vectors for given xy coordinate in the 
% Optional Parameters
%   ""

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