function [rotate_fix] = crism_proj_get_gcpcor_rotmat(etrec,etemit,gcp_correction_param)
% [rotate_fix] = crism_proj_get_gcpcor_rotmat(etrec,etemit,gcp_correction_param)
%   Using correction parameters derived from GCPs, get the rotation matrix
%   that fixes the attitude of the MRO to satisfy the GCP conditions.
% INPUTS
%  etrec
%  etemit
%  gcp_correction_param: struct having fields
%   etrec
%   etemit
%   rotaxis : rotation axis for which correction is performed by 
%   rotang  : angle in radians for the correction
% OUTPUTS
%  rotate_fix: rotation matrix that fixes the attitude of 
% 

etrec_ref  = cat(1,gcp_correction_param.etrec);
etemit_ref = cat(1,gcp_correction_param.etemit);

% Get the neighboring ref points
i_before = find((etrec_ref-etrec)<=0);
if ~isempty(i_before)
    i_before = i_before(end);
end
i_after  = find((etrec_ref-etrec)>=0);
if ~isempty(i_after)
    i_after  = i_after(1);
end

if isempty(i_before)
    i_before = 1;
    i_after  = 2;
end

Ngcp = length(gcp_correction_param);
if isempty(i_after)
    i_before = Ngcp-1;
    i_after  = Ngcp;
end


if i_before==i_after
    % etrec_refi = etrec_ref(i_before);
    etemit_refi = etemit_ref(i_before);
    [rotate_frombefore] = cspice_pxfrm2( 'IAU_MARS', 'IAU_MARS', etemit_refi, etemit );
    rot_axis_b = rotate_frombefore * gcp_correction_param(i_before).rotaxis';
    theta = gcp_correction_param(i_before).rotang;
    q = axang2quat([rot_axis_b',theta]);
    % [bsight_iaumars_etemit_fix2] = rotation_using_quaternion(rot_axis_b,theta,bsight_iaumars_etemit);
else
    etemit_refi_before = etemit_ref(i_before);
    etemit_refi_after  = etemit_ref(i_after);
    etrec_refi_before  = etrec_ref(i_before);
    etrec_refi_after   = etrec_ref(i_after);
    theta_b = gcp_correction_param(i_before).rotang;
    theta_a = gcp_correction_param(i_after).rotang;
    axis_b  = gcp_correction_param(i_before).rotaxis;
    axis_a  = gcp_correction_param(i_after).rotaxis;
    
    % axis_b is defined in the IAU_MARS cooridnate system at the ephemeris
    % time of "etemit_refi_before"
    % That needs to be converted to the IAU_MARS cooridnate system at the
    % ephemeris time of "etemit"
    [rotate_frombefore] = cspice_pxfrm2( 'IAU_MARS', 'IAU_MARS', etemit_refi_before, etemit );
    rot_axis_b = rotate_frombefore * axis_b';
    [q_b] = axang2quat([rot_axis_b',theta_b]);
    % [q_b] = get_quaternion_from_axis_angle(rot_axis_b,angs(i_before));
    % theta_b = angs(i_before) * (etrec_refi_after-etrec) / (etrec_refi_after-etrec_refi_before);
    % [bsight_iaumars_etemit_fix] = rotation_using_quaternion(rot_axis_b,theta,bsight_iaumars_etemit);
    
    [rotate_fromafter] = cspice_pxfrm2( 'IAU_MARS', 'IAU_MARS', etemit_refi_after, etemit );
    rot_axis_a = rotate_fromafter * axis_a';
    [q_a] = axang2quat([rot_axis_a',theta_a]);
    % [q_a] = get_quaternion_from_axis_angle(rot_axis_a,angs(i_after));
    % theta_a = angs(i_after) * (etrec-etrec_refi_before) / (etrec_refi_after-etrec_refi_before);
    % [bsight_iaumars_etemit_fix2] = rotation_using_quaternion(rot_axis_a,theta,bsight_iaumars_etemit_fix);
    
    % interpolate quaternion
    % interpolation is performed based on etrec, the ephemeris time of the
    % record time.
    t = (etrec-etrec_refi_before) / (etrec_refi_after-etrec_refi_before);
    if t>0 && t<1
        q = slerp(quaternion(q_b),quaternion(q_a),t);
    else
        % Uhhh, extrapolation of the quaternion does not seem to be
        % supported by the MATLAB built-in function "slerp".
        q = slerp_extrap(q_b',q_a',t);
        q = q';
        % theta_b = gcp_correction_param(i_before).rotang * (etrec_refi_after-etrec)  / (etrec_refi_after-etrec_refi_before);
        % theta_a = gcp_correction_param(i_after).rotang  * (etrec-etrec_refi_before) / (etrec_refi_after-etrec_refi_before);
        % [bsight_iaumars_etemit_fix] = rotation_using_quaternion(rot_axis_b,theta_b,bsight_iaumars_etemit);
    end
end

rotate_fix = quat2rotm(q);

end