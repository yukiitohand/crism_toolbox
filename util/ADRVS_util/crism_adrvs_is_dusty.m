function [is_dusty] = crism_adrvs_is_dusty(obs_id)
% [is_dusty] = crism_adrvs_is_dusty(obs_id)
%  Check if obs_id is listed in the list of dusty scenes.
[obs_id_short_dusty] = crism_adrvs_get_obs_id_short_dusty();
is_dusty = any(hex2dec(obs_id)==hex2dec(obs_id_short_dusty));
end