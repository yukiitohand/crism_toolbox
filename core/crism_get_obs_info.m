function [ obs_info ] = crism_get_obs_info(obs_id,varargin)
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
obs_classType = '';

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

ext_ter      = '';
ext_mtrdr    = '';
ext_trrif    = '';
ext_trrra    = '';
ext_trrrahkp = '';
ext_edrscdf  = '';
ext_ddr      = '';
ext_epf      = '';
ext_un       = '';

force_dwld = 0;
verbose=1;
outfile = '';

OBS_COUNTER_SCENE_custom = 0;
OBS_COUNTER_DF_custom = 0;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'YYYY_DOY'
                yyyy_doy = varargin{i+1};
            case 'OBS_CLASSTYPE'
                obs_classType = varargin{i+1};
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
                
            case 'VERBOSE'
                verbose = varargin{i+1};
            case 'FORCE_DWLD'
                force_dwld = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            case 'OBS_COUNTER_SCENE'
                obs_counter_tmp = varargin{i+1};
                OBS_COUNTER_SCENE_custom = 1;
            case 'OBS_COUNTER_DF'
                obs_counter_df_tmp = varargin{i+1};
                OBS_COUNTER_DF_custom = 1;
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

% zero-padding if not
obs_id = upper(crism_pad_obs_id(obs_id));

if isempty(yyyy_doy) || isempty(obs_classType)
    [ yyyy_doy,obs_classType2 ] = crism_searchOBSID2YYYY_DOY_v2(obs_id);
    if ~isempty(obs_classType) && ~strcmp(obs_classType,obs_classType2)
        fprintf('The input obs_classType %s is different in the record.\n',obs_classType);
    end
    obs_classType = obs_classType2;
end
if verbose
    fprintf('OBS_ID: %s\n',obs_id);
    fprintf('YYYY_DOY: %s\n',yyyy_doy);
    fprintf('OBS_CLASSTYPE: %s\n',obs_classType);
end

dirname = [obs_classType obs_id];

if isempty(sensor_id)
    error('"SENOSER_ID" is necessary');
end

switch obs_classType
    case {'FRT','HRL','HRS'}
        obs_counter = '07';
        obs_counter_epf = '[0-689A-Za-z]{2}';
        obs_counter_epfdf = '0[0E]{1}';
        obs_counter_df = '0[68]{1}';
    case {'FRS','ATO'}
        obs_counter = '01';
        obs_counter_df = '0[03]{1}';
        obs_counter_epf = '';
        obs_counter_epfdf = '';
        obs_counter_un = '02';
    case 'FFC'
        obs_counter = '0[13]{1}';
        obs_counter_df = '0[024]{1}';
        % this could be switched.
        obs_counter_epf = '';
        if verbose
            fprintf('no epf for obervation type FFC\n');
        end
        if dwld_epf==1
            if verbose
                fprintf('DOWNLOAD_EPFRA is inactivated\n');
            end
        end
        
    case 'CAL'
        obs_counter = '[0-9a-fA-F]{2}';
        obs_counter_df = '[0-9a-fA-F]{1}';
    case 'ICL'
        obs_counter = '[0-9a-fA-F]{2}';
        obs_counter_df = '[0-9a-fA-F]{1}';
    case {'MSP','HSP'}
        obs_counter = '01';
        obs_counter_df = '0[02]{1}';
        obs_counter_epf = '';
        obs_counter_epfdf = '';
    otherwise
        error('OBS_TYPE %s is not supported yet.',obs_classType);
end

if OBS_COUNTER_SCENE_custom
    obs_counter = obs_counter_tmp;
end
if OBS_COUNTER_DF_custom
    obs_counter_df = obs_counter_df_tmp;
end

