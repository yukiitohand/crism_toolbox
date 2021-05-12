function [cahv_mdl] = crism_get_cahv_mdl_adhoc_v2(crism_camera_info)

A = [0 0 1];
Hdash = [1 0 0];
Vdash = [0 1 0];

switch upper(crism_camera_info.sensor_id)
    case 'S'
        ref_fov_ang = crism_camera_info.krnl_info.INS_74017_FOV_REF_ANGLE;
        ref_fov_unit = crism_camera_info.krnl_info.INS_74017_FOV_ANGLE_UNITS;
        
    case 'L'
        ref_fov_ang = crism_camera_info.krnl_info.INS_74018_FOV_REF_ANGLE;
        ref_fov_unit = crism_camera_info.krnl_info.INS_74018_FOV_ANGLE_UNITS;

end


% hc is same for one band.
a0_ref = crism_camera_info.ref_camera_coeff(2);
a1_ref = crism_camera_info.ref_camera_coeff(3);
hc = -a0_ref/a1_ref;

% Other CAHV model would be different for the cross track samples you will
% refer to. This is because the samples are defined with ifov ANGLES, not
% spatial coordinate on the projected camera plane.
% reference line-of-sight angle
ref_losa_sample = 200; 
% theta for reference line-of-sight angle
theta_rlosa = a0_ref + a1_ref .* ref_losa_sample;
hs = (ref_losa_sample-hc)/tand(theta_rlosa);


%% V direction
vc = 0;
switch upper(ref_fov_unit)
    case 'RADIANS'
        theta_ref = ref_fov_ang;
    case 'DGREES'
        theta_ref = deg2rad(ref_fov_ang);
    otherwise 
        error('Undefined V_FOV_UNIT %s',ref_fov_unit);
end
% rotation around x axis
vs = 0.5/tan(theta_ref);


%%
H = hs * Hdash + hc * A;
V = vs * Vdash + vc * A;
cahv_mdl = CAHV_MODEL();
cahv_mdl.C = [0 0 0];
cahv_mdl.A = A;
cahv_mdl.H = H;
cahv_mdl.V = V;
cahv_mdl.Hdash = Hdash;
cahv_mdl.Vdash = Vdash;
cahv_mdl.hs = hs;
cahv_mdl.vs = vs;
cahv_mdl.hc = hc;
cahv_mdl.vc = vc;



end