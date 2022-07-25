function [ obs_info ] = crism_get_obs_info_v2(obs_id,varargin)
% [ obs_info ] = get_crism_obs_info_v2(obs_id,varargin)
%   get an information struct of the give observation id
%  INPUTS
%   obs_id: (up to 8 character string) "000094F6" or "94F6"
%
%   OUTPUTS
%       obs_info: struct
%        o - obs_id
%        o - obs_class_type
%        o - dirname
%        o - yyyy_doy
%        o - dir_info: Each field points to dir_info struct array for each
%        |    |        product types
%        |    o - edr
%        |    o - trr
%        |    o - ddr
%        |    o - ter
%        |    o - mtr
%        |
%        o - basenames: Each field points to cell array that contains all
%        |    |         the matched unique basenames without extensions
%        |    o - edr
%        |    o - trr
%        |    o - ddr
%        |    o - ter
%        |    o - mtr
%        o - central_scan_info: struct about the info on central scan
%        |     o - indx: index of the central scan in sgmnt_info
%        |     o - sgid: segment id of the central scan
%        |     o - df_indx: index of the dark franme measurements associated to central scan in sgmnt_info
%        |     o - df_sgid: segment id of the dark franme measurements associated to central scan
%        |
%        o - epf_info: struct about the info on epf
%        |     o - indx: index of EPF in sgmnt_info
%        |     o - sgid: segment id of the EPF
%        |     o - df_indx: index of the dark franme measurements associated to EPF in sgmnt_info
%        |     o - df_sgid: segment id of the dark franme measurements associated to EPF
%        |
%        o - sgmnt_info (struct array sorted by observation counters/segment ids)
%               Each Element has following fields:
%                   obs_counter        : char, hex format of the counter
%                   sensor_id          : cell, including all the sensor ids associated with this segment.
%                   activity_id        : cell, including all the activity ids associated with this segment.
%                   is_central_scan    : Boolean
%                   is_central_scan_df : Boolean
%                   is_epf             : Boolean
%                   is_epfdf           : Boolean
%                   L,S,J: struct
%                     edr, trr, ddr, ter, mtr
%                       o - activity_id: cell, including all the activity ids associated with the product type(s) of this segment.
%                       o - (self.activity_id{i}): cell of the associated product basenames for i=1:length(self.activity_id)
%                       o - HKP: cell of the associated HKP product basenames if applicable
%   
% OPTIONAL PARAMETERS
%       'yyyy_doy'
%           (yyyy): the year (ddd): the date counted from Jan. 1st of the year
%           e.x.) '2008_009'
%           (defualt) Obtained by crism_searchOBSID2YYYY_DOY_v2
%
%       'OBS_CLASSTYPE' : (3 charater string) 'FRT', 'HRS',..., etc
%           (defualt) Obtained by crism_searchOBSID2YYYY_DOY_v2
%
%       'SENSOR_ID:
%           (defualt) '(S|L|J)'
%
%       'VERBOSE': boolean, whether or not to display detail
%           (default) true
%
%       'DWLD_INDEX_CACHE_UPDATE' : boolean, whether or not to update index.html 
%           (default) false
%
%       'DOWNLOAD_*': integer, {0,1,2}
%           0: do not use any internet connection, offline mode
%           1: online mode, just scan the remote repository
%           2: online mode, scan the remote repository and download data
%           (default) 0
%           List of '*'
%               TRRIF_CS    : TRR, IF, Central Scan
%               TRRRA_CS    : TRR, RA, Central Scan
%               TRRHKP_CS   : TRR, HKP, Central Scan
%               DDR_CS      : DDR, Central Scan
%               EDR_CS_CSDF : EDR, SC, Central Scan and EDR, DF for Central Scan
%               EPF         : TRR, {IF,RA,HKP} of EPF, DDR of EPF, EDR of EPF (including SC and DF)
%               TER         : TER products
%               MTR         : MTR/MTRDR products
%               EDR_UN      : EDR, UN (Undefined)
%               EDR_DF      : EDR, DF (Dark Frames)
%               EDR_BI      : EDR, BI (Bias)
%               EDR_SP      : EDR, SP (Sphere)
%
%      'EXT_*': integer, {0,1,2}
%           Extension of the file you want to collect
%           (default) ''
%           List of '*'
%               TRRIF_CS    : TRR, IF, Central Scan
%               TRRRA_CS    : TRR, RA, Central Scan
%               TRRHKP_CS   : TRR, HKP, Central Scan
%               DDR_CS      : DDR, Central Scan
%               EDR_CS_CSDF : EDR, SC, Central Scan and EDR, DF for Central Scan
%               EPF         : TRR, {IF,RA,HKP} of EPF, DDR of EPF, EDR of EPF (including SC and DF)
%               TER         : TER products
%               MTR         : MTR/MTRDR products
%               EDR_UN      : EDR, UN (Undefined)
%               EDR_DF      : EDR, DF (Dark Frames)
%               EDR_BI      : EDR, BI (Bias)
%               EDR_SP      : EDR, SP (Sphere)
%
%       'VERBOSE' : print some property values such as obs_id. {0,1}
%           (default) 1
%
%       'DWLD_OVERWRITE': {0,1}, whether or not to overwrite the images
%           (default) 0
%
%       {'OBS_COUNTER_CS','OBS_COUNTER_SCENE'}
%           regular expression, observation counter for the scene image, 
%           different for different observation mode
%           (default) '07' for FRT and HRL
%                     '01' for FRS
%                     '0[13]{1}' for FFC
%       {'OBS_COUNTER_CSDF'',OBS_COUNTER_DF'}
%           regular expression, observation counter for the dark reference, 
%           different for different observation mode
%           (default) '0[68]{1}' for FRT and HRL
%                     '0[02]{1}' for FRS
%                     '0[02]{1}' for FFC
%                            
%
%

