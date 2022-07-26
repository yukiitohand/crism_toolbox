function [search_result] = crism_search_products_EDR(obs_id, varargin)

product_type = '(EDR|HKP)';

obs_class_type = '';
obs_counter    = '(?<obs_counter>[0-9a-fA-F]{2})';
activity_id    = '(SC|DF|SP|BI)';
activity_macro_num   = '(?<activity_macro_num>[0-9]{3})';
sensor_id      = '(S|L)';
vr             = '(?<version>[0-9a-zA-Z]{1})';
% yyyy_doy             = '(?<yyyy_doy>[0-9]{4}_[0-9]{3})';

obs_counter_ptrn_struct = '';

ext_cs_csdf = '';
ext_epf = '';
ext_un  = '';
ext_df  = '';
ext_bi  = '';
ext_sp  = '';
dwld_cs_csdf = 0;
dwld_epf = 0;
dwld_un  = 0;
dwld_df  = 0;
dwld_bi  = 0;
dwld_sp  = 0;

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
            case {'DOWNLOAD_CS_CSDF','DOWNLOAD_EDRSCDF'}
                dwld_cs_csdf = varargin{i+1};
            case 'DOWNLOAD_EPF'
                dwld_epf = varargin{i+1};
            case 'DOWNLOAD_UN'
                dwld_un  = varargin{i+1};
            case 'DOWNLOAD_DF'
                dwld_df  = varargin{i+1};
            case 'DOWNLOAD_BI'
                dwld_bi  = varargin{i+1};
            case 'DOWNLOAD_SP'
                dwld_sp  = varargin{i+1};
            case {'EXT_CS_CSDF','EXT_EDRSCDF'}
                ext_cs_csdf = varargin{i+1};
            case 'EXT_EPF'
                ext_epf = varargin{i+1};
            case 'EXT_UN'
                ext_un = varargin{i+1};
            case 'EXT_DF'
                ext_df = varargin{i+1};
            case 'EXT_BI'
                ext_bi = varargin{i+1};
            case 'EXT_SP'
                ext_sp = varargin{i+1};
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

