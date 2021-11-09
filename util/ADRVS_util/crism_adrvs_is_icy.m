function [is_icy] = crism_adrvs_is_icy(obs_id)
% [is_icy] = crism_adrvs_is_icy(obs_id)
%  Check if obs_id is listed in the list of icy scenes.
[obs_id_short_icy] = crism_adrvs_get_obs_id_short_icy();
is_icy = any(hex2dec(obs_id)==hex2dec(obs_id_short_icy));
end