%%
%-------------------------------------------------------------------------%
% TER
%-------------------------------------------------------------------------%
if any(strcmpi(obs_classType,{'FRT','ATO','FRS','HRL','HRS'}))
     search_product_TER = @(x_ai) crism_search_observation_fromProp(...
         crism_create_propOBSbasename('OBS_CLASS_TYPE',obs_classType,...
        'OBS_ID',obs_id,'ACTIVITY_ID',x_ai,'OBS_COUNTER',obs_counter,...
        'SENSOR_ID','J','product_type','TER'),...
        'Dwld',dwld_ter,'Match_Exact',true,'Force',force_dwld, ...
        'OUT_FILE',outfile,'EXT',ext_ter,'INDEX_CACHE_UPDATE',dwld_index_cache_update);
    
    % [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname,basenameOBS]
    [dir_info,basenameTERIF,fnameTERIFwext_local] = search_product_TER('IF');
    [~,basenameTERIN,fnameTERINwext_local] = search_product_TER('IN');
    [~,basenameTERSR,fnameTERSRwext_local] = search_product_TER('SR');
    [~,basenameTERSU,fnameTERSUwext_local] = search_product_TER('SU');
    [~,basenameTERWV,fnameTERWVwext_local] = search_product_TER('WV');
    dir_ter = dir_info.dirfullpath_local;
else
    dir_ter = ''; basenameTERIF = ''; basenameTERIN = ''; basenameTERSR = '';
    basenameTERSU = ''; basenameTERWV = '';
    fnameTERIFwext_local = []; fnameTERINwext_local = []; 
    fnameTERSRwext_local = []; fnameTERSUwext_local = [];
    fnameTERWVwext_local = [];
    
end
fnamesTERwext_local = [fnameTERIFwext_local  fnameTERINwext_local ...
    fnameTERSRwext_local fnameTERSUwext_local fnameTERWVwext_local ]';
%
%-------------------------------------------------------------------------%
% MTRDR
%-------------------------------------------------------------------------%
switch upper(obs_classType)
    case {'FRT','ATO','FRS','HRL','HRS'}
        search_product_MTR = @(x_ai,y_si) crism_search_observation_fromProp(...
             crism_create_propOBSbasename('OBS_CLASS_TYPE',obs_classType,...
            'OBS_ID',obs_id,'ACTIVITY_ID',x_ai,'OBS_COUNTER',obs_counter,...
            'SENSOR_ID',y_si,'product_type','MTR'),...
            'Dwld',dwld_mtrdr,'Match_Exact',true,'Force',force_dwld, ...
            'OUT_FILE',outfile,'EXT', ext_mtrdr,'INDEX_CACHE_UPDATE',dwld_index_cache_update);

        % [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname,basenameOBS]
        [dir_info,basenameMTRIF,fnameMTRIFwext_local] = search_product_MTR('IF','J');
        [~,basenameMTRIN,fnameMTRINwext_local] = search_product_MTR('IN','J');
        [~,basenameMTRSR,fnameMTRSRwext_local] = search_product_MTR('SR','J');
        [~,basenameMTRSU,fnameMTRSUwext_local] = search_product_MTR('SU','J');
        [~,basenameMTRWV,fnameMTRWVwext_local] = search_product_MTR('WV','J');
        [~,basenameMTRDE,fnameMTRDEwext_local] = search_product_MTR('DE','L');
        dir_mtrdr = dir_info.dirfullpath_local;
    otherwise
        dir_mtrdr = '';
        basenameMTRIF = ''; basenameMTRIN = ''; basenameMTRSR = '';
        basenameMTRSU = ''; basenameMTRWV = ''; basenameMTRDE = '';
        fnameMTRIFwext_local = []; fnameMTRINwext_local = []; 
        fnameMTRSRwext_local = []; fnameMTRSUwext_local = [];
        fnameMTRWVwext_local = []; fnameMTRDEwext_local = [];
end

fnamesMTRwext_local = [fnameMTRIFwext_local fnameMTRINwext_local ...
    fnameMTRSRwext_local fnameMTRSUwext_local fnameMTRWVwext_local ...
    fnameMTRDEwext_local ]';

