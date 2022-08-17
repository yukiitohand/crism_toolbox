function [cahv_mdl] = crism_get_cahv_mdl_adhoc_plane(crism_camera_info)

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

% Take the Line-of-Sight angles (LOSA) as its tangent (tan(LOSA)), assuming
% that the angles are small (tan(x) is nearly equal to x for a small x).
x = [0 639];
xmhc = x-hc;
[xmhc_max,i] = max(abs(xmhc));
xmhc = xmhc(i); x = x(i);
theta_rlosa = a0_ref + a1_ref .* x;

% inversely obtain hs
hs = xmhc ./ deg2rad(theta_rlosa);

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
cos_ref = cos(theta_ref); sin_ref = sin(theta_ref);
rot_mat_ref = [...
    1       0        0;
    0 cos_ref -sin_ref;
    0 sin_ref  cos_ref];
ifov_vec_ref = rot_mat_ref * A';
% rotating the boresight vector along the 
vs = ifov_vec_ref(3) ./ ifov_vec_ref(2) .* (-0.5-vc);

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