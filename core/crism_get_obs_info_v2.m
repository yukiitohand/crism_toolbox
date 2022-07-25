function [ obs_info ] = crism_get_obs_info_v2(obs_id,varargin)
% [ obs_info ] = get_crism_obs_info(obs_id,varargin)
%   get an information struct of the give observation id
%  Inputs:
%   obs_id: (up to 8 character string) "000094F6" or "94F6"
%
%   Outputs
%       obs_info: struct
%             fields
%                 obs_info.obs_id           = obs_id;
%                 obs_info.obs_classType    = obs_classType;
%                 obs_info.dirname          = dirname;
%                 obs_info.yyyy_doy         = yyyy_doy;
%                 obs_info.sensor_id        = sensor_id;
%                 obs_info.dir_trdr         = dir_trdr;
%                 obs_info.dir_edr          = dir_edr;
%                 obs_info.dir_ddr          = dir_ddr;
%                 obs_info.dir_ter          = dir_ter;
%                 obs_info.dir_mtrdr        = dir_mtrdr;
%                 % trdr
%                 obs_info.basenameRA       = basenameRA;
%                 obs_info.basenameRAHKP    = basenameRAHKP;
%                 obs_info.basenameIF       = basenameIF;
%                 obs_info.basenameEPFIF    = basenameEPFIF;
%                 obs_info.basenameEPFRA    = basenameEPFRA;
%                 obs_info.basenameEPFRAHKP = basenameEPFRAHKP;
%                 % edr
%                 obs_info.basenameSC       = basenameSC;
%                 obs_info.basenameSCHKP    = basenameSCHKP;
%                 obs_info.basenameBI       = basenameBI;
%                 obs_info.basenameBIHKP    = basenameBIHKP;
%                 obs_info.basenameSP       = basenameSP;
%                 obs_info.basenameSPHKP    = basenameSPHKP;
%                 obs_info.basenameDF       = basenameDF;
%                 obs_info.basenameDFHKP    = basenameDFHKP;
%                 obs_info.basenameEPFSC    = basenameEPFSC;
%                 obs_info.basenameEPFSCHKP = basenameEPFSCHKP;
%                 obs_info.basenameEPFDF    = basenameEPFDF;
%                 obs_info.basenameEPFDFHKP = basenameEPFDFHKP;
%                 obs_info.basenameUN       = basenameUN;
%                 %ddr
%                 obs_info.basenameDDR      = basenameDDR;
%                 obs_info.basenameEPFDDR   = basenameEPFDDR;
%                 %ter
%                 obs_info.basenameTERIF    = basenameTERIF;
%                 obs_info.basenameTERIN    = basenameTERIN;
%                 obs_info.basenameTERSR    = basenameTERSR;
%                 obs_info.basenameTERSU    = basenameTERSU;
%                 obs_info.basenameTERWV    = basenameTERWV;
%                 %mtrdr
%                 obs_info.basenameMTRIF    = basenameMTRIF;
%                 obs_info.basenameMTRIN    = basenameTERIN;
%                 obs_info.basenameMTRSR    = basenameTERSR;
%                 obs_info.basenameMTRSU    = basenameTERSU;
%                 obs_info.basenameMTRWV    = basenameMTRWV;
%                 obs_info.basenameMTRDE    = basenameMTRDE;
%                 
%   Optional Parameters
%      'yyyy_doy'       : 'yyyy_doy' (yyyy): the year 
%                         (ddd): the date counted from Jan. 1st of the year
%                         e.x.) '2008_009'
%                       * always specify this parameter 
%                         (searching has not been implemented yet)
%
%      'OBS_CLASSTYPE' : (3 charater string) 'FRT', 'HRS',..., etc
%
%      'SENSOR_ID : "L" or "S"
%
%      'VERBOSE'        : boolean, whether or not to display detail
%                         (default) true
%      'DWLD_INDEX_CACHE_UPDATE' : boolean, whether or not to update index.html 
%        (default) false
%      'DOWNLOAD_TER': integer, {0,1,2}
%                  0: do not use any internet connection, offline mode
%                  1: online mode, connect to the internet
%                  2: 
%                  (default) 0
%      'DOWNLOAD_MTRDR': integer, {0,1,2}
%                  0: do not use any internet connection, offline mode
%                  1: online mode, connect to the internet
%                  2: 
%                  (default) 0
%      'DOWNLOAD_TRRIF': integer, {0,1,2}
%                  0: do not use any internet connection, offline mode
%                  1: online mode, connect to the internet
%                  2: 
%                  (default) 0
%      'DOWNLOAD_TRRRA': integer, {0,1,2}
%                  0: do not use any internet connection, offline mode
%                  1: online mode, connect to the internet
%                  2: 
%                  (default) 0
%      'DOWNLOAD_EDRSCDF': integer, {0,1,2}
%                  0: do not use any internet connection, offline mode
%                  1: online mode, connect to the internet
%                  2: 
%                  (default) 0
%      'DOWNLOAD_DDR': integer, {0,1,2}
%                  0: do not use any internet connection, offline mode
%                  1: online mode, connect to the internet
%                  2: 
%                  (default) 0
%      'DOWNLOAD_EPF': integer, {0,1,2}
%                  0: do not use any internet connection, offline mode
%                  1: online mode, connect to the internet
%                  2: 
%                  (default) 0
%      'VERBOSE' : print some property values such as obs_id. {0,1}
%                  (default) 1
%      'FORCE_DWLD': {0,1}, whether or not to forcefully download the
%                    files specified.
%      'DWLD_OVERWRITE': {0,1}, whether or not to overwrite the images
%      'OUT_FILE'  : file path to the output file of the list of relative
%                    path to be downloaded
%                    (default) ''
%      'OBS_COUNTER_SCENE' : regular expression, observation counter for 
%                            the scene image, different for different
%                            observation mode
%                            (default) '07' for FRT and HRL
%                                      '01' for FRS
%                                      '0[13]{1}' for FFC
%      'OBS_COUNTER_DF'    : regular expression, observation counter for 
%                            the dark reference, different for different
%                            observation mode
%                            (default) '0[68]{1}' for FRT and HRL
%                                      '0[02]{1}' for FRS
%                                      '0[02]{1}' for FFC
%                            
%
%

