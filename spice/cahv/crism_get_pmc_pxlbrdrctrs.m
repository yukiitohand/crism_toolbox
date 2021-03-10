function [pmc_pxlbrdrctrs] = crism_get_pmc_pxlbrdrctrs(crism_camera_info,cahv_mdl,binx)
% [pmc_pxlbrdrctrs] = crism_get_pmc_pxlbrdrctrs(crism_camera_info,cahv_mdl,binx)
% Get (P-C) pointing vector for the center of the border of the CRISM
% pixels.
% INPUTS
%  crism_camera_info: struct, output of "crism_ik_kernel_load"
%  cahv_mdl         : CAHV_MODEL class obj, cahv_mdl for the measurement
%  binx             : binning width {1,2,5,10}
% OUTPUTS
%  pmc_pxlbrdrctrs: [3 x (Ncrism+1)]
%     (P-C) associated with the center of pixel borders (y=0). Ncrism is 
%     the number of CRISM cross-track pixels. (640 with no binning)
%
% =========================================================================
%   Pixel border centers (x) with no binning 
% =========================================================================
%  
%   -|--> X
%    |
%  Y v
%          -0.5     0.5     1.5     2.5       637.5   638.5   639.5
%        
%    -0.5     ------- ------- ------- -        - ------- ------- 
%            |       |       |       |          |       |       |
%       0    x       x       x       x   ...    x       x       x 
%            |       |       |       |          |       |       |
%     0.5     ------- ------- ------- -        - ------- ------- 
%
%
% =========================================================================
%   Pixel border centers (x) with binning x2
% =========================================================================
%   -|--> X
%    |
%  Y v
%          -0.5             1.5               637.5           639.5
%        
%    -0.5     --------------- ---------        - ---------------
%            |               |                  |               |
%       0    x       +       x       +   ...    x       +       x
%            |               |                  |               |
%     0.5     --------------- ---------        - ---------------
%
% 
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>

x_brd = -0.5:binx:639.5;
[pmc_pxlbrdrctrs] = crism_cahv_get_pmc([x_brd;zeros(size(x_brd))], ...
    crism_camera_info,cahv_mdl);

end