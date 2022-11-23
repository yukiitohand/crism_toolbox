function [crism_camera_info] = crism_ik_kernel_load_v2(spicekrnlObj_ik,crismdata_obj,varargin)
% read raw ik kernel. Directory path is automatically resolved by 
% "crism_get_spice_dirpath"
[dirpath_ik_krnl] = spicekrnlObj_ik.dirpath;
fname_ik_krnl = spicekrnlObj_ik.fname_krnl;
fpath_krnl = joinPath(dirpath_ik_krnl,fname_ik_krnl);
krnl_info = spice_textkernel_read(fpath_krnl);

% match information with ROWNUM table.
rownum_crism = crismdata_obj.read_ROWNUM_TABLE();
nB = length(rownum_crism);

switch upper(crismdata_obj.prop.sensor_id)
    case 'S'
        ref_rownum = krnl_info.INS_74017_REFERENCE_BAND;
        actv_idx = find(abs(krnl_info.INS_74017_CAMERA_COEFF(:,2))>1e-16);
        actv_cam_coef = krnl_info.INS_74017_CAMERA_COEFF(actv_idx,:);
    case 'L'
        ref_rownum = krnl_info.INS_74018_REFERENCE_BAND;
        actv_idx = find(abs(krnl_info.INS_74018_CAMERA_COEFF(:,2))>1e-16);
        actv_cam_coef = krnl_info.INS_74018_CAMERA_COEFF(actv_idx,:);
        
    otherwise
        error('Undefined processing of camera info for sensor_id %s',crismdata_obj.prop.sensor_id);
end

camera_coeff = nan(nB,3);
for bi=1:nB
    idxb = find(rownum_crism(bi)==actv_cam_coef(:,1));
    if ~isempty(idxb)
        camera_coeff(bi,:) = actv_cam_coef(idxb,:);
    end
end

ref_band_idx     = find(rownum_crism==ref_rownum);
ref_camera_coeff = camera_coeff(ref_band_idx,:);


crism_camera_info = [];
crism_camera_info.sensor_id        = crismdata_obj.prop.sensor_id;
crism_camera_info.ref_band_idx     = ref_band_idx    ;
crism_camera_info.ref_camera_coeff = ref_camera_coeff;
crism_camera_info.camera_coeff     = camera_coeff    ;
crism_camera_info.krnl_info        = krnl_info; % also stores all the general information
crism_camera_info.rownum           = rownum_crism;

%% next spatial sampling is resolved
xtrck_smpls_full = 0:639;
binx = crismdata_obj.lbl.PIXEL_AVERAGING_WIDTH;
[xtrck_smpls] = crism_bin_image_frames(xtrck_smpls_full,'binx',binx);
crism_camera_info.xtrck_smpls_full = xtrck_smpls_full;
crism_camera_info.xtrck_smpls = xtrck_smpls;

end