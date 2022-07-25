function [search_result] = crism_search_products_DDR(obs_id, varargin)

product_type = 'DDR';

obs_class_type = '';
obs_counter    = '(?<obs_counter>[0-9a-fA-F]{2})';
activity_id    = 'DE';
activity_macro_num   = '(?<activity_macro_num>[0-9]{3})';
sensor_id      = '(S|L)';
vr             = '(?<version>[0-9a-zA-Z]{1})';
% yyyy_doy             = '(?<yyyy_doy>[0-9]{4}_[0-9]{3})';

obs_counter_ptrn_struct = '';

ext_cs   = '';
ext_epf  = '';
dwld_cs  = 0;
dwld_epf = 0;
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
            % case 'YYYY_DOY'
            %     yyyy_doy = varargin{i+1};
            case 'VERSION'
                vr = varargin{i+1};
            case 'OBS_COUNTER_PTRN_STRUCT'
                obs_counter_ptrn_struct = varargin{i+1};
            case {'DOWNLOAD_CS','DOWNLOAD_DDR'}
                dwld_cs = varargin{i+1};
            case {'DOWNLOAD_EPF'}
                dwld_epf = varargin{i+1};
            case {'EXT_CS','EXT_DDR'}
                ext_cs = varargin{i+1};
            case {'EXT_EPF'}
                ext_epf = varargin{i+1};
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

if isempty(obs_counter_ptrn_struct)
    obs_counter_ptrn_struct = crism_get_obs_counter_ptrn_struct(obs_class_type);
end

dwld_list = min(max([dwld_cs,dwld_epf]),1);
[search_result] = crism_search_products_OBS(obs_id, product_type, ...
    'OBS_CLASS_TYPE', obs_class_type, 'OBS_COUNTER', obs_counter, ...
    'ACTIVITY_ID', activity_id,'ACTIVITY_MACRO_NUM',activity_macro_num, ...
    'OBS_COUNTER',obs_counter,'SENSOR_ID',sensor_id,'VERSION',vr, ...
    'Dwld',dwld_list,'EXT','','overwrite',overwrite, ...
    'INDEX_CACHE_UPDATE',index_cache_update);

if ~isempty(search_result.basenames)
    obscntrscell = {search_result.sgmnt_info.obs_counter};
    % ----------------------------------------------------------------------- %
    % Central Scan
    % ----------------------------------------------------------------------- %
    if any(strcmpi(obs_class_type,{'FRT','HRL','HRS','FRS','ATO','FFC','MSP','HSP'}))
        cscntr  = obs_counter_ptrn_struct.central_scan; % Central Scan CouNTR
        is_cs = ~cellfun('isempty',regexpi(obscntrscell,cscntr,'ONCE'));
        cs_indx = find(is_cs);
    end
    
    % ----------------------------------------------------------------------- %
    % EPF
    % ----------------------------------------------------------------------- %
    if any(strcmpi(obs_class_type,{'FRT','HRL','HRS'}))
        epfcntr  = obs_counter_ptrn_struct.epf; 
        is_epf = ~cellfun('isempty',regexpi(obscntrscell,epfcntr,'ONCE'));
        epf_indx = find(is_epf);
    end

    
    % Download
    if dwld_cs>1
        cs_sgmnt_info = search_result.sgmnt_info(cs_indx);
        basenameDDRptrncell = [];
        for i_sg=1:length(cs_sgmnt_info)
            for i=1:length(cs_sgmnt_info(i_sg).sensor_id)
                sensid_i = cs_sgmnt_info(i_sg).sensor_id{i};
                if any(strcmpi(sensid_i,{'S','L'}))
                    for j=1:length(cs_sgmnt_info(i_sg).(sensid_i).activity_id)
                        actid_j = cs_sgmnt_info(i_sg).(sensid_i).activity_id{j};
                        basenameDDRptrncell = [basenameDDRptrncell cs_sgmnt_info(i_sg).(sensid_i).(actid_j)];
                    end
                end
            end
        end
        basenameDDRptrn = ['(', strjoin(basenameDDRptrncell, '|'), ')'];
        [basenameOBS,fnameOBS_wext_local,files_remote] = crism_readDownloadBasename( ...
            basenameDDRptrn,search_result.dir_info.subdir_local,dwld_cs, ...
            'Subdir_remote',search_result.dir_info.subdir_remote, ...
            'Match_Exact',true,'overwrite',overwrite,'EXTENSION',ext_cs);
        search_result.fnamewext_local = union(fnamewext_local,fnameOBS_wext_local);
    end
    
    if dwld_epf>1
        epf_sgmnt_info = search_result.sgmnt_info(epf_indx);
        basenameEPFDDRptrncell = [];
        for i_sg=1:length(epf_sgmnt_info)
            for i=1:length(epf_sgmnt_info(i_sg).sensor_id)
                sensid_i = epf_sgmnt_info(i_sg).sensor_id{i};
                if any(strcmpi(sensid_i,{'S','L'}))
                    for j=1:length(epf_sgmnt_info(i_sg).(sensid_i).activity_id)
                        actid_j = epf_sgmnt_info(i_sg).(sensid_i).activity_id{j};
                        basenameEPFDDRptrncell = [basenameEPFDDRptrncell epf_sgmnt_info(i_sg).(sensid_i).(actid_j)];
                    end
                end
            end
        end
        basenameEPFDDRptrn = ['(', strjoin(basenameEPFDDRptrncell, '|'), ')'];
        [basenameOBS,fnameOBS_wext_local,files_remote] = crism_readDownloadBasename( ...
            basenameEPFDDRptrn,search_result.dir_info.subdir_local,dwld_epf, ...
            'Subdir_remote',search_result.dir_info.subdir_remote, ...
            'Match_Exact',true,'overwrite',overwrite,'EXTENSION',ext_epf);
        search_result.fnamewext_local = union(fnamewext_local,fnameOBS_wext_local);
    end
end


end