yyyy_doy = '';
obs_class_type = '';
sensor_id = '(S|L|J)';

dwld_index_cache_update = false;

dwld_ter         = 0;
dwld_mtr         = 0;
dwld_trrif_cs    = 0;
dwld_trrra_cs    = 0;
dwld_trrrahkp_cs = 0;
dwld_edr_cs_csdf = 0;
dwld_ddr_cs      = 0;
dwld_epf         = 0;
dwld_edr_un      = 0;
dwld_edr_df      = 0;
dwld_edr_bi      = 0;
dwld_edr_sp      = 0;

ext_ter         = '';
ext_mtr         = '';
ext_trrif_cs    = '';
ext_trrra_cs    = '';
ext_trrrahkp_cs = '';
ext_edr_cs_csdf = '';
ext_ddr_cs      = '';
ext_epf         = '';
ext_edr_un      = '';
ext_edr_df      = '';
ext_edr_bi      = '';
ext_edr_sp      = '';

dwld_overwrite = 0;
verbose=1;

OBS_COUNTER_CS_custom   = 0;
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
            case {'DOWNLOAD_TRRIF_CS','DOWNLOAD_TRRIF'}
                dwld_trrif_cs = varargin{i+1};
            case {'DOWNLOAD_TRRRA_CS','DOWNLOAD_TRRRA'}
                dwld_trrra_cs = varargin{i+1};
            case {'DOWNLOAD_TRRHKP_CS','DOWNLOAD_TRRRAHKP'}
                dwld_trrrahkp_cs = varargin{i+1};
            case {'DOWNLOAD_EDR_CS_CSDF','DOWNLOAD_EDRSCDF'}
                dwld_edr_cs_csdf = varargin{i+1};
            case 'DOWNLOAD_TER'
                dwld_ter = varargin{i+1};
            case {'DOWNLOAD_MTR','DOWNLOAD_MTRDR'}
                dwld_mtr = varargin{i+1};
            case 'DOWNLOAD_EPF'
                dwld_epf = varargin{i+1};
            case {'DOWNLOAD_DDR_CS','DOWNLOAD_DDR'}
                dwld_ddr_cs = varargin{i+1};
            case {'DOWNLOAD_EDR_UN','DOWNLOAD_UN'}
                dwld_edr_un = varargin{i+1};
            case {'DOWNLOAD_EDR_DF','DOWNLOAD_DF'}
                dwld_edr_df = varargin{i+1};
            case {'DOWNLOAD_EDR_SP'}
                dwld_edr_sp = varargin{i+1};
            case {'DOWNLOAD_EDR_BI'}
                dwld_edr_bi = varargin{i+1};
                
            % Extentions --------------------------------------------------
            case {'EXT_TRRIF_CS','EXT_TRRIF'}
                ext_trrif_cs = varargin{i+1};
            case {'EXT_TRRRA_CS','EXT_TRRRA'}
                ext_trrra_cs = varargin{i+1};
            case {'EXT_TRRRAHKP_CS','EXT_TRRRAHKP'}
                ext_trrrahkp_cs = varargin{i+1};
            case {'EXT_EDR_CS_CSDF','EXT_EDRSCDF'}
                ext_edr_cs_csdf = varargin{i+1};
            case 'EXT_TER'
                ext_ter = varargin{i+1};
            case {'EXT_MTR','EXT_MTRDR'}
                ext_mtr = varargin{i+1};
            case 'EXT_EPF'
                ext_epf = varargin{i+1};
            case {'EXT_DDR_CS','EXT_DDR'}
                ext_ddr_cs = varargin{i+1};
            case {'EXT_EDR_UN','EXT_UN'}
                ext_edr_un = varargin{i+1};
            case {'EXT_EDR_DF','EXT_DF'}
                ext_edr_df = varargin{i+1};
            case {'EXT_EDR_SP'}
                ext_edr_sp = varargin{i+1};
            case {'EXT_EDR_BI'}
                ext_edr_bi = varargin{i+1};

            case 'VERBOSE'
                verbose = varargin{i+1};
            case 'DWLD_OVERWRITE'
                dwld_overwrite = varargin{i+1};
            case {'OBS_COUNTER_CS','OBS_COUNTER_SCENE'}
                obs_counter_cs_tmp = varargin{i+1};
                OBS_COUNTER_CS_custom = 1;
            case {'OBS_COUNTER_CSDF','OBS_COUNTER_DF'}
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
    'Download_IF_CS',dwld_trrif_cs,'EXT_IF_CS',ext_trrif_cs,...
    'Download_RA_CS',dwld_trrra_cs,'EXT_RA_CS',ext_trrra_cs,...
    'Download_HKP_CS',dwld_trrrahkp_cs,'EXT_HKP_CS',ext_trrrahkp_cs,...
    'Download_EPF',dwld_epf,'EXT_EPF',ext_epf,...
    'overwrite',dwld_overwrite, ...
    'INDEX_CACHE_UPDATE',dwld_index_cache_update, ...
    'OBS_COUNTER_PTRN_STRUCT',obs_counter_ptrn_struct);

