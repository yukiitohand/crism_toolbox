function [ yyyy_doy,obs_classType ] = searchOBSID2YYYY_DOY( obs_id,varargin)
% [ yyyy_doy ] = searchOBSID2YYYY_DOY( OBS_ID,varargin )
% return yyyy_doy and obs_classType for the given obs_id
%
%   Inputs:
%   obs_id: (xxxxxxxx) such as '000094F6', '94F6' or
%           dirname (XXXxxxxxxxx) such as 'FRT000094F6. 
%   Optional Parameters
%

global LUT_OBSID2YYYY_DOY

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})

            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end


% zero-padding if its shorter than 8 characters.
if length(obs_id)<8
    obs_id = pad_obs_id(obs_id);
end
%obs_id = upper(sprintf('%08s',obs_id));
obs_id = upper(obs_id);

ptr = '^[A-Z]{3}[0-9A-F]{8}';
ptr2 = '[0-9A-F]{8}';
if regexp(obs_id,ptr,'ONCE')
    yyyy_doy = LUT_OBSID2YYYY_DOY.(obs_id);
    obs_classType = obs_id(1:3);
elseif regexp(obs_id,ptr2,'ONCE')
    obs_classTypeList = {'FRT','FRS','HRL','HRS','CAL','ICL','FFC','ATO','ATU','MSP','MSW','EPF','TOD','HSV',...
    'LMB','HSP','MSV','CRL','CRM','CRS'};
    i=1; flg = 1;
    while flg
        flnm = [obs_classTypeList{i} obs_id];
        if isfield(LUT_OBSID2YYYY_DOY,flnm)
            yyyy_doy = LUT_OBSID2YYYY_DOY.(flnm);
            obs_classType = obs_classTypeList{i};
            flg = 0;
        elseif i==length(obs_classTypeList)
            error('OBS_ID %s does not exist.',obs_id);
        else
            i = i+1;
        end
    end
end

end