%-------------------------------------------------------------------------%
% TRR
%-------------------------------------------------------------------------%
switch upper(obs_classType)
    case {'FRT','ATO','FRS','HRL','HRS','MSP','HSP','FFC'}
        search_product_TRR = @(x_ai,y_oc,z_pd,w_dwld,v,xx_ext) crism_search_observation_fromProp(...
             crism_create_propOBSbasename('OBS_CLASS_TYPE',obs_classType,...
            'OBS_ID',obs_id,'ACTIVITY_ID',x_ai,'OBS_COUNTER',y_oc,...
            'SENSOR_ID',sensor_id,'product_type',z_pd,'Version',v),...
            'Dwld',w_dwld,'Match_Exact',true,'Force',force_dwld,'OUT_FILE',outfile, ...
            'EXTENSION',xx_ext,'INDEX_CACHE_UPDATE',dwld_index_cache_update);

        % [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname,basenameOBS]
        [dir_info,basenameIF,fnameTRRIFwext_local] = search_product_TRR('IF',obs_counter,'TRR',dwld_trrif,3,ext_trrif);
        [~,basenameRA,fnameTRRRAwext_local]        = search_product_TRR('RA',obs_counter,'TRR',dwld_trrra,3,ext_trrra);
        [~,basenameRAHKP,fnameTRRRAHKPwext_local]  = search_product_TRR('RA',obs_counter,'HKP',dwld_trrrahkp,3,ext_trrrahkp);
        dir_trdr = dir_info.dirfullpath_local;
        switch upper(obs_classType)
            case {'FRT','HRL','HRS'}
                % EPF
                [~,basenameEPFIF,fnameEPFIFwext_local]    = search_product_TRR('IF',obs_counter_epf,'TRR',dwld_epf,3,ext_epf);
                [~,basenameEPFRA,fnameEPFRAwext_local]    = search_product_TRR('RA',obs_counter_epf,'TRR',dwld_epf,3,ext_epf);
                [~,basenameEPFRAHKP,fnameEPFRAHKPwext_local] = search_product_TRR('RA',obs_counter_epf,'HKP',dwld_epf,3,ext_epf);
            otherwise
                basenameEPFIF = []; basenameEPFRA = []; basenameEPFRAHKP = [];
                fnameEPFIFwext_local = []; fnameEPFRAwext_local = []; fnameEPFRAHKPwext_local = [];
        end
    otherwise
        dir_trdr = '';
        basenameIF = ''; basenameRA = ''; basenameRAHKP = '';
        basenameEPFIF = []; basenameEPFRA = []; basenameEPFRAHKP = [];
        fnameTRRIFwext_local = []; fnameTRRRAwext_local = []; fnameTRRRAHKPwext_local = [];
        fnameEPFIFwext_local = []; fnameEPFRAwext_local = []; fnameEPFRAHKPwext_local = [];
end

fnamesTRRwext_local = [fnameTRRIFwext_local fnameTRRRAwext_local ...
    fnameTRRRAHKPwext_local fnameEPFIFwext_local fnameEPFRAwext_local ...
    fnameEPFRAwext_local fnameEPFRAHKPwext_local];

%-------------------------------------------------------------------------%
% EDR
%-------------------------------------------------------------------------%
search_product_EDR = @(x_ai,y_oc,z_pd,w_dwld,v,xx_ext) crism_search_observation_fromProp(...
         crism_create_propOBSbasename('OBS_CLASS_TYPE',obs_classType,...
        'OBS_ID',obs_id,'ACTIVITY_ID',x_ai,'OBS_COUNTER',y_oc,...
        'SENSOR_ID',sensor_id,'product_type',z_pd,'Version',v),...
        'Dwld',w_dwld,'Match_Exact',true,'Force',force_dwld, ...
        'OUT_FILE',outfile,'EXT',xx_ext,'INDEX_CACHE_UPDATE',dwld_index_cache_update);