yyyy_doy = '';
obs_class_type = '';
sensor_id = '(S|L)';

dwld_index_cache_update = false;

dwld_ter      = 0;
dwld_mtrdr    = 0;
dwld_trrif    = 0;
dwld_trrra    = 0;
dwld_trrrahkp = 0;
dwld_edrscdf  = 0;
dwld_ddr      = 0;
dwld_epf      = 0;
dwld_un       = 0;
dwld_df       = 0;

ext_ter      = '';
ext_mtrdr    = '';
ext_trrif    = '';
ext_trrra    = '';
ext_trrrahkp = '';
ext_edrscdf  = '';
ext_ddr      = '';
ext_epf      = '';
ext_un       = '';
ext_df       = '';

dwld_overwrite = 0;
verbose=1;

OBS_COUNTER_CS_custom = 0;
OBS_COUNTER_CSDF_custom = 0;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'YYYY_DOY'
                yyyy_doy = varargin{i+1};
            case 'OBS_CLASSTYPE'
                obs_class_type = varargin{i+1};
            case 'SENSOR_ID'
                sensor_id = varargin{i+1};
            % Download options --------------------------------------------
            case 'DWLD_INDEX_CACHE_UPDATE'
                dwld_index_cache_update = varargin{i+1};
            case 'DOWNLOAD_TRRIF'
                dwld_trrif = varargin{i+1};
            case 'DOWNLOAD_TRRRA'
                dwld_trrra = varargin{i+1};
            case 'DOWNLOAD_TRRRAHKP'
                dwld_trrrahkp = varargin{i+1};
            case 'DOWNLOAD_EDRSCDF'
                dwld_edrscdf = varargin{i+1};
            case 'DOWNLOAD_TER'
                dwld_ter = varargin{i+1};
            case 'DOWNLOAD_MTRDR'
                dwld_mtrdr = varargin{i+1};
            case 'DOWNLOAD_EPF'
                dwld_epf = varargin{i+1};
            case 'DOWNLOAD_DDR'
                dwld_ddr = varargin{i+1};
            case 'DOWNLOAD_UN'
                dwld_un = varargin{i+1};
            case 'DOWNLOAD_DF'
                dwld_df = varargin{i+1};
                
            % Extentions --------------------------------------------------
            case 'EXT_TRRIF'
                ext_trrif = varargin{i+1};
            case 'EXT_TRRRA'
                ext_trrra = varargin{i+1};
            case 'EXT_TRRRAHKP'
                ext_trrrahkp = varargin{i+1};
            case 'EXT_EDRSCDF'
                ext_edrscdf = varargin{i+1};
            case 'EXT_TER'
                ext_ter = varargin{i+1};
            case 'EXT_MTRDR'
                ext_mtrdr = varargin{i+1};
            case 'EXT_EPF'
                ext_epf = varargin{i+1};
            case 'EXT_DDR'
                ext_ddr = varargin{i+1};
            case 'EXT_UN'
                ext_un = varargin{i+1};
            case 'EXT_DF'
                ext_df = varargin{i+1};

            case 'VERBOSE'
                verbose = varargin{i+1};
            case 'DWLD_OVERWRITE'
                dwld_overwrite = varargin{i+1};
            case {'OBS_COUNTER_SCENE','OBS_COUNTER_CS'}
                obs_counter_cs_tmp = varargin{i+1};
                OBS_COUNTER_CS_custom = 1;
            case {'OBS_COUNTER_DF','OBS_COUNTER_CSDF'}
                obs_counter_csdf_tmp = varargin{i+1};
                OBS_COUNTER_CSDF_custom = 1;
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

