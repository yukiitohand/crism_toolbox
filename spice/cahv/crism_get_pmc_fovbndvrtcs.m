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
%
% =========================================================================
%   CRISM FOV bounds determined by the four vertices (X) of the rectangle.
% =========================================================================
%  With MARGIN=0,
%  
%   -|--> X
%    |
%  Y v
%          -0.5     0.5     1.5     2.5       637.5   638.5   639.5
%    -0.5    X------- ------- ------- -        - ------- -------X
%            |       |       |       |          |       |       |
%       0    |       |       |       |   ...    |       |       | 
%            |       |       |       |          |       |       |
%     0.5    X------- ------- ------- -        - ------- -------X
%
%
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>
% 

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

[pmc_fovbndvrtcs] = crism_cahv_get_pmc( ...
    [ -0.5-mrgn -0.5-mrgn 639.5+mrgn 639.5+mrgn;   ...
       0.5+mrgn -0.5+mrgn  -0.5-mrgn   0.5+mrgn] , ...
    crism_camera_info,cahv_mdl);

end