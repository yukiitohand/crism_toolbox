function [pmc_pxlvrtcs_top,pmc_pxlvrtcs_btm] = crism_get_pmc_pxlvrtcs( ...
    crism_camera_info,cahv_mdl,binx)
% [pmc_pxlvrtcs_top,pmc_pxlvrtcs_btm] = crism_get_pmc_pxlvrtcs( ...
%     TRRdata,crism_camera_info,cahv_mdl)
% Get (P-C) pointing vector for the CRISM pixel vertices.
% INPUTS
%  crism_camera_info: struct, output of "crism_ik_kernel_load"
%  cahv_mdl         : CAHV_MODEL class obj, cahv_mdl for the measurement
%  binx             : binning width {1,2,5,10}
% OUTPUTS
%  pmc_pxlvrtcs_top: [3 x (Ncrism+1)]
%     (P-C) associated with the pixel vertices with y=-0.5. Ncrism is the
%     number of CRISM cross-track pixels. (640 with no binning)
%  pmc_pxlvrtcs_btm: [3 x (Ncrism+1)]
%     (P-C) associated with the pixel vertices with y=+0.5. Ncrism is the
%     number of CRISM cross-track pixels. (640 with no binning)
%
% =========================================================================
%   Pixel vertices (x) with no binning 
% =========================================================================
%  Vertices with y=-0.5 corresponds to "pmc_pxlvrtx_top" and those with
%  y=0.5 does to "pmc_pxlvrtx_btm".
%
%   -|--> X
%    |
%  Y v
%          -0.5     0.5     1.5     2.5       637.5   638.5   639.5
%        
%    -0.5    x-------x-------x-------x-        -x-------x-------x
%            |       |       |       |          |       |       |
%       0    |   +   |   +   |   +   |   ...    |   +   |   +   |
%            |       |       |       |          |       |       |
%     0.5    x-------x-------x-------x-        -x-------x-------x
%
%
% =========================================================================
%   Pixel vertices (x) with binning x2
% =========================================================================
%   -|--> X
%    |
%  Y v
%          -0.5             1.5               637.5           639.5
%        
%    -0.5    x---------------x---------        -x---------------x
%            |               |                  |               |
%       0    |       +       |       +   ...    |       +       |
%            |               |                  |               |
%     0.5    x---------------x---------        -x---------------x
%
% 

x_brd = -0.5:binx:639.5;
[pmc_pxlvrtcs_top] = crism_cahv_get_pmc(...
    [x_brd;-0.5*ones(size(x_brd))], crism_camera_info,cahv_mdl);
[pmc_pxlvrtcs_btm] = crism_cahv_get_pmc(...
    [x_brd; 0.5*ones(size(x_brd))], crism_camera_info,cahv_mdl);

end