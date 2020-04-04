function [ obs_info ] = get_crism_obs_info(obs_id,varargin)
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
%      
%
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
dwld_ter = 0;
dwld_mtrdr = 0;
dwld_trrif = 0;
dwld_trrra = 0;
dwld_edrscdf = 0;
dwld_ddr = 0;
dwld_epf = 0;
dwld_un = 0;

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
            case 'DOWNLOAD_TRRIF'
                dwld_trrif = varargin{i+1};
            case 'DOWNLOAD_TRRRA'
                dwld_trrra = varargin{i+1};
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
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

% zero-padding if not
obs_id = upper(pad_obs_id(obs_id));

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
base_dir = upper([obs_classType obs_id]);


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
     get_basenameOBS_dirpath_TER = @(x_ai) get_dirpath_observation_fromProp(...
         create_propOBSbasename('OBS_CLASS_TYPE',obs_classType,...
        'OBS_ID',obs_id,'ACTIVITY_ID',x_ai,'OBS_COUNTER',obs_counter,...
        'SENSOR_ID','J','product_type','TER'),...
        'Dwld',dwld_ter,'Match_Exact',true,'Force',force_dwld,'OUT_FILE',outfile);
    
    % [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname,basenameOBS]
    [dir_ter,~,~,~,~,basenameTERIF] = get_basenameOBS_dirpath_TER('IF');
    [~,~,~,~,~,basenameTERIN] = get_basenameOBS_dirpath_TER('IN');
    [~,~,~,~,~,basenameTERSR] = get_basenameOBS_dirpath_TER('SR');
    [~,~,~,~,~,basenameTERSU] = get_basenameOBS_dirpath_TER('SU');
    [~,~,~,~,~,basenameTERWV] = get_basenameOBS_dirpath_TER('WV');
    
else
    dir_ter = ''; basenameTERIF = ''; basenameTERIN = ''; basenameTERSR = '';
    basenameTERSU = ''; basenameTERWV = '';
end
%
%-------------------------------------------------------------------------%
% MTRDR
%-------------------------------------------------------------------------%
if any(strcmpi(obs_classType,{'FRT','ATO','FRS','HRL','HRS'}))
    get_basenameOBS_dirpath_MTR = @(x_ai,y_si) get_dirpath_observation_fromProp(...
         create_propOBSbasename('OBS_CLASS_TYPE',obs_classType,...
        'OBS_ID',obs_id,'ACTIVITY_ID',x_ai,'OBS_COUNTER',obs_counter,...
        'SENSOR_ID',y_si,'product_type','MTR'),...
        'Dwld',dwld_mtrdr,'Match_Exact',true,'Force',force_dwld,'OUT_FILE',outfile);
    
    % [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname,basenameOBS]
    [dir_mtrdr,~,~,~,~,basenameMTRIF] = get_basenameOBS_dirpath_MTR('IF','J');
    [~,~,~,~,~,basenameMTRIN] = get_basenameOBS_dirpath_MTR('IN','J');
    [~,~,~,~,~,basenameMTRSR] = get_basenameOBS_dirpath_MTR('SR','J');
    [~,~,~,~,~,basenameMTRSU] = get_basenameOBS_dirpath_MTR('SU','J');
    [~,~,~,~,~,basenameMTRWV] = get_basenameOBS_dirpath_MTR('WV','J');
    [~,~,~,~,~,basenameMTRDE] = get_basenameOBS_dirpath_MTR('DE','L');
    
else
    dir_mtrdr = ''; basenameMTRIF = ''; basenameMTRIN = ''; basenameMTRSR = '';
    basenameMTRSU = ''; basenameMTRWV = ''; basenameMTRDE = '';
end
%-------------------------------------------------------------------------%
% TRR
%-------------------------------------------------------------------------%
if any(strcmpi(obs_classType,{'FRT','ATO','FRS','HRL','HRS','MSP','HSP','FFC'}))
    get_basenameOBS_dirpath_TRR = @(x_ai,y_oc,z_pd,w_dwld,v) get_dirpath_observation_fromProp(...
         create_propOBSbasename('OBS_CLASS_TYPE',obs_classType,...
        'OBS_ID',obs_id,'ACTIVITY_ID',x_ai,'OBS_COUNTER',y_oc,...
        'SENSOR_ID',sensor_id,'product_type',z_pd,'Version',v),...
        'Dwld',w_dwld,'Match_Exact',true,'Force',force_dwld,'OUT_FILE',outfile);
    
    % [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname,basenameOBS]
    [dir_trdr,~,~,~,~,basenameIF] = get_basenameOBS_dirpath_TRR('IF',obs_counter,'TRR',dwld_trrif,3);
    [~,~,~,~,~,basenameRA] = get_basenameOBS_dirpath_TRR('RA',obs_counter,'TRR',dwld_trrra,3);
    [~,~,~,~,~,basenameRAHKP] = get_basenameOBS_dirpath_TRR('RA',obs_counter,'HKP',dwld_trrra,3);
    
    if any(strcmpi(obs_classType,{'FRT','HRL','HRS'}))
        % EPF
        [~,~,~,~,~,basenameEPFIF] = get_basenameOBS_dirpath_TRR('IF',obs_counter_epf,'TRR',dwld_epf,3);
        [~,~,~,~,~,basenameEPFRA] = get_basenameOBS_dirpath_TRR('RA',obs_counter_epf,'TRR',dwld_epf,3);
        [~,~,~,~,~,basenameEPFRAHKP] = get_basenameOBS_dirpath_TRR('RA',obs_counter_epf,'HKP',dwld_epf,3);
    else
        basenameEPFIF = []; basenameEPFRA = []; basenameEPFRAHKP = [];
    end
