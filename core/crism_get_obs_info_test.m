function [ obs_info ] = crism_get_obs_info_test(obs_id,varargin)
% [ obs_info ] = get_crism_obs_info_test(obs_id,varargin)
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

dwld_overwrite = 0;
verbose=1;

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
            case 'DWLD_OVERWRITE'
                dwld_overwrite = varargin{i+1};
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

sensor_id = validatestring(sensor_id,{'S','L'});

varargin_for_v2 = { ...
    'YYYY_DOY',yyyy_doy, ...
    'OBS_CLASSTYPE',obs_classType,'SENSOR_ID',sensor_id, ...
    'DWLD_INDEX_CACHE_UPDATE', dwld_index_cache_update, ...
    'DOWNLOAD_TRRIF_CS', dwld_trrif, 'DOWNLOAD_TRRRA_CS', dwld_trrra, ...
    'DOWNLOAD_TRRHKP_CS', dwld_trrrahkp, 'DOWNLOAD_EDR_CS_CSDF', dwld_edrscdf, ...
    'DOWNLOAD_TER', dwld_ter, 'DOWNLOAD_MTR', dwld_mtrdr, ...
    'DOWNLOAD_EPF',dwld_epf, 'DOWNLOAD_DDR_CS',dwld_ddr, ...
    'DOWNLOAD_EDR_UN',dwld_un, 'DOWNLOAD_EDR_DF',dwld_edrscdf, ...
    'DOWNLOAD_EDR_BI',dwld_edrscdf, 'DOWNLOAD_EDR_SP',dwld_edrscdf, ...
    'EXT_TRRIF_CS', ext_trrif, 'EXT_TRRRA_CS', ext_trrra, ...
    'EXT_TRRHKP_CS', ext_trrrahkp, 'EXT_EDR_CS_CSDF', ext_edrscdf, ...
    'EXT_TER', ext_ter, 'EXT_MTR', ext_mtrdr, ...
    'EXT_EPF',ext_epf, 'EXT_DDR_CS',ext_ddr, ...
    'EXT_EDR_UN',ext_un, 'EXT_EDR_DF',ext_edrscdf, ...
    'EXT_EDR_BI',ext_edrscdf, 'EXT_EDR_SP',ext_edrscdf, ...
    'VERBOSE',verbose, 'DWLD_OVERWRITE',dwld_overwrite ...
    };
if OBS_COUNTER_SCENE_custom
    varargin_for_v2 = [varargin_for_v2 {'OBS_COUNTER_CS', obs_counter_tmp}];
end
if OBS_COUNTER_DF_custom
    varargin_for_v2 = [varargin_for_v2 {'OBS_COUNTER_CSDF', obs_counter_df_tmp}];
end

[ obs_info_v2 ] = crism_get_obs_info_v2(obs_id, varargin_for_v2{:});



%%
% SUMMARY
obs_info = [];
% basic info
obs_info.obs_id = obs_id;
obs_info.obs_classType = obs_info_v2.obs_class_type;
obs_info.dirname   = obs_info_v2.dirname;
obs_info.yyyy_doy  = obs_info_v2.yyyy_doy;
obs_info.sensor_id = sensor_id;

obs_info.dir_trdr  = obs_info_v2.dir_info.trr.dirfullpath_local;
obs_info.dir_edr   = obs_info_v2.dir_info.edr.dirfullpath_local;
obs_info.dir_ddr   = obs_info_v2.dir_info.ddr.dirfullpath_local;
obs_info.dir_ter   = obs_info_v2.dir_info.ter.dirfullpath_local;
obs_info.dir_mtrdr = obs_info_v2.dir_info.mtr.dirfullpath_local;

