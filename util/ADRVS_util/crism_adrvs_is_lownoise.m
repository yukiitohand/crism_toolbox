function [is_lownoise] = crism_adrvs_is_lownoise(obs_id)
% [is_lownoise] = crism_adrvs_is_lownoise(obs_id)
%  Check if obs_id is listed in the list of low noise images.
[obs_id_short_lownoise] = crism_adrvs_get_obs_id_short_lownoise();
is_lownoise = any(hex2dec(obs_id)==hex2dec(obs_id_short_lownoise));
end