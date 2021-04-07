function [pmc_fovbndvrtcs] = crism_get_pmc_fovbndvrtcs(crism_camera_info,cahv_mdl,varargin)
% [pmc_fovbndvrtcs] = crism_get_pmc_fovbndvrtcs(crism_camera_info,cahv_mdl)
% Get (P-C) pointing vector of the vertices of the CRISM rectangular FOV.
% INPUTS
%  crism_camera_info: struct, output of "crism_ik_kernel_load"
%  cahv_mdl         : CAHV_MODEL class obj, cahv_mdl for the measurement
% OUTPUTS
%  pmc_fovbndvrtcs: [3 x (Ncrism+1)]
%     (P-C) associated with the four vertices of the rectangular shape of
%     the CRISM FOV. 
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
% 
Ncrism = 640;
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
                [pmc_edgpxlctrs] = crism_cahv_get_pmc_angularx( ...
                    [  0 639;   ...
                       0   0],  ...
                    crism_camera_info,cahv_mdl,'PROJ_MODE',proj_mode_ctr);
                % project the pmc at 0 and 639 onto cahv model image plane
                xy_ctr_cahv = cahv_mdl.get_xy_from_p_minus_c(pmc_edgpxlctrs);

                d = 0.5+mrgn;
                % Get pmc 
                [pmc_fovbndvrtcs] = cahv_mdl.get_p_minus_c_from_xy(...
                        [xy_ctr_cahv(1,1)-d xy_ctr_cahv(1,1)-d xy_ctr_cahv(1,2)+d xy_ctr_cahv(1,2)+d;   ...
                               -d                  d                  d                 -d           ]);

            case 'ANGULARX'
                d = 0.5+mrgn;
                [pmc_fovbndvrtcs] = crism_cahv_get_pmc_angularx( ...
                    [ -d -d 639+d 639+d;   ...
                      -d  d   d    -d   ] , ...
                    crism_camera_info,cahv_mdl);
                
            case 'ANGULARXY'
                d = 0.5+mrgn;
                [pmc_fovbndvrtcs] = crism_cahv_get_pmc_angularxy( ...
                    [ -d -d 639+d 639+d;   ...
                      -d  d   d    -d   ] , ...
                    crism_camera_info,cahv_mdl);
            otherwise
                error('The combination PROJ_MODE_CTR:%s PROJ_MODE_VRTCS:%s is not implemented', ...
                    proj_mode_ctr,proj_mode_vrtcs);
        end
    otherwise
        error('The combination PROJ_MODE_CTR:%s PROJ_MODE_VRTCS:%s is not implemented', ...
            proj_mode_ctr,proj_mode_vrtcs);
end

end