% central scan
basenameIF = ''; basenameRA = ''; basenameRAHKP = '';
basenameSC = ''; basenameSCHKP = ''; basenameDDR = '';
%ter/ter
basenameTERIF = ''; basenameTERIN = ''; basenameTERSR = '';
basenameTERSU = ''; basenameTERWV = '';
%mtrdr/MTRDR
basenameMTRIF = ''; basenameMTRIN = ''; basenameMTRSR = '';
basenameMTRSU = ''; basenameMTRWV = ''; basenameMTRDE = '';
basenameDF = ''; basenameDFHKP = '';
if isfield(obs_info_v2,'central_scan_info')
    cs_sgmnt_info = obs_info_v2.sgmnt_info(obs_info_v2.central_scan_info.indx);
    for i_sgid=1:length(cs_sgmnt_info)
        if isfield(cs_sgmnt_info(i_sgid),sensor_id)
            if isfield(cs_sgmnt_info(i_sgid).(sensor_id),'trr')
                if isfield(cs_sgmnt_info(i_sgid).(sensor_id).trr,'IF')
                    basenameIF = [basenameIF cs_sgmnt_info(i_sgid).(sensor_id).trr.IF];
                end
                if isfield(cs_sgmnt_info(i_sgid).(sensor_id).trr,'RA')
                    basenameRA = [basenameRA cs_sgmnt_info(i_sgid).(sensor_id).trr.RA];
                end
                if isfield(cs_sgmnt_info(i_sgid).(sensor_id).trr,'HKP')
                    basenameRAHKP = [basenameRAHKP cs_sgmnt_info(i_sgid).(sensor_id).trr.HKP];
                end
            end
            if isfield(cs_sgmnt_info(i_sgid).(sensor_id),'edr')
                if isfield(cs_sgmnt_info(i_sgid).(sensor_id).edr,'SC')
                    basenameSC = [basenameSC cs_sgmnt_info(i_sgid).(sensor_id).edr.SC];
                end
                if isfield(cs_sgmnt_info(i_sgid).(sensor_id).edr,'HKP')
                    basenameSCHKP = [basenameSCHKP cs_sgmnt_info(i_sgid).(sensor_id).edr.HKP];
                end
            end
            if isfield(cs_sgmnt_info(i_sgid).(sensor_id),'ddr')
                if isfield(cs_sgmnt_info(i_sgid).(sensor_id).ddr,'DE')
                    basenameDDR = [basenameDDR cs_sgmnt_info(i_sgid).(sensor_id).ddr.DE];
                end
            end
            if isfield(cs_sgmnt_info(i_sgid).(sensor_id),'mtr')
                if isfield(cs_sgmnt_info(i_sgid).(sensor_id).mtr,'DE')
                    basenameMTRDE = [basenameMTRDE cs_sgmnt_info(i_sgid).(sensor_id).mtr.DE];
                end
            end
        end
        if isfield(cs_sgmnt_info(i_sgid),'J') 
            if isfield(cs_sgmnt_info(i_sgid).J,'ter')
                if isfield(cs_sgmnt_info(i_sgid).J.ter,'IF')
                    basenameTERIF = [basenameTERIF cs_sgmnt_info(i_sgid).J.ter.IF];
                end
                if isfield(cs_sgmnt_info(i_sgid).J.ter,'IN')
                    basenameTERIN = [basenameTERIN cs_sgmnt_info(i_sgid).J.ter.IN];
                end
                if isfield(cs_sgmnt_info(i_sgid).J.ter,'SR')
                    basenameTERSR = [basenameTERSR cs_sgmnt_info(i_sgid).J.ter.SR];
                end
                if isfield(cs_sgmnt_info(i_sgid).J.ter,'SU')
                    basenameTERSU = [basenameTERSU cs_sgmnt_info(i_sgid).J.ter.SU];
                end
                if isfield(cs_sgmnt_info(i_sgid).J.ter,'WV')
                    basenameTERWV = [basenameTERWV cs_sgmnt_info(i_sgid).J.ter.WV];
                end
            end
            if isfield(cs_sgmnt_info(i_sgid).J,'mtr')
                if isfield(cs_sgmnt_info(i_sgid).J.mtr,'IF')
                    basenameMTRIF = [basenameMTRIF cs_sgmnt_info(i_sgid).J.mtr.IF];
                end
                if isfield(cs_sgmnt_info(i_sgid).J.mtr,'IN')
                    basenameMTRIN = [basenameMTRIN cs_sgmnt_info(i_sgid).J.mtr.IN];
                end
                if isfield(cs_sgmnt_info(i_sgid).J.mtr,'SR')
                    basenameMTRSR = [basenameMTRSR cs_sgmnt_info(i_sgid).J.mtr.SR];
                end
                if isfield(cs_sgmnt_info(i_sgid).J.mtr,'SU')
                    basenameMTRSU = [basenameMTRSU cs_sgmnt_info(i_sgid).J.mtr.SU];
                end
                if isfield(cs_sgmnt_info(i_sgid).J.mtr,'WV')
                    basenameMTRWV = [basenameMTRWV cs_sgmnt_info(i_sgid).J.mtr.WV];
                end
            end
        end
    end
    csdf_sgmnt_info = obs_info_v2.sgmnt_info(obs_info_v2.central_scan_info.df_indx);
    for i_sgid=1:length(csdf_sgmnt_info)
        if isfield(csdf_sgmnt_info(i_sgid),sensor_id)
            if isfield(csdf_sgmnt_info(i_sgid).(sensor_id),'edr')
                if isfield(csdf_sgmnt_info(i_sgid).(sensor_id).edr,'DF')
                    basenameDF = [basenameDF csdf_sgmnt_info(i_sgid).(sensor_id).edr.DF];
                end
                if isfield(csdf_sgmnt_info(i_sgid).(sensor_id).edr,'HKP')
                    basenameDFHKP = [basenameDFHKP csdf_sgmnt_info(i_sgid).(sensor_id).edr.HKP];
                end
            end
        end
    end

    % central scan
    if length(basenameIF)==1,    basenameIF = basenameIF{1};       end
    if length(basenameRA)==1,    basenameRA = basenameRA{1};       end
    if length(basenameRAHKP)==1, basenameRAHKP = basenameRAHKP{1}; end
    if length(basenameSC)==1,    basenameSC = basenameSC{1};       end
    if length(basenameSCHKP)==1, basenameSCHKP = basenameSCHKP{1}; end
    if length(basenameDDR)==1,   basenameDDR = basenameDDR{1};     end
    %ter/ter
    if length(basenameTERIF)==1, basenameTERIF = basenameTERIF{1}; end
    if length(basenameTERIN)==1, basenameTERIN = basenameTERIN{1}; end
    if length(basenameTERSR)==1, basenameTERSR = basenameTERSR{1}; end
    if length(basenameTERSU)==1, basenameTERSU = basenameTERSU{1}; end
    if length(basenameTERWV)==1, basenameTERWV = basenameTERWV{1}; end
    %mtrdr/MTRDR
    if length(basenameMTRIF)==1, basenameMTRIF = basenameMTRIF{1}; end
    if length(basenameMTRIN)==1, basenameMTRIN = basenameMTRIN{1}; end
    if length(basenameMTRSR)==1, basenameMTRSR = basenameMTRSR{1}; end
    if length(basenameMTRSU)==1, basenameMTRSU = basenameMTRSU{1}; end
    if length(basenameMTRWV)==1, basenameMTRWV = basenameMTRWV{1}; end
    if length(basenameMTRDE)==1, basenameMTRDE = basenameMTRDE{1}; end
    % df
    if length(basenameDF)==1,    basenameDF = basenameDF{1};       end
    if length(basenameDFHKP)==1, basenameDFHKP = basenameDFHKP{1}; end
