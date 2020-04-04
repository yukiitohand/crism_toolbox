function [ yyyy_doy,obs_classType ] = crism_searchOBSID2YYYY_DOY_v2( obs_id,varargin)
% [ yyyy_doy ] = crism_searchOBSID2YYYY_DOY_v2( OBS_ID,varargin )
% return yyyy_doy and obs_classType for the given obs_id
%
%   Inputs:
%    obs_id: (xxxxxxxx) such as '000094F6', '94F6' or
%           dirname (XXXxxxxxxxx) such as 'FRT000094F6. 
%   OUTPUTS
%    yyyy_doy: Year (YYYY) and Day of the Year (DOY), e.g., 2007_028
%    obs_classType: OBSERVATION CLASS Type such as 'FRT', 'HRL'
%

global CRISM_INDEX_OBS_CLASS_TYPE CRISM_INDEX_OBS_ID CRISM_INDEX_YYYY CRISM_INDEX_DOY

if isempty(CRISM_INDEX_OBS_CLASS_TYPE)
    error('Perform "crism_init" first to load global variables');
end

if length(obs_id)==11, obs_id = obs_id(4:11); end

obs_id_num = reshape(hex2dec(obs_id),1,[]);
[idx] = find(CRISM_INDEX_OBS_ID==obs_id_num);
obs_classType = CRISM_INDEX_OBS_CLASS_TYPE(idx,:);
yyyy_doy = sprintf('%04d_%03d',CRISM_INDEX_YYYY(idx),CRISM_INDEX_DOY(idx));

end