switch upper(obs_classType)
    case {'FRT','ATO','FRS','HRL','HRS','MSP','HSP','FFC'}
        % SC
        [dir_info,basenameSC,fnameEDRSCwext_local] = search_product_EDR('SC',obs_counter,'EDR',dwld_edrscdf,0,ext_edrscdf);
        [~,basenameSCHKP,fnameEDRSCHKPwext_local] = search_product_EDR('SC',obs_counter,'HKP',dwld_edrscdf,0,ext_edrscdf);
        dir_edr = dir_info.dirfullpath_local;
        switch upper(obs_classType)
            case {'FRT','HRL','HRS'}
                [~,basenameEPFSC,fnameEPFSCwext_local]       = search_product_EDR('SC',obs_counter_epf,'EDR',dwld_epf,0,ext_epf);
                [~,basenameEPFSCHKP,fnameEPFSCHKPwext_local] = search_product_EDR('SC',obs_counter_epf,'HKP',dwld_epf,0,ext_epf);
                % DF
                [~,basenameEPFDF,fnameEPFDFwext_local]        = search_product_EDR('DF',obs_counter_epfdf,'EDR',dwld_epf,0,ext_epf);
                [~,basenameEPFDFHKP,fnameEPFDFHKPwext_local] = search_product_EDR('DF',obs_counter_epfdf,'HKP',dwld_epf,0,ext_epf);
            otherwise
                basenameEPFSC = []; basenameEPFDF = []; basenameEPFSCHKP = []; basenameEPFDFHKP = [];
                fnameEPFSCwext_local = []; fnameEPFSCHKPwext_local = [];
                fnameEPFDFwext_local = []; fnameEPFDFHKPwext_local = [];
        end
        
    otherwise
        basenameSC = ''; basenameSCHKP = []; basenameEPFSC = []; 
        basenameEPFDF = []; basenameEPFSCHKP = []; basenameEPFDFHKP = [];
        fnameEDRSCwext_local = []; fnameEDRSCHKPwext_local = [];
        fnameEPFSCwext_local = []; fnameEPFSCHKPwext_local = [];
        fnameEPFDFwext_local = []; fnameEPFDFHKPwext_local = [];
end

% Additional EDRs
% for CAL only
switch upper(obs_classType)
    case 'CAL'
        % BI
        [~,basenameBI,fnameBIwext_local] = search_product_EDR('BI',obs_counter,'EDR',dwld_edrscdf,0,ext_edrscdf);
        [~,basenameBIHKP,fnameBIHKPwext_local] = search_product_EDR('BI',obs_counter,'HKP',dwld_edrscdf,0,ext_edrscdf);
    otherwise
        basenameBI = []; basenameBIHKP = [];
        fnameBIwext_local = []; fnameBIHKPwext_local = [];
end

% for ICL only
switch upper(obs_classType)
    case 'ICL'
        % SP
        [~,basenameSP,fnameSPwext_local] = search_product_EDR('SP',obs_counter,'EDR',dwld_edrscdf,0,ext_edrscdf);
        [~,basenameSPHKP,fnameSPHKPwext_local] = search_product_EDR('SP',obs_counter,'HKP',dwld_edrscdf,0,ext_edrscdf);
    otherwise
        basenameSP = []; basenameSPHKP = [];
        fnameSPwext_local = []; fnameSPHKPwext_local = [];
end

% for FRS only
switch upper(obs_classType)
    case 'FRS'
        [~,basenameUN,fnameUNwext_local] = search_product_EDR('UN',obs_counter_un,'EDR',dwld_un,0,ext_un);
    otherwise
        basenameUN = []; fnameUNwext_local = [];
end

% DF
[~,basenameDF,fnameDFwext_local] = search_product_EDR('DF',obs_counter_df,'EDR',dwld_edrscdf,0,ext_edrscdf);
[~,basenameDFHKP,fnameDFHKPwext_local] = search_product_EDR('DF',obs_counter_df,'HKP',dwld_edrscdf,0,ext_edrscdf);

fnamesEDRwext_local = [fnameEDRSCwext_local fnameEDRSCHKPwext_local ...
    fnameEPFSCwext_local fnameEPFSCHKPwext_local fnameEPFDFwext_local ...
    fnameEPFDFHKPwext_local fnameBIwext_local fnameBIHKPwext_local ...
    fnameSPwext_local fnameSPHKPwext_local fnameUNwext_local ...
    fnameDFwext_local fnameDFHKPwext_local];

