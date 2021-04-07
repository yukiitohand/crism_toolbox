function [pmc_pxlvrtcsCell] = crism_get_pmc_pxlvrtcsCell( ...
    crism_camera_info,cahv_mdl,varargin)
% [pmc_pxlvrtcsCell] = crism_get_pmc_pxlvrtcsCell( ...
%     crism_camera_info,cahv_mdl,varargin)
% Get (P-C) pointing vector for each of the CRISM pixel vertices.
% INPUTS
%  crism_camera_info: struct, output of "crism_ik_kernel_load"
%  cahv_mdl         : CAHV_MODEL class obj, cahv_mdl for the measurement
% OUTPUTS
%  pmc_pxlvrtcsCell: cell array [1 x Ncrism]
%     Each cell has the (P-C) associated with the pixel vertices. 
%     Ncrism is the number of CRISM cross-track pixels. (640 with no binning)
% OPTIONAL Parameters
%  "MARGIN": margin width in the both direction
%    (default) 0
%  "PROJ_MODE_CTR": projection mode for the computation of pixel centers
%    (default) "AngularX"
%  "PROJ_MODE_VRTCS": projection mdoe for the computation of the pixel
%  vertexes 
%    (default) "Planar"
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
                x_ctr = 0:639;
                [pmc_pxlctrs] = crism_cahv_get_pmc( [x_ctr;zeros(size(x_ctr))], ...
                    crism_camera_info,cahv_mdl,'PROJ_MODE',proj_mode_ctr);

                xy_ctr_cahv = cahv_mdl.get_xy_from_p_minus_c(pmc_pxlctrs);

                d = 0.5+mrgn;

                pmc_pxlvrtcsCell = cell(1,Ncrism);
                y_brdrtop = -d; y_brdrbtm = d;
                for i=1:Ncrism
                    x_ctr_cahv_i = xy_ctr_cahv(1,i);
                    x_brdrleft  = x_ctr_cahv_i - d;
                    x_brdrright = x_ctr_cahv_i + d;
                    [pmc_pxlvrtcsi] = cahv_mdl.get_p_minus_c_from_xy(...
                        [x_brdrleft x_brdrleft x_brdrright x_brdrright;   ...
                         y_brdrtop  y_brdrbtm  y_brdrbtm   y_brdrtop   ]);
                    pmc_pxlvrtcsCell{i} = pmc_pxlvrtcsi;
                end
            otherwise
                error('The combination PROJ_MODE_CTR:%s PROJ_MODE_VRTCS:%s is not implemented', ...
                    proj_mode_ctr,proj_mode_vrtcs);
        end
    otherwise
        error('The combination PROJ_MODE_CTR:%s PROJ_MODE_VRTCS:%s is not implemented', ...
            proj_mode_ctr,proj_mode_vrtcs);
end

end