end


basenameEPFIF = ''; basenameEPFRA = ''; basenameEPFRAHKP = '';
basenameEPFSC = ''; basenameEPFSCHKP = ''; basenameEPFDDR = '';
basenameEPFDF = ''; basenameEPFDFHKP = '';

if isfield(obs_info_v2,'epf_info')
    epf_sgmnt_info = obs_info_v2.sgmnt_info(obs_info_v2.epf_info.indx);
    for i_sgid=1:length(epf_sgmnt_info)
        if isfield(epf_sgmnt_info(i_sgid),sensor_id)
            if isfield(epf_sgmnt_info(i_sgid).(sensor_id),'trr')
                if isfield(epf_sgmnt_info(i_sgid).(sensor_id).trr,'IF')
                    basenameEPFIF = [basenameEPFIF epf_sgmnt_info(i_sgid).(sensor_id).trr.IF];
                end
                if isfield(epf_sgmnt_info(i_sgid).(sensor_id).trr,'RA')
                    basenameEPFRA = [basenameEPFRA epf_sgmnt_info(i_sgid).(sensor_id).trr.RA];
                end
                if isfield(epf_sgmnt_info(i_sgid).(sensor_id).trr,'HKP')
                    basenameEPFRAHKP = [basenameEPFRAHKP epf_sgmnt_info(i_sgid).(sensor_id).trr.HKP];
                end
            end
            if isfield(epf_sgmnt_info(i_sgid).(sensor_id),'edr')
                if isfield(epf_sgmnt_info(i_sgid).(sensor_id).edr,'SC')
                    basenameEPFSC = [basenameEPFSC epf_sgmnt_info(i_sgid).(sensor_id).edr.SC];
                end
                if isfield(epf_sgmnt_info(i_sgid).(sensor_id).edr,'HKP')
                    basenameEPFSCHKP = [basenameEPFSCHKP epf_sgmnt_info(i_sgid).(sensor_id).edr.HKP];
                end
            end
            if isfield(epf_sgmnt_info(i_sgid).(sensor_id),'ddr')
                if isfield(epf_sgmnt_info(i_sgid).(sensor_id).ddr,'DE')
                    basenameEPFDDR = [basenameEPFDDR epf_sgmnt_info(i_sgid).(sensor_id).ddr.DE];
                end
            end
        end
    end

    epfdf_sgmnt_info = obs_info_v2.sgmnt_info(obs_info_v2.epf_info.df_indx);
    for i_sgid=1:length(epfdf_sgmnt_info)
        if isfield(epfdf_sgmnt_info(i_sgid),sensor_id)
            if isfield(epfdf_sgmnt_info(i_sgid).(sensor_id),'edr')
                if isfield(epfdf_sgmnt_info(i_sgid).(sensor_id).edr,'DF')
                    basenameEPFDF = [basenameEPFDF epfdf_sgmnt_info(i_sgid).(sensor_id).edr.DF];
                end
                if isfield(epfdf_sgmnt_info(i_sgid).(sensor_id).edr,'HKP')
                    basenameEPFDFHKP = [basenameEPFDFHKP epfdf_sgmnt_info(i_sgid).(sensor_id).edr.HKP];
                end
            end
        end
    end
    % epf
    if length(basenameEPFIF)==1,    basenameEPFIF = basenameEPFIF{1};       end
    if length(basenameEPFRA)==1,    basenameEPFRA = basenameEPFRA{1};       end
    if length(basenameEPFRAHKP)==1, basenameEPFRAHKP = basenameEPFRAHKP{1}; end
    if length(basenameEPFSC)==1,    basenameEPFSC = basenameEPFSC{1};       end
    if length(basenameEPFSCHKP)==1, basenameEPFSCHKP = basenameEPFSCHKP{1}; end
    if length(basenameEPFDDR)==1,   basenameEPFDDR = basenameEPFDDR{1};     end
    if length(basenameEPFDF)==1,    basenameEPFDF = basenameEPFDF{1};       end
    if length(basenameEPFDFHKP)==1, basenameEPFDFHKP = basenameEPFDFHKP{1}; end