%-------------------------------------------------------------------------%
% DDR
%-------------------------------------------------------------------------%
switch upper(obs_classType)
    case {'FRT','ATO','FRS','HRL','HRS','MSP','HSP','FFC'}
        search_product_DDR = @(y_oc,w_dwld) crism_search_observation_fromProp(...
             crism_create_propOBSbasename('OBS_CLASS_TYPE',obs_classType,...
            'OBS_ID',obs_id,'ACTIVITY_ID','DE','OBS_COUNTER',y_oc,...
            'SENSOR_ID',sensor_id,'product_type','DDR'),...
            'Dwld',w_dwld,'Match_Exact',true,'Force',force_dwld, ...
            'OUT_FILE',outfile,'Ext',ext_ddr,'INDEX_CACHE_UPDATE',dwld_index_cache_update);
        [dir_info,basenameDDR,fnameDDRwext_local] = search_product_DDR(obs_counter,dwld_ddr);
        dir_ddr = dir_info.dirfullpath_local;
    
        switch upper(obs_classType)
            case {'FRT','HRL','HRS'}
                % EPF
                [~,basenameEPFDDR,fnameEPFDDRwext_local] = search_product_DDR(obs_counter_epf,dwld_epf);
            otherwise
                basenameEPFDDR = []; fnameEPFDDRwext_local = [];
        end
    otherwise
        dir_ddr = ''; basenameDDR = ''; basenameEPFDDR = [];
        fnameDDRwext_local = []; fnameEPFDDRwext_local = [];
end

fnamesDDRwext_local = [fnameDDRwext_local fnameEPFDDRwext_local];

%%
% SUMMARY
obs_info = [];
% basic info
obs_info.obs_id = obs_id;
obs_info.obs_classType = obs_classType;
obs_info.dirname = dirname;
obs_info.yyyy_doy = yyyy_doy;
obs_info.sensor_id = sensor_id;
obs_info.dir_trdr = dir_trdr;
obs_info.dir_edr = dir_edr;
obs_info.dir_ddr = dir_ddr;
obs_info.dir_ter = dir_ter;
obs_info.dir_mtrdr = dir_mtrdr;
% trdr/trr
obs_info.basenameRA = basenameRA;
obs_info.basenameRAHKP = basenameRAHKP;
obs_info.basenameIF = basenameIF;
% obs_info.basenameIFHKP = basenameIFHKP;
obs_info.basenameEPFIF = basenameEPFIF;
obs_info.basenameEPFRA = basenameEPFRA;
obs_info.basenameEPFRAHKP = basenameEPFRAHKP;
% edr/edr
obs_info.basenameSC = basenameSC;
obs_info.basenameSCHKP = basenameSCHKP;
obs_info.basenameDF = basenameDF;
obs_info.basenameDFHKP = basenameDFHKP;
obs_info.basenameEPFSC = basenameEPFSC;
obs_info.basenameEPFSCHKP = basenameEPFSCHKP;
obs_info.basenameEPFDF = basenameEPFDF;
obs_info.basenameEPFDFHKP = basenameEPFDFHKP;
obs_info.basenameBI = basenameBI;
obs_info.basenameBIHKP = basenameBIHKP;
obs_info.basenameSP = basenameSP;
obs_info.basenameSPHKP = basenameSPHKP;
obs_info.basenameUN = basenameUN;
%ddr/ddr
obs_info.basenameDDR = basenameDDR;
obs_info.basenameEPFDDR = basenameEPFDDR;
%ter/ter
obs_info.basenameTERIF = basenameTERIF;
obs_info.basenameTERIN = basenameTERIN;
obs_info.basenameTERSR = basenameTERSR;
obs_info.basenameTERSU = basenameTERSU;
obs_info.basenameTERWV = basenameTERWV;
%mtrdr/MTRDR
obs_info.basenameMTRIF = basenameMTRIF;
obs_info.basenameMTRIN = basenameMTRIN;
obs_info.basenameMTRSR = basenameMTRSR;
obs_info.basenameMTRSU = basenameMTRSU;
obs_info.basenameMTRWV = basenameMTRWV;
obs_info.basenameMTRDE = basenameMTRDE;

obs_info.fnameTERwext_local = fnamesTERwext_local;
obs_info.fnameMTRwext_local = fnamesMTRwext_local;
obs_info.fnameTRRwext_local = fnamesTRRwext_local;
obs_info.fnameEDRwext_local = fnamesEDRwext_local;
obs_info.fnameDDRwext_local = fnamesDDRwext_local;


end