% # EDR
[search_result_EDR] = crism_search_products_EDR(obs_id, ...
    'OBS_CLASS_TYPE', obs_class_type, 'SENSOR_ID',sensor_id, ...
    'Download_CS_CSDF',dwld_edr_cs_csdf,'EXT_CS_CSDF',ext_edr_cs_csdf,...
    'Download_EPF',dwld_epf,'EXT_EPF',ext_epf,...
    'Download_UN',dwld_edr_un,'EXT_UN',ext_edr_un,...
    'Download_DF',dwld_edr_df,'EXT_DF',ext_edr_df,...
    'Download_BI',dwld_edr_bi,'EXT_BI',ext_edr_bi,...
    'Download_SP',dwld_edr_sp,'EXT_SP',ext_edr_sp,...
    'overwrite',dwld_overwrite, ...
    'INDEX_CACHE_UPDATE',dwld_index_cache_update, ...
    'OBS_COUNTER_PTRN_STRUCT',obs_counter_ptrn_struct);

% # DDR
[search_result_DDR] = crism_search_products_DDR(obs_id, ...
    'OBS_CLASS_TYPE', obs_class_type, 'SENSOR_ID',sensor_id, ...
    'Download_CS',dwld_ddr_cs,'EXT_CS',ext_ddr_cs,...
    'Download_EPF',dwld_epf,'EXT_EPF',ext_epf,...
    'overwrite',dwld_overwrite, ...
    'INDEX_CACHE_UPDATE',dwld_index_cache_update, ...
    'OBS_COUNTER_PTRN_STRUCT',obs_counter_ptrn_struct);


% # MTRDR
[search_result_MTR] = crism_search_products_MTRTER(obs_id, ...
    'PRODUCT_TYPE', 'MTR', ...
    'OBS_CLASS_TYPE', obs_class_type, 'SENSOR_ID','(S|L|J)', ...
    'Download',dwld_mtr,'EXT',ext_mtr,...
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

    cs_info = [];
    cs_info.indx = cs_indx;
    cs_info.sgid = cs_sgid;
    cs_info.df_indx = csdf_indx;
    cs_info.df_sgid = csdf_sgid;
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

    epf_info = [];
    epf_info.indx = epf_indx;
    epf_info.sgid = epf_sgid;
    epf_info.df_indx = epfdf_indx;
    epf_info.df_sgid = epfdf_sgid;
end

%% SUMMARY
obs_info = [];
obs_info.obs_id = obs_id;
obs_info.obs_class_type = obs_class_type;
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
    obs_info.central_scan_info = cs_info;
end

if any(strcmpi(obs_class_type,{'FRT','HRL','HRS'}))
    obs_info.epf_info = epf_info;
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