end

basenameUN = ''; basenameUNHKP = '';
if isfield(obs_info_v2,'un_info')
    un_sgmnt_info = obs_info_v2.sgmnt_info(obs_info_v2.un_info.indx);
    for i_sgid=1:length(un_sgmnt_info)
        if isfield(un_sgmnt_info(i_sgid),sensor_id)
            if isfield(un_sgmnt_info(i_sgid).(sensor_id),'edr')
                if isfield(un_sgmnt_info(i_sgid).(sensor_id).edr,'UN')
                    basenameUN = [basenameUN un_sgmnt_info(i_sgid).(sensor_id).edr.UN];
                end
                if isfield(un_sgmnt_info(i_sgid).(sensor_id).edr,'HKP')
                    basenameUNHKP = [basenameUNHKP un_sgmnt_info(i_sgid).(sensor_id).edr.HKP];
                end
            end
        end
    end
    if length(basenameUN)==1,    basenameUN = basenameUN{1};       end
    if length(basenameUNHKP)==1, basenameUNHKP = basenameUNHKP{1}; end
end

basenameSP = ''; basenameSPHKP = '';
if isfield(obs_info_v2,'sp_info')
    sp_sgmnt_info = obs_info_v2.sgmnt_info(obs_info_v2.sp_info.indx);
    for i_sgid=1:length(sp_sgmnt_info)
        if isfield(sp_sgmnt_info(i_sgid),sensor_id)
            if isfield(sp_sgmnt_info(i_sgid).(sensor_id),'edr')
                if isfield(sp_sgmnt_info(i_sgid).(sensor_id).edr,'SP')
                    basenameSP = [basenameSP sp_sgmnt_info(i_sgid).(sensor_id).edr.SP];
                end
                if isfield(sp_sgmnt_info(i_sgid).(sensor_id).edr,'HKP')
                    basenameSPHKP = [basenameSPHKP sp_sgmnt_info(i_sgid).(sensor_id).edr.HKP];
                end
            end
        end
    end

    spdf_sgmnt_info = obs_info_v2.sgmnt_info(obs_info_v2.sp_info.df_indx);
    for i_sgid=1:length(spdf_sgmnt_info)
        if isfield(spdf_sgmnt_info(i_sgid),sensor_id)
            if isfield(spdf_sgmnt_info(i_sgid).(sensor_id),'edr')
                if isfield(spdf_sgmnt_info(i_sgid).(sensor_id).edr,'DF')
                    basenameDF = [basenameDF spdf_sgmnt_info(i_sgid).(sensor_id).edr.DF];
                end
                if isfield(spdf_sgmnt_info(i_sgid).(sensor_id).edr,'HKP')
                    basenameDFHKP = [basenameDFHKP spdf_sgmnt_info(i_sgid).(sensor_id).edr.HKP];
                end
            end
        end
    end
    if length(basenameSP)==1,    basenameSP = basenameSP{1};       end
    if length(basenameSPHKP)==1, basenameSPHKP = basenameSPHKP{1}; end
    if length(basenameDF)==1,    basenameDF = basenameDF{1};       end
    if length(basenameDFHKP)==1, basenameDFHKP = basenameDFHKP{1}; end
