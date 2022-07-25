function [search_result] = crism_search_products_MTRTER(obs_id, varargin)

product_type = 'MTR';

obs_class_type       = '';
obs_counter          = '(?<obs_counter>[0-9a-fA-F]{2})';
activity_id    = '(IF|IN|SR|SU|WV|DE)';
activity_macro_num   = '(?<activity_macro_num>[0-9]{3})';
sensor_id      = 'J';
vr             = '(?<version>[0-9a-zA-Z]{1})';
% yyyy_doy             = '(?<yyyy_doy>[0-9]{4}_[0-9]{3})';
ext   = '';
dwld  = 0;
overwrite  = false;
index_cache_update = false;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'OBS_CLASS_TYPE'
                obs_class_type = varargin{i+1};
            case 'OBS_COUNTER'
                obs_counter = varargin{i+1};
            case 'ACTIVITY_ID'
                activity_id = varargin{i+1};
            case 'ACTIVITY_MACRO_NUM'
                activity_macro_num = varargin{i+1};
            case 'SENSOR_ID'
                sensor_id = varargin{i+1};
            case 'PRODUCT_TYPE'
                product_type = varargin{i+1};
            % case 'YYYY_DOY'
            %     yyyy_doy = varargin{i+1};
            case 'VERSION'
                vr = varargin{i+1};
            case {'EXT','EXTENSION'}
                ext = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case 'INDEX_CACHE_UPDATE'
                index_cache_update = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});   
        end
    end
end

if isempty(obs_class_type)
    [ yyyy_doy,obs_class_type ] = crism_searchOBSID2YYYY_DOY_v2(obs_id);
end

[search_result] = crism_search_products(obs_id, product_type, ...
    'OBS_CLASS_TYPE',obs_class_type, 'OBS_COUNTER',obs_counter, ...
    'ACTIVITY_ID',activity_id,'ACTIVITY_MACRO_NUM',activity_macro_num, ...
    'OBS_COUNTER',obs_counter,'SENSOR_ID',sensor_id,'VERSION',vr, ...
    'Dwld',min(dwld,1),'EXT','','overwrite',overwrite, ...
    'INDEX_CACHE_UPDATE',index_cache_update);

if ~isempty(search_result.basenames)
    if dwld>1
        basenamePtrn = ['(' strjoin(basenames,'|') ')'];
        [basenameOBS,fnameOBS_wext_local,files_remote] = crism_readDownloadBasename( ...
            basenamePtrn,search_result.dir_info.subdir_local,dwld, ...
            'Subdir_remote',search_result.dir_info.subdir_remote, ...
            'Match_Exact',true,'overwrite',overwrite,'EXTENSION',ext);
        search_result.fnamewext_local = union(fnamewext_local,fnameOBS_wext_local);
    end
end


end