% zero-padding if not
obs_id = upper(crism_pad_obs_id(obs_id));

if isempty(yyyy_doy) || isempty(obs_class_type)
    [ yyyy_doy,obs_class_type2 ] = crism_searchOBSID2YYYY_DOY_v2(obs_id);
    if ~isempty(obs_class_type) && ~strcmp(obs_class_type,obs_class_type2)
        fprintf('The input obs_classType %s is different in the record.\n',obs_class_type);
    end
    obs_class_type = obs_class_type2;
end
if verbose
    fprintf('OBS_ID: %s\n',obs_id);
    fprintf('YYYY_DOY: %s\n',yyyy_doy);
    fprintf('OBS_CLASSTYPE: %s\n',obs_class_type);
end

dirname = [obs_class_type obs_id];

if isempty(sensor_id)
    error('"SENOSER_ID" is necessary');
end

[obs_counter_ptrn_struct] = crism_get_obs_counter_ptrn_struct(obs_class_type);

if OBS_COUNTER_CS_custom
    obs_counter_ptrn_struct.central_scan = obs_counter_cs_tmp;
end
if OBS_COUNTER_CSDF_custom
    obs_counter_ptrn_struct.central_scan_df = obs_counter_csdf_tmp;
end

%%
% # TRR
[search_result_TRR] = crism_search_products_TRR(obs_id, ...
    'OBS_CLASS_TYPE', obs_class_type, 'SENSOR_ID',sensor_id, ...
    'Download_IF',dwld_trrif,'EXT_IF',ext_trrif,...
    'Download_RA',dwld_trrra,'EXT_RA',ext_trrra,...
    'Download_HKP',dwld_trrrahkp,'EXT_HKP',ext_trrrahkp,...
    'Download_EPF',dwld_epf,'EXT_EPF',ext_epf,...
    'overwrite',dwld_overwrite, ...
    'INDEX_CACHE_UPDATE',dwld_index_cache_update, ...
    'OBS_COUNTER_PTRN_STRUCT',obs_counter_ptrn_struct);

% # EDR
[search_result_EDR] = crism_search_products_EDR(obs_id, ...
    'OBS_CLASS_TYPE', obs_class_type, 'SENSOR_ID',sensor_id, ...
    'Download_edrscdf',dwld_edrscdf,'EXT_edrscdf',ext_edrscdf,...
    'Download_EPF',dwld_epf,'EXT_EPF',ext_epf,...
    'Download_UN',dwld_un,'EXT_EPF',ext_un,...
    'Download_UN',dwld_df,'EXT_EPF',ext_df,...
    'overwrite',dwld_overwrite, ...
    'INDEX_CACHE_UPDATE',dwld_index_cache_update, ...
    'OBS_COUNTER_PTRN_STRUCT',obs_counter_ptrn_struct);

