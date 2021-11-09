function [cataux_obsinfo] = crism_get_cataux_obsinfo(obs_id)
% [cataux_obsinfo] = crism_get_cataux_obsinfo(obs_id)
%  Get information from 
%   CAT_ENVI/aux_files/obs_info/crism_obs_info.txt
%  INPUTS
%   obs_id : char, observation ID
%  OUTPUTS
%   cataux_obs_info : struct holding the following information
%      obs_class_type
%      partition
%      sclk
%      bench_temp
%      utc
%      vsid_mcg : preselected obsid for the atm volcano scan correction for
%        the McGuire bandset mode.
%      vsid_pel : preselected obsid for the atm volcano scan correction for
%        the Pelky bandset mode.
%

global crism_env_vars

fpath_self = mfilename('fullpath');
[dirpath_self,filename] = fileparts(fpath_self);
cache_fname = 'CRISM_CATAUX_CRISM_OBS_INFO.mat';
cachefpath = joinPath(dirpath_self,cache_fname);

if ~exist(cachefpath,'file')

    localCATrootDir = crism_env_vars.localCATrootDir;
    % dirpath_cataux = joinPath(localCATrootDir,'aux_files');
    dirpath_cataux_obs_info = joinPath(localCATrootDir,'CAT_ENVI/aux_files/obs_info');

    fname_cataux_obsinfo = 'crism_obs_info.txt';
    fpath_cataux_crism_obsinfo = joinPath(dirpath_cataux_obs_info,fname_cataux_obsinfo);
    fid = fopen(fpath_cataux_crism_obsinfo,'r');
    data = fread(fid,'char*1');
    data = convertCharsToStrings(char(data));
    data = splitlines(data);
    data = cat(1,data{:});
    fclose(fid);

    OBS_ID_LIST         = data(:,2:9);
    OBS_CLASS_TYPE_LIST = data(:,11:13);
    PARTITION_LIST      = data(:,17);
    SCLK_LIST           = data(:,19:28);
    BENCH_TEMP_LIST     = data(:,32:38);
    UTC_LIST            = data(:,41:63);
    VSID_MCG_LIST       = data(:,65:69);
    VSID_PEL_LIST       = data(:,71:75);

    OBS_ID_DEC_LIST = hex2dec(OBS_ID_LIST);
    PARTITION_LIST  = uint8(str2num(PARTITION_LIST));
    SCLK_LIST       = str2num(SCLK_LIST);
    BENCH_TEMP_LIST = str2num(BENCH_TEMP_LIST);

    save(cachefpath,'OBS_ID_DEC_LIST','OBS_CLASS_TYPE_LIST', ...
        'PARTITION_LIST','SCLK_LIST','BENCH_TEMP_LIST','UTC_LIST', ...
        'VSID_MCG_LIST','VSID_PEL_LIST','-v7');
    
else
    load(cachefpath,'OBS_ID_DEC_LIST','OBS_CLASS_TYPE_LIST', ...
        'PARTITION_LIST','SCLK_LIST','BENCH_TEMP_LIST','UTC_LIST', ...
        'VSID_MCG_LIST','VSID_PEL_LIST');
end

obs_id_dec = hex2dec(obs_id);
mtch_idx = find(obs_id_dec==OBS_ID_DEC_LIST);

cataux_obsinfo = [];
if mtch_idx
    cataux_obsinfo.obs_class_type = OBS_CLASS_TYPE_LIST(mtch_idx,:);
    cataux_obsinfo.partition      = PARTITION_LIST(mtch_idx);
    cataux_obsinfo.sclk           = SCLK_LIST(mtch_idx);
    cataux_obsinfo.bench_temp     = BENCH_TEMP_LIST(mtch_idx);
    cataux_obsinfo.utc            = UTC_LIST(mtch_idx,:);
    cataux_obsinfo.vsid_mcg       = VSID_MCG_LIST(mtch_idx,:);
    cataux_obsinfo.vsid_pel       = VSID_PEL_LIST(mtch_idx,:);
end

end