end

basenameBI = ''; basenameBIHKP = '';
if isfield(obs_info_v2,'bi_info')
    bi_sgmnt_info = obs_info_v2.sgmnt_info(obs_info_v2.bi_info.indx);
    for i_sgid=1:length(bi_sgmnt_info)
        if isfield(bi_sgmnt_info(i_sgid),sensor_id)
            if isfield(bi_sgmnt_info(i_sgid).(sensor_id),'edr')
                if isfield(bi_sgmnt_info(i_sgid).(sensor_id).edr,'BI')
                    basenameBI = [basenameBI bi_sgmnt_info(i_sgid).(sensor_id).edr.BI];
                end
                if isfield(bi_sgmnt_info(i_sgid).(sensor_id).edr,'HKP')
                    basenameBIHKP = [basenameBIHKP bi_sgmnt_info(i_sgid).(sensor_id).edr.HKP];
                end
            end
        end
    end
    if length(basenameBI)==1,    basenameBI = basenameBI{1};       end
    if length(basenameBIHKP)==1, basenameBIHKP = basenameBIHKP{1}; end
end

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

% obs_info.fnameTERwext_local = fnamesTERwext_local;
% obs_info.fnameMTRwext_local = fnamesMTRwext_local;
% obs_info.fnameTRRwext_local = fnamesTRRwext_local;
% obs_info.fnameEDRwext_local = fnamesEDRwext_local;
% obs_info.fnameDDRwext_local = fnamesDDRwext_local;


end