% # DDR
[search_result_DDR] = crism_search_products_DDR(obs_id, ...
    'OBS_CLASS_TYPE', obs_class_type, 'SENSOR_ID',sensor_id, ...
    'Download_ddr',dwld_ddr,'EXT_ddr',ext_ddr,...
    'Download_EPF',dwld_epf,'EXT_EPF',ext_epf,...
    'overwrite',dwld_overwrite, ...
    'INDEX_CACHE_UPDATE',dwld_index_cache_update, ...
    'OBS_COUNTER_PTRN_STRUCT',obs_counter_ptrn_struct);


% # MTRDR
[search_result_MTR] = crism_search_products_MTRTER(obs_id, ...
    'PRODUCT_TYPE', 'MTR', ...
    'OBS_CLASS_TYPE', obs_class_type, 'SENSOR_ID','(S|L|J)', ...
    'Download',dwld_mtrdr,'EXT',ext_mtrdr,...
    'overwrite',dwld_overwrite, ...
    'INDEX_CACHE_UPDATE',dwld_index_cache_update);

% # TER
[search_result_TER] = crism_search_products_MTRTER(obs_id, ...
    'PRODUCT_TYPE', 'TER', ...
    'OBS_CLASS_TYPE', obs_class_type, 'SENSOR_ID','(S|L|J)', ...
    'Download',dwld_ter,'EXT',ext_ter,...
    'overwrite',dwld_overwrite, ...
    'INDEX_CACHE_UPDATE',dwld_index_cache_update);


%% Combine segment information
[sgmnt_info] = crism_initialize_sgmnt_info(search_result_EDR,'edr');
[sgmnt_info] = crism_integrate_sgmnt_info(sgmnt_info,search_result_TRR,'trr');
[sgmnt_info] = crism_integrate_sgmnt_info(sgmnt_info,search_result_DDR,'ddr');
[sgmnt_info] = crism_integrate_sgmnt_info(sgmnt_info,search_result_TER,'ter');
[sgmnt_info] = crism_integrate_sgmnt_info(sgmnt_info,search_result_MTR,'mtr');

%% obs

obscntrscell = {sgmnt_info.obs_counter};

% ----------------------------------------------------------------------- %
% Central Scan
% ----------------------------------------------------------------------- %
if any(strcmpi(obs_class_type,{'FRT','HRL','HRS','FRS','ATO','FFC','MSP','HSP'}))
    cscntr  = obs_counter_ptrn_struct.central_scan; % Central Scan CouNTR
    is_cs = ~cellfun('isempty',regexpi(obscntrscell,cscntr,'ONCE'));
    is_cs_cell = num2cell(is_cs);
    [sgmnt_info.is_central_scan] = is_cs_cell{:};
    cs_indx = find(is_cs);
    cs_sgid = obscntrscell(cs_indx);

    csdfcntr  = obs_counter_ptrn_struct.central_scan_df; % Central Scan CouNTR
    is_csdf = ~cellfun('isempty',regexpi(obscntrscell,csdfcntr,'ONCE'));
    is_csdf_cell = num2cell(is_csdf);
    [sgmnt_info.is_central_scan_df] = is_csdf_cell{:};
    csdf_indx = find(is_csdf);
    csdf_sgid = obscntrscell(csdf_indx);
end

% ----------------------------------------------------------------------- %
% EPF
% ----------------------------------------------------------------------- %
if any(strcmpi(obs_class_type,{'FRT','HRL','HRS'}))
    epfcntr  = obs_counter_ptrn_struct.epf; % Central Scan CouNTR
    is_epf = ~cellfun('isempty',regexpi(obscntrscell,epfcntr,'ONCE'));
    is_epf_cell = num2cell(is_epf);
    [sgmnt_info.is_epf] = is_epf_cell{:};
    epf_indx = find(is_epf);
    epf_sgid = obscntrscell(epf_indx);

    epfdfcntr  = obs_counter_ptrn_struct.epfdf; % Central Scan CouNTR
    is_epfdf = ~cellfun('isempty',regexpi(obscntrscell,epfdfcntr,'ONCE'));
    is_epfdf_cell = num2cell(is_epfdf);
    [sgmnt_info.is_epfdf] = is_epfdf_cell{:};
    epfdf_indx = find(is_epfdf);
    epfdf_sgid = obscntrscell(epfdf_indx);
end

%% SUMMARY
obs_info = [];
obs_info.obs_id = obs_id;
obs_info.obs_classType = obs_class_type;
obs_info.dirname = dirname;
obs_info.yyyy_doy = yyyy_doy;

