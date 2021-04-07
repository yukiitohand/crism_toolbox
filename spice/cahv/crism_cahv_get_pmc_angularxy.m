function [pmc] = crism_cahv_get_pmc_angularxy(xy,crism_camera_info,cahv_mdl,varargin)
% [pmc] = crism_cahv_get_pmc_angularxy(xy,crism_camera_info,cahv_mdl,varargin)
% Get (P-C) vectors for given xy coordinate in the angular pixel
% coordinate. The coordinate is defined by the a0 and a1 parameters stored
% in the crism_camera_info. In this function, y-coordinate is also
% measured in angular basis. 
% INPUTS
%  xy: [1 x 2] vector or [ * x 2] vector, x and y coordinate for which
%      (P-C) is calculated.
%  crism_camera_info: struct, output of "crism_ik_kernel_load"
%  cahv_mdl         : CAHV_MODEL class obj, cahv_mdl for the measurement
% OUTPUTS
%  pmc: [1 x 3] or [ * x 3]
%      P-C vector
%   ""

if any(cahv_mdl.A~=[0 0 1]) || any(cahv_mdl.Hd~=[1 0 0])
    error(['CAHV_MDL needs to be defined in the CRISM IR coordinate' ...
        'A=[0 0 1] Hd=[1 0 0] Vd=[0 1 0]' ...
        'Since this function uses rotational matrix for rotation.']);
end

switch upper(crism_camera_info.sensor_id)
    case 'S'
        ref_fov_ang = crism_camera_info.krnl_info.INS_74017_FOV_REF_ANGLE;
        ref_fov_unit = crism_camera_info.krnl_info.INS_74017_FOV_ANGLE_UNITS;
        
    case 'L'
        ref_fov_ang = crism_camera_info.krnl_info.INS_74018_FOV_REF_ANGLE;
        ref_fov_unit = crism_camera_info.krnl_info.INS_74018_FOV_ANGLE_UNITS;
end

switch upper(ref_fov_unit)
    case 'RADIANS'
        theta_ref = ref_fov_ang;
    case 'DGREES'
        theta_ref = deg2rad(ref_fov_ang);
    otherwise 
        error('Undefined V_FOV_UNIT %s',ref_fov_unit);
end


%%
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
ref_angles = (xy(2,:) ./ 0.5) .* theta_ref;
% reference angle corresponds to 

pmc = nan(3,Npmc);
for si = 1:Npmc
    losa = los_angles(si);
    cos_losa = cosd(losa); sin_losa = sind(losa);
    rot_mat_losa = [...
        cos_losa   0   sin_losa;
               0   1          0;
       -sin_losa   0   cos_losa];
   
    refa = ref_angles(si);
    cos_refa = cos(refa); sin_refa = sind(refa);
    % rotate -refa radians due to the defined coordinate system.
    rot_mat_refang = [...
           1          0          0;
           0   cos_refa   sin_refa;
           0  -sin_refa   cos_refa];
    pmc(:,si) = rot_mat_losa * rot_mat_refang * cahv_mdl.A';
end

pmc = pmc ./ sqrt(sum(pmc.^2,1));

if xy_isrow
    pmc = reshape(pmc,1,3);
end