else
    dir_trdr = ''; basenameIF = ''; basenameRA = ''; basenameRAHKP = '';
    basenameEPFIF = []; basenameEPFRA = []; basenameEPFRAHKP = [];
end
%-------------------------------------------------------------------------%
% EDR
%-------------------------------------------------------------------------%
get_basenameOBS_dirpath_EDR = @(x_ai,y_oc,z_pd,w_dwld,v) get_dirpath_observation_fromProp(...
         create_propOBSbasename('OBS_CLASS_TYPE',obs_classType,...
        'OBS_ID',obs_id,'ACTIVITY_ID',x_ai,'OBS_COUNTER',y_oc,...
        'SENSOR_ID',sensor_id,'product_type',z_pd,'Version',v),...
        'Dwld',w_dwld,'Match_Exact',true,'Force',force_dwld,'OUT_FILE',outfile);

if any(strcmpi(obs_classType,{'FRT','ATO','FRS','HRL','HRS','MSP','HSP','FFC'})) 
    % SC
    [dir_edr,~,~,~,~,basenameSC] = get_basenameOBS_dirpath_EDR('SC',obs_counter,'EDR',dwld_edrscdf,0);
    [~,~,~,~,~,basenameSCHKP] = get_basenameOBS_dirpath_EDR('SC',obs_counter,'HKP',dwld_edrscdf,0);

    if any(strcmpi(obs_classType,{'FRT','HRL','HRS'}))
        [~,~,~,~,~,basenameEPFSC] = get_basenameOBS_dirpath_EDR('SC',obs_counter_epf,'EDR',dwld_epf,0);
        [~,~,~,~,~,basenameEPFSCHKP] = get_basenameOBS_dirpath_EDR('SC',obs_counter_epf,'HKP',dwld_epf,0);
        % DF
        [~,~,~,~,~,basenameEPFDF] = get_basenameOBS_dirpath_EDR('DF',obs_counter_epfdf,'EDR',dwld_epf,0);
        [~,~,~,~,~,basenameEPFDFHKP] = get_basenameOBS_dirpath_EDR('DF',obs_counter_epfdf,'HKP',dwld_epf,0);
    else
        basenameEPFSC = []; basenameEPFDF = []; basenameEPFSCHKP = []; basenameEPFDFHKP = [];
    end
else
    basenameSC = ''; basenameSCHKP = []; basenameEPFSC = []; 
    basenameEPFDF = []; basenameEPFSCHKP = []; basenameEPFDFHKP = [];
end
if any(strcmpi(obs_classType,{'CAL'}))
    % BI
    [dir_edr,~,~,~,~,basenameBI] = get_basenameOBS_dirpath_EDR('BI',obs_counter,'EDR',dwld_edrscdf,0);
    [~,~,~,~,~,basenameBIHKP] = get_basenameOBS_dirpath_EDR('BI',obs_counter,'HKP',dwld_edrscdf,0);
else
   basenameBI = []; basenameBIHKP = [];
end
if any(strcmpi(obs_classType,{'ICL'}))
    % SP
    [dir_edr,~,~,~,~,basenameSP] = get_basenameOBS_dirpath_EDR('SP',obs_counter,'EDR',dwld_edrscdf,0);
    [~,~,~,~,~,basenameSPHKP] = get_basenameOBS_dirpath_EDR('SP',obs_counter,'HKP',dwld_edrscdf,0);
else
   basenameSP = []; basenameSPHKP = [];
end

% for FRS only
if strcmpi(obs_classType,'FRS')
    [~,~,~,~,~,basenameUN] = get_basenameOBS_dirpath_EDR('UN',obs_counter_un,'EDR',dwld_un,0);
else
    basenameUN = [];
end

% DF
[dir_edr,~,~,~,~,basenameDF] = get_basenameOBS_dirpath_EDR('DF',obs_counter_df,'EDR',dwld_edrscdf,0);
[~,~,~,~,~,basenameDFHKP] = get_basenameOBS_dirpath_EDR('DF',obs_counter_df,'HKP',dwld_edrscdf,0);


%-------------------------------------------------------------------------%
% DDR
%-------------------------------------------------------------------------%
if any(strcmpi(obs_classType,{'FRT','ATO','FRS','HRL','HRS','MSP','HSP','FFC'}))
    get_basenameOBS_dirpath_DDR = @(y_oc,w_dwld) get_dirpath_observation_fromProp(...
         create_propOBSbasename('OBS_CLASS_TYPE',obs_classType,...
        'OBS_ID',obs_id,'ACTIVITY_ID','DE','OBS_COUNTER',y_oc,...
        'SENSOR_ID',sensor_id,'product_type','DDR'),...
        'Dwld',w_dwld,'Match_Exact',true,'Force',force_dwld,'OUT_FILE',outfile);
    [dir_ddr,~,~,~,~,basenameDDR] = get_basenameOBS_dirpath_DDR(obs_counter,dwld_ddr);

    if any(strcmpi(obs_classType,{'FRT','HRL','HRS'}))
        % EPF
        [~,~,~,~,~,basenameEPFDDR] = get_basenameOBS_dirpath_DDR(obs_counter_epf,dwld_epf);
    else
        basenameEPFDDR = [];
    end
else
    dir_ddr = ''; basenameDDR = ''; basenameEPFDDR = [];
end

obs_info = [];
% summary
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


end