obs_info.dir_info = [];
obs_info.dir_info.edr = search_result_EDR.dir_info;
obs_info.dir_info.trr = search_result_TRR.dir_info;
obs_info.dir_info.ddr = search_result_DDR.dir_info;
obs_info.dir_info.ter = search_result_TER.dir_info;
obs_info.dir_info.mtr = search_result_MTR.dir_info;

obs_info.basenames = [];
obs_info.basenames.edr = search_result_EDR.basenames;
obs_info.basenames.trr = search_result_TRR.basenames;
obs_info.basenames.ddr = search_result_DDR.basenames;
obs_info.basenames.ter = search_result_TER.basenames;
obs_info.basenames.mtr = search_result_MTR.basenames;

obs_info.sgmnt_info = sgmnt_info;

if any(strcmpi(obs_class_type,{'FRT','HRL','HRS','FRS','ATO','FFC','MSP','HSP'}))
    obs_info.central_scan_indx = cs_indx;
    obs_info.central_scan_sgid = cs_sgid;
    obs_info.central_scan_df_indx = csdf_indx;
    obs_info.central_scan_df_sgid = csdf_sgid;
end

if any(strcmpi(obs_class_type,{'FRT','HRL','HRS'}))
    obs_info.epf_indx = epf_indx;
    obs_info.epf_sgid = epf_sgid;
    obs_info.epfdf_indx = epfdf_indx;
    obs_info.epfdf_sgid = epfdf_sgid;
end
end

function [sgmnt_info] = crism_initialize_sgmnt_info(search_result,pdtype)
sgmnt_info = [];
if ~isempty(search_result.basenames)
    obscntrs_edr_cell = {search_result.sgmnt_info.obs_counter};
    if ~issorted(obscntrs_edr_cell)
        [obscntrs_edr_cell,i_srt] = sort(obscntrs_edr_cell);
        search_result.sgmnt_info = search_result.sgmnt_info(i_srt);
    end
    for i_sgid=1:length(search_result.sgmnt_info)
        obscntr = search_result.sgmnt_info(i_sgid).obs_counter;
        sgmnt_info(i_sgid).obs_counter = obscntr;
        sensids = search_result.sgmnt_info(i_sgid).sensor_id;
        sgmnt_info(i_sgid).sensor_id = sensids;
        sgmnt_info(i_sgid).activity_id = {};
        for i_sens=1:length(sensids)
            sensid_i = sensids{i_sens};
            if ~isfield(sgmnt_info(i_sgid),sensid_i)
                sgmnt_info(i_sgid).(sensid_i) = [];
            end
            sgmnt_info(i_sgid).(sensid_i).(pdtype) = search_result.sgmnt_info(i_sgid).(sensid_i);
            actids = search_result.sgmnt_info(i_sgid).(sensid_i).activity_id;
            sgmnt_info(i_sgid).activity_id = union(sgmnt_info(i_sgid).activity_id,actids);
        end
    end
end
end

function [sgmnt_info] = crism_integrate_sgmnt_info(sgmnt_info,search_result,pdtype)
if ~isempty(search_result.basenames)
    obscntrs_sgmnt_info = {sgmnt_info.obs_counter};
    obscntrs_mtch_cell = {search_result.sgmnt_info.obs_counter};
    for i_mtch=1:length(obscntrs_mtch_cell)
        obscntr = obscntrs_mtch_cell{i_mtch};
        i_sgid = find(strcmpi(obscntr,obscntrs_sgmnt_info));
        if ~isempty(i_sgid)
            sensids_mtch = search_result.sgmnt_info(i_mtch).sensor_id;
            sgmnt_info(i_sgid).sensor_id = union(sgmnt_info(i_sgid).sensor_id,sensids_mtch);
            for i_sens=1:length(sensids_mtch)
                sensid_i = sensids_mtch{i_sens};
                if ~isfield(sgmnt_info(i_sgid),sensid_i)
                    sgmnt_info(i_sgid).(sensid_i) = [];
                end
                sgmnt_info(i_sgid).(sensid_i).(pdtype) = search_result.sgmnt_info(i_mtch).(sensid_i);
                actids_mtch = search_result.sgmnt_info(i_mtch).(sensid_i).activity_id;
                sgmnt_info(i_sgid).activity_id = union(sgmnt_info(i_sgid).activity_id,actids_mtch);
            end
        end
    end
end
end