dwld_list = min(max([dwld_cs_csdf,dwld_epf,dwld_un,dwld_df]),1);
[search_result] = crism_search_products_OBS(obs_id, product_type, ...
    'OBS_CLASS_TYPE', obs_class_type, 'OBS_COUNTER', obs_counter, ...
    'ACTIVITY_ID', activity_id,'ACTIVITY_MACRO_NUM',activity_macro_num, ...
    'SENSOR_ID',sensor_id,'VERSION',vr, ...
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
    
        csdfcntr  = obs_counter_ptrn_struct.central_scan_df; % Central Scan CouNTR
        is_csdf = ~cellfun('isempty',regexpi(obscntrscell,csdfcntr,'ONCE'));
        csdf_indx = find(is_csdf);
    end
    
    % --------------------------------------------------------------------%
    % EPF
    % --------------------------------------------------------------------%
    if any(strcmpi(obs_class_type,{'FRT','HRL','HRS'}))
        epfcntr  = obs_counter_ptrn_struct.epf; 
        is_epf = ~cellfun('isempty',regexpi(obscntrscell,epfcntr,'ONCE'));
        epf_indx = find(is_epf);
    
        epfdfcntr  = obs_counter_ptrn_struct.epfdf; % Central Scan CouNTR
        is_epfdf = ~cellfun('isempty',regexpi(obscntrscell,epfdfcntr,'ONCE'));
        epfdf_indx = find(is_epfdf);
    end
    
    % ----------------------------------------------------------------------- %
    % UN
    % ----------------------------------------------------------------------- %
    if any(strcmpi(obs_class_type,{'FRS'}))
        uncntr  = obs_counter_ptrn_struct.un; 
        is_un = ~cellfun('isempty',regexpi(obscntrscell,uncntr,'ONCE'));
        un_indx = find(is_un);
    end



    % Download
    
    if dwld_cs_csdf>1
        edrscdf_sgmnt_info = search_result.sgmnt_info([cs_indx csdf_indx]);
        basenameEDRSCDFptrncell = [];
        for i_sg=1:length(edrscdf_sgmnt_info)
            for i=1:length(edrscdf_sgmnt_info(i_sg).sensor_id)
                sensid_i = edrscdf_sgmnt_info(i_sg).sensor_id{i};
                if any(strcmpi(sensid_i,{'S','L'}))
                    if isfield(edrscdf_sgmnt_info(i_sg).(sensid_i),'SC')
                        basenameEDRSCDFptrncell = [basenameEDRSCDFptrncell edrscdf_sgmnt_info(i_sg).(sensid_i).SC];
                    end
                    if isfield(edrscdf_sgmnt_info(i_sg).(sensid_i),'DF')
                        basenameEDRSCDFptrncell = [basenameEDRSCDFptrncell edrscdf_sgmnt_info(i_sg).(sensid_i).DF];
                    end
                    if isfield(edrscdf_sgmnt_info(i_sg).(sensid_i),'HKP')
                        basenameEDRSCDFptrncell = [basenameEDRSCDFptrncell edrscdf_sgmnt_info(i_sg).(sensid_i).HKP];
                    end
                end
            end
        end
        basenameEDRSCDFptrn = ['(', strjoin(basenameEDRSCDFptrncell, '|'), ')'];
        [basenameOBS,fnameOBS_wext_local,files_dwlded] = crism_readDownloadBasename( ...
            basenameEDRSCDFptrn,search_result.dir_info.subdir_local,dwld_cs_csdf, ...
            'Subdir_remote',search_result.dir_info.subdir_remote, ...
            'Match_Exact',true,'overwrite',overwrite,'EXTENSION',ext_cs_csdf);
        search_result.fnamewext_local = union(search_result.fnamewext_local,fnameOBS_wext_local);
    end
    
    if dwld_epf>1
        epf_sgmnt_info = search_result.sgmnt_info([epf_indx epfdf_indx]);
        basenameEDREPFptrncell = [];
        for i_sg=1:length(epf_sgmnt_info)
            for i=1:length(epf_sgmnt_info(i_sg).sensor_id)
                sensid_i = epf_sgmnt_info(i_sg).sensor_id{i};
                if any(strcmpi(sensid_i,{'S','L'}))
                    for j=1:length(epf_sgmnt_info(i_sg).(sensid_i).activity_id)
                        actid_j = epf_sgmnt_info(i_sg).(sensid_i).activity_id{j};
                        basenameEDREPFptrncell = [basenameEDREPFptrncell epf_sgmnt_info(i_sg).(sensid_i).(actid_j)];
                    end
                    if isfield(epf_sgmnt_info(i_sg).(sensid_i),'HKP')
                        basenameEDREPFptrncell = [basenameEDREPFptrncell epf_sgmnt_info(i_sg).(sensid_i).HKP];
                    end
                end
            end
        end
        basenameEDREPFptrn = ['(', strjoin(basenameEDREPFptrncell, '|'), ')'];
        [basenameOBS,fnameOBS_wext_local,files_dwlded] = crism_readDownloadBasename( ...
            basenameEDREPFptrn,search_result.dir_info.subdir_local,dwld_epf, ...
            'Subdir_remote',search_result.dir_info.subdir_remote, ...
            'Match_Exact',true,'overwrite',overwrite,'EXTENSION',ext_epf);
        search_result.fnamewext_local = union(search_result.fnamewext_local,fnameOBS_wext_local);
    end
    
    if dwld_un>1
        sgmnt_info = search_result.sgmnt_info;
        basenameUNptrncell = [];
        for i_sg=1:length(sgmnt_info)
            for i=1:length(sgmnt_info(i_sg).sensor_id)
                sensid_i = sgmnt_info(i_sg).sensor_id{i};
                if any(strcmpi(sensid_i,{'S','L'}))
                    if isfield(sgmnt_info(i_sg).(sensid_i),'UN')
                        basenameUNptrncell = [basenameUNptrncell sgmnt_info(i_sg).(sensid_i).UN];
                        if isfield(sgmnt_info(i_sg).(sensid_i),'HKP')
                            basenameUNptrncell = [basenameUNptrncell sgmnt_info(i_sg).(sensid_i).HKP];
                        end
                    end
                end
            end
        end
        basenameUNptrn = ['(', strjoin(basenameUNptrncell, '|'), ')'];
        [basenameOBS,fnameOBS_wext_local,files_dwlded] = crism_readDownloadBasename( ...
            basenameUNptrn,search_result.dir_info.subdir_local,dwld_un, ...
            'Subdir_remote',search_result.dir_info.subdir_remote, ...
            'Match_Exact',true,'overwrite',overwrite,'EXTENSION',ext_un);
        search_result.fnamewext_local = union(search_result.fnamewext_local,fnameOBS_wext_local);
    end
    
    if dwld_df>1
        sgmnt_info = search_result.sgmnt_info;
        basenameDFptrncell = [];
        for i_sg=1:length(sgmnt_info)
            for i=1:length(sgmnt_info(i_sg).sensor_id)
                sensid_i = sgmnt_info(i_sg).sensor_id{i};
                if any(strcmpi(sensid_i,{'S','L'}))
                    if isfield(sgmnt_info(i_sg).(sensid_i),'DF')
                        basenameDFptrncell = [basenameDFptrncell sgmnt_info(i_sg).(sensid_i).DF];
                        if isfield(sgmnt_info(i_sg).(sensid_i),'HKP')
                            basenameDFptrncell = [basenameDFptrncell sgmnt_info(i_sg).(sensid_i).HKP];
                        end
                    end
                end
            end
        end
        basenameDFptrn = ['(', strjoin(basenameDFptrncell, '|'), ')'];
        [basenameOBS,fnameOBS_wext_local,files_dwlded] = crism_readDownloadBasename( ...
            basenameDFptrn,search_result.dir_info.subdir_local,dwld_df, ...
            'Subdir_remote',search_result.dir_info.subdir_remote, ...
            'Match_Exact',true,'overwrite',overwrite,'EXTENSION',ext_df);
        search_result.fnamewext_local = union(search_result.fnamewext_local,fnameOBS_wext_local);
    end

    if dwld_bi>1
        sgmnt_info = search_result.sgmnt_info;
        basenameBIptrncell = [];
        for i_sg=1:length(sgmnt_info)
            for i=1:length(sgmnt_info(i_sg).sensor_id)
                sensid_i = sgmnt_info(i_sg).sensor_id{i};
                if any(strcmpi(sensid_i,{'S','L'}))
                    if isfield(sgmnt_info(i_sg).(sensid_i),'BI')
                        basenameBIptrncell = [basenameBIptrncell sgmnt_info(i_sg).(sensid_i).BI];
                        if isfield(sgmnt_info(i_sg).(sensid_i),'HKP')
                            basenameBIptrncell = [basenameBIptrncell sgmnt_info(i_sg).(sensid_i).HKP];
                        end
                    end
                end
            end
        end
        basenameBIptrn = ['(', strjoin(basenameBIptrncell, '|'), ')'];
        [basenameOBS,fnameOBS_wext_local,files_remote] = crism_readDownloadBasename( ...
            basenameBIptrn,search_result.dir_info.subdir_local,dwld_bi, ...
            'Subdir_remote',search_result.dir_info.subdir_remote, ...
            'Match_Exact',true,'overwrite',overwrite,'EXTENSION',ext_bi);
        search_result.fnamewext_local = union(search_result.fnamewext_local,fnameOBS_wext_local);
    end

    if dwld_sp>1
        sgmnt_info = search_result.sgmnt_info;
        basenameSPptrncell = [];
        for i_sg=1:length(sgmnt_info)
            for i=1:length(sgmnt_info(i_sg).sensor_id)
                sensid_i = sgmnt_info(i_sg).sensor_id{i};
                if any(strcmpi(sensid_i,{'S','L'}))
                    if isfield(sgmnt_info(i_sg).(sensid_i),'SP')
                        basenameSPptrncell = [basenameSPptrncell sgmnt_info(i_sg).(sensid_i).SP];
                        if isfield(sgmnt_info(i_sg).(sensid_i),'HKP')
                            basenameSPptrncell = [basenameSPptrncell sgmnt_info(i_sg).(sensid_i).HKP];
                        end
                    end
                end
            end
        end
        basenameSPptrn = ['(', strjoin(basenameSPptrncell, '|'), ')'];
        [basenameOBS,fnameOBS_wext_local,files_remote] = crism_readDownloadBasename( ...
            basenameSPptrn,search_result.dir_info.subdir_local,dwld_sp, ...
            'Subdir_remote',search_result.dir_info.subdir_remote, ...
            'Match_Exact',true,'overwrite',overwrite,'EXTENSION',ext_sp);
        search_result.fnamewext_local = union(search_result.fnamewext_local,fnameOBS_wext_local);
    end

end

end