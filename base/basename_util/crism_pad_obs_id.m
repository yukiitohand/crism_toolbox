function [obs_id_strpadded] = pad_obs_id(obs_id)
% [obs_id_strpadded] = pad_obs_id(obs_id)
%  convert obs_id in string format or numeric format to 0 padded string
%  format
%  INPUT
%    obs_id: observation id, numeric or string
%  OUTPUT
%    obs_id_strpadded: padded string of obs_id
%      something like 0000B6F1

if isnumeric(obs_id)
    obs_id_strpadded = sprintf('%08X',obs_id);
elseif ischar(obs_id)
    obs_id_strpadded = sprintf('%08s',obs_id);
end