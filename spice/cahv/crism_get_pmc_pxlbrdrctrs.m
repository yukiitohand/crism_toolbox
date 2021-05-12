function [pmc_pxlbrdrctrs] = crism_get_pmc_pxlbrdrctrs( ...
    crism_camera_info,cahv_mdl,varargin)
% [pmc_pxlbrdrctrs] = crism_get_pmc_pxlbrdrctrs( ...
%     crism_camera_info,cahv_mdl,varargin)
% Get (P-C) pointing vector for the center of the border of the CRISM
% pixels.
% INPUTS
%  crism_camera_info: struct, output of "crism_ik_kernel_load"
%  cahv_mdl         : CAHV_MODEL class obj, cahv_mdl for the measurement
% OUTPUTS
%  pmc_pxlbrdrctrs: [3 x (Ncrism+1)]
%     (P-C) associated with the center of pixel borders (y=0). Ncrism is 
%     the number of CRISM cross-track pixels. (640 with no binning)
% OPTIONAL Parameters
%  "MARGIN": margin width in the both direction
%    (default) 0
%  "PROJ_MODE_CTR": projection mode for the computation of pixel centers
%    (default) "AngularX"
%  "PROJ_MODE_VRTCS": projection mdoe for the computation of the pixel
%  vertexes 
%    (default) "Planar"
%
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>

mrgn = 0;
proj_mode_ctr = 'AngularX';
proj_mode_vrtcs = 'Planar';
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MARGIN'
                mrgn = varargin{i+1};
            case 'PROJ_MODE_CTR'
                proj_mode_ctr = varargin{i+1};
            case 'PROJ_MODE_VRTCS'
                proj_mode_vrtcs = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});   
        end
    end
end

switch upper(proj_mode_ctr)
    case 'ANGULARX'
        switch upper(proj_mode_vrtcs)
            case 'PLANAR'
                x = 0:639;
                binx = 1;
                h = fspecial('average',[1,binx]);
                xbinx = conv(x,h,'valid');
                xbinx = xbinx(1:binx:end);
                [pmc_pxlctrs] = crism_cahv_get_pmc_angularx( ... 
                    [xbinx;zeros(size(xbinx))], ...
                    crism_camera_info,cahv_mdl);
                xy_ctr_cahv = cahv_mdl.get_xy_from_p_minus_c(pmc_pxlctrs);
                xy_ctr_cahv_pd = [2*xy_ctr_cahv(1)-xy_ctr_cahv(2) xy_ctr_cahv 2*xy_ctr_cahv(end)-xy_ctr_cahv(end-1)];
                xy_brdr_cahv = 0.5 * (xy_ctr_cahv_pd(2:end) + xy_ctr_cahv_pd(1:end-1));
                xy_brdr_cahv(1) = xy_brdr_cahv(1)-mrgn;
                xy_brdr_cahv(end) = xy_brdr_cahv(end) - mrgn;
                % Get pmc 
                [pmc_pxlbrdrctrs] = cahv_mdl.get_p_minus_c_from_xy(...
                        [xy_brdr_cahv;zeros(size(xy_brdr_cahv))] );
                
            case {'ANGULARX','ANGULARXY'}
                binx = 1;
                x_brd = -0.5:binx:639.5;
                x_brd(1) = x_brd(1) - mrgn;
                x_brd(end) = x_brd(end) + mrgn;
                [pmc_pxlbrdrctrs] = crism_cahv_get_pmc_angularx( ...
                    [x_brd;zeros(size(x_brd))],crism_camera_info,cahv_mdl);
                
            otherwise
                error('The combination PROJ_MODE_CTR:%s PROJ_MODE_VRTCS:%s is not implemented', ...
                    proj_mode_ctr,proj_mode_vrtcs);
        end
    otherwise
        error('The combination PROJ_MODE_CTR:%s PROJ_MODE_VRTCS:%s is not implemented', ...
            proj_mode_ctr,proj_mode_vrtcs);
end



end
