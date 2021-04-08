function [pmc_pxlctrs] = crism_get_pmc_pxlctrs(crism_camera_info,cahv_mdl,varargin)
% [pmc_pxlctrs] = crism_get_pmc_pxlctrs(crism_camera_info,cahv_mdl,binx)
% Get (P-C) pointing vector for the CRISM pixel centers
% INPUTS
%  crism_camera_info: struct, output of "crism_ik_kernel_load"
%  cahv_mdl         : CAHV_MODEL class obj, cahv_mdl for the measurement
% OUTPUTS
%  pmc_pxlctrs: [3 x (Ncrism)]
%     (P-C) associated with the pixel centers. Ncrism is the number of 
%     CRISM cross-track pixels. (640 with no binning)
% OPTIONAL Parameters
%   'PROJ_MODE': projection mode, either of {'ANGULARX','PLANAR','ANGULARXY'}
%     'ANGULARX': angular projection only in the cross track direction
%     'ANGULARXY': angular projection both in the cross and along track
%     directions.
%     'PLANAR': planar projection using CAHV model.
%     (default) 'ANGULARX'
% 
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>

proj_mode = 'ANGULARX'; % {'ANGULARX','ANGULARXY','PLANE'}
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'PROJ_MODE'
                proj_mode = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});   
        end
    end
end

x = 0:639;
binx = 1;
h = fspecial('average',[1,binx]); % convolution vector
xbinx = conv(x,h,'valid'); % take convolution and 
xbinx = xbinx(1:binx:end);

switch upper(proj_mode)
    case {'ANGULARX','ANGULARXY'}
        [pmc_pxlctrs] = crism_cahv_get_pmc_angularx([xbinx;zeros(size(xbinx))], ...
            crism_camera_info,cahv_mdl);
    case 'PLANAR'
        [pmc_pxlctrs] = cahv_mdl.get_p_minus_c_from_xy([xbinx;zeros(size(xbinx))]);
    otherwise
        error('Undefined PROJ_MODE %s',proj_mode);
end


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