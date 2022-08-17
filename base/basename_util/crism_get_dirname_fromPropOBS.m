function [dirname] = crism_get_dirname_fromPropOBS(propOBS)
% [dirname] = crism_get_dirname_fromPropOBS(propOBS)
%   get dirname from property struct of observation
%  INPUT
%    propOBS: property struct of the observation
%  OUTPUT
%    dirname: string, like FRT0000B6F1

[obs_id_strpadded] = crism_pad_obs_id(propOBS.obs_id);
dirname = sprintf('%3s%08s',propOBS.obs_class_type,obs_id_strpadded);

end