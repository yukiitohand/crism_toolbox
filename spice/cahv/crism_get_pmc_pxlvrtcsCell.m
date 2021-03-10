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
%
Ncrism = 640;
mrgn = 0;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MARGIN'
                mrgn = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});   
        end
    end
end

x_ctr = 0:639;
[pmc_pxlctrs] = crism_cahv_get_pmc( [x_ctr;zeros(size(x_ctr))], ...
    crism_camera_info,cahv_mdl);

x_ctr_cahv = cahv_mdl.get_xy_from_p_minus_c(pmc_pxlctrs);

d = 0.5+mrgn;

pmc_pxlvrtcsCell = cell(1,Ncrism);
y_brdrtop = -d; y_brdrbtm = d;
for i=1:Ncrism
    x_ctr_cahv_i = x_ctr_cahv(i);
    x_brdrleft  = x_ctr_cahv_i - d;
    x_brdrright = x_ctr_cahv_i + d;
    [pmc_pxlvrtcsi] = crism_cahv_get_pmc(...
        [x_brdrleft x_brdrleft x_brdrright x_brdrright;   ...
         y_brdrtop  y_brdrbtm  y_brdrbtm   y_brdrtop   ], ...
        crism_camera_info,cahv_mdl);
    pmc_pxlvrtcsCell{i} = pmc_pxlvrtcsi;
end

end