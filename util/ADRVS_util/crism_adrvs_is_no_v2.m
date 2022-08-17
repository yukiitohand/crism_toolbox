function [is_no_v2] = crism_adrvs_is_no_v2(obs_id)
% [is_no_v2] = crism_adrvs_is_no_v2(obs_id)
%  Check if there exist an ADR VS data associated with TRR2 (v6 of ADR VS
%  data) for obs_id.
[obs_id_short_no_v2] = crism_adrvs_get_obs_id_short_no_v2();
is_no_v2 = any(hex2dec(obs_id)==hex2dec(obs_id_short_no_v2));
end