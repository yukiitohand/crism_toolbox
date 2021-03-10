function [cahv_mdl] = crism_get_cahv_mdl_generic(crism_camera_info)

PROC_MODE = 'QUATERNION';
% mode using rotation matrix is not fully supported yet.

switch upper(crism_camera_info.sensor_id)
    case 'S'
        boresight_vec = crism_camera_info.krnl_info.INS_74017_BORESIGHT; 
        slitdir_vec = crism_camera_info.krnl_info.INS_74017_SLIT_DIRECTION;
        ref_vec = crism_camera_info.krnl_info.INS_74017_FOV_REF_VECTOR;
        ref_fov_ang = crism_camera_info.krnl_info.INS_74017_FOV_REF_ANGLE;
        ref_fov_unit = crism_camera_info.krnl_info.INS_74017_FOV_ANGLE_UNITS;
    case 'L'
        boresight_vec = crism_camera_info.krnl_info.INS_74018_BORESIGHT;
        slitdir_vec = crism_camera_info.krnl_info.INS_74018_SLIT_DIRECTION;
        ref_vec = crism_camera_info.krnl_info.INS_74018_FOV_REF_VECTOR;
        ref_fov_ang = crism_camera_info.krnl_info.INS_74018_FOV_REF_ANGLE;
        ref_fov_unit = crism_camera_info.krnl_info.INS_74018_FOV_ANGLE_UNITS;
        
end
% normalization
ref_vec = ref_vec / norm(ref_vec,2);
boresight_vec = boresight_vec / norm(boresight_vec,2);
slitdir_vec = slitdir_vec / norm(slitdir_vec,2);
% obtain each direction
Hdash = cross(ref_vec,boresight_vec); % rotation axis for REF_VEC
Hdash = Hdash / norm(Hdash,2); % support when ref_vec is not perpendicular to boresight.
Vdash = cross(boresight_vec,Hdash); % rotation axis for SLIT DIRECTION
A = boresight_vec;
HdVdA = [Hdash Vdash A];
slit_rotaxis = cross(boresight_vec,slitdir_vec);

% hc is same for one band.
a0_ref = crism_camera_info.ref_camera_coeff(2);
a1_ref = crism_camera_info.ref_camera_coeff(3);
hc = -a0_ref/a1_ref;

% Other CAHV model would be different for the cross track samples you will
% refer to. This is because the samples are defined with ifov ANGLES, not
% spatial coordinate on the projected camera plane.
ref_losa_sample = 200;
theta_rlosa = a0_ref + a1_ref .* ref_losa_sample;
% consider the rotation around the second axis.
switch PROC_MODE
    case 'QUATERNION'
        theta_rlosa_half = theta_rlosa * 0.5;
        sin_rlosah = sind(theta_rlosa_half);
        q234 = slit_rotaxis*sin_rlosah;
        q = quaternion(cosd(theta_rlosa_half), q234(1),q234(2),q234(3));
        ifov_vec_rlosa = rotatepoint(q, A);
        ifov_vec_rlosa = reshape(ifov_vec_rlosa,3,1);
    case 'ROTATION_MATRIX'
        % following computation may not work if the slit direction is not
        % perpendicular to the plane spanned by BORESIGHT and REV_VEC.
        cos_rlosa = cosd(theta_rlosa); sin_rlosa = sind(theta_rlosa);
        rot_mat = [
            cos_rlosa   0   sin_rlosa;
                    0   1           0;
           -sin_rlosa   0   cos_rlosa];
        ifov_vec_rlosa = HdVdA * rot_mat*boresight_vec';
end

% inversely obtain hc and hs
hs = (A * ifov_vec_rlosa) ./ (Hdash * ifov_vec_rlosa) .* (ref_losa_sample-hc);

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

switch PROC_MODE
    case 'QUATERNION'
        theta_ref_half = theta_ref * 0.5;
        sin_refh = sin(theta_ref_half);
        q234 = sin_refh * Hdash;
        q = quaternion(cos(theta_ref_half),q234(1),q234(2),q234(3));
        ifov_vec_ref = rotatepoint(q, boresight_vec);
        ifov_vec_ref = reshape(ifov_vec_ref,3,1);
    case 'ROTATION_MATRIX'
        
end

vs = (A * ifov_vec_ref) ./ (Vdash * ifov_vec_ref) .* (-0.5-vc);

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