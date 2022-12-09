function [ yyyy_doy,obs_classType ] = crism_searchOBSID2YYYY_DOY_v2( obs_id )
% [ yyyy_doy ] = crism_searchOBSID2YYYY_DOY_v2( OBS_ID )
% return yyyy_doy and obs_classType for the given obs_id
%
%   Inputs:
%    obs_id: (xxxxxxxx) such as '000094F6', '94F6' or
%           dirname (XXXxxxxxxxx) such as 'FRT000094F6.
%          : you can also cell array of obs_id as an input.
%   OUTPUTS
%    yyyy_doy: Year (YYYY) and Day of the Year (DOY), e.g., 2007_028
%    obs_classType: OBSERVATION CLASS Type such as 'FRT', 'HRL'
%    yyyy_doy and obs_classType will be cell arrrays if the input obs_id is
%    a cell array.
%

global CRISM_INDEX_OBS_CLASS_TYPE CRISM_INDEX_OBS_ID CRISM_INDEX_YYYY CRISM_INDEX_DOY

if isempty(CRISM_INDEX_OBS_CLASS_TYPE)
    error('Perform "crism_init" first to load global variables');
end

if ischar(obs_id)
    if length(obs_id)==11, obs_id = obs_id(4:11); end
    obs_id_num = int32(hex2dec(obs_id));
    [idx_row] = find(CRISM_INDEX_OBS_ID==obs_id_num);
    if isempty(idx_row)
        yyyy_doy = -1;
        obs_classType = -1;
    elseif length(idx_row)==1
        obs_classType = CRISM_INDEX_OBS_CLASS_TYPE(idx_row,:);
        yyyy_doy = sprintf('%04d_%03d',CRISM_INDEX_YYYY(idx_row),CRISM_INDEX_DOY(idx_row));
    else
        obs_classType = cellstr(CRISM_INDEX_OBS_CLASS_TYPE(idx_row,:));
        mtch_unk = strcmpi(obs_classType,'UNK');
        if any(mtch_unk)
            fprintf('Dropping UNK.\n');
            idx_row = idx_row(~mtch_unk);
        end
        obs_classType = cellstr(CRISM_INDEX_OBS_CLASS_TYPE(idx_row,:));
        mtch_epf = strcmpi(obs_classType,'EPF');
        if any(mtch_epf)
            fprintf('Dropping EPF.\n');
            idx_row = idx_row(~mtch_epf);
        end
        if length(idx_row)==1
            yyyy_doy = sprintf('%04d_%03d',CRISM_INDEX_YYYY(idx_row),CRISM_INDEX_DOY(idx_row));
            obs_classType = CRISM_INDEX_OBS_CLASS_TYPE(idx_row,:);
        else
            fprintf('Ambiguity: multiple observation class types are matched: %s\n',strjoin(obs_classType,','));
        end
    end

elseif iscell(obs_id)
    N = length(obs_id);
    for i=1:N
        obs_id_i = obs_id{i};
        if length(obs_id_i)==11, obs_id{i} = obs_id_i(4:11); end
    end
    yyyy_doy = cell(size(obs_id)); [yyyy_doy{:}] = deal('');
    obs_classType = cell(size(obs_id)); [obs_classType{:}] = deal('');
    obs_id_num = reshape(int32(hex2dec(obs_id)),1,[]);
    [idx_row,idx_col] = find(CRISM_INDEX_OBS_ID==obs_id_num);
    obs_classType(idx_col) = cellstr(CRISM_INDEX_OBS_CLASS_TYPE(idx_row,:));
    yyyy_doy(idx_col) = arrayfun(@(x,y)sprintf('%04d_%03d',x,y), ...
        CRISM_INDEX_YYYY(idx_row),CRISM_INDEX_DOY(idx_row),'UniformOutput',false);
end



end

