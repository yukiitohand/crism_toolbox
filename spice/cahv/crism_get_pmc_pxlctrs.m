function [pmc_pxlctrs] = crism_get_pmc_pxlctrs(crism_camera_info,cahv_mdl,binx)
% [pmc_pxlctrs] = crism_get_pmc_pxlctrs(crism_camera_info,cahv_mdl,binx)
% Get (P-C) pointing vector for the CRISM pixel centers
% INPUTS
%  crism_camera_info: struct, output of "crism_ik_kernel_load"
%  cahv_mdl         : CAHV_MODEL class obj, cahv_mdl for the measurement
%  binx             : binning width {1,2,5,10}
% OUTPUTS
%  pmc_pxlctrs: [3 x (Ncrism)]
%     (P-C) associated with the pixel centers. Ncrism is the number of 
%     CRISM cross-track pixels. (640 with no binning)
%
% 
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>

x = 0:639;

h = fspecial('average',[1,binx]); % convolution vector
xbinx = conv(x,h,'valid'); % take convolution and 
xbinx = xbinx(1:binx:end);

[pmc_pxlctrs] = crism_cahv_get_pmc([xbinx;zeros(size(xbinx))], ...
    crism_camera_info,cahv_mdl);


% a0_ref = crism_camera_info.ref_camera_coeff(2);
% a1_ref = crism_camera_info.ref_camera_coeff(3);
% 
% % line of sight angles
% los_angles = a0_ref + a1_ref * crism_camera_info.xtrck_smpls;
% 
% samples = length(crism_camera_info.xtrck_smpls);
% pmc_pxlctr = nan(3,samples);
% for si = 1:samples
%     losa = los_angles(si);
%     cos_losa = cosd(losa); sin_losa = sind(losa);
%     rot_mat_losa = [...
%         cos_losa   0   sin_losa;
%                0   1          0;
%        -sin_losa   0   cos_losa];
%     pmc_pxlctr(:,si) = rot_mat_losa * cahv_mdl.A';
% end


end