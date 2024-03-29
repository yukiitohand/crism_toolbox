function [dir_info,basenameADRVS,fnameADRVS_wext_local] = crism_search_adrvs_fromProp(propADRVS,varargin)
% [dir_info,basenameADRVS,fnameADRVS_wext_local] = crism_search_adrvs_fromProp(propADRVS,varargin)
%  get directory path of the given basename of the ADR VS file. The file could
%  be downloaded using an option
%  Inputs
%   propADRVS: basename of the ADR VS file, can be empty.
%  Outputs
%   dir_info struct
%       dirfullpath_local: full local directroy path of the CDR file
%       subdir_local     : subdirectory path
%       subdir_remote    : subdirectory for the remote server
%       acro             : acronym for the CDR data, usually same sa
%                          dirname
%   basenameADRVS: basename of the matched file
%   fnameADRVS_wext_local : cell array of the filenames (with extensions) existing 
%                      locally.
%  Optional Parameters
%      'DWLD','DOWNLOAD' : {0,-1}, -1: list all matched filenames. 0:
%                         nothing happens
%                         (default) 0

global crism_env_vars
localCATrootDir = crism_env_vars.localCATrootDir;

dwld = 0;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

if isempty(propADRVS)
    propADRVS = crism_create_propADRVSbasename();
end

acro = propADRVS.acro_calibration_type;
subdir_local = fullfile('CAT_ENVI','aux_files','ADR',acro);
dirfullpath_local = fullfile(localCATrootDir,subdir_local);
subdir_remote = [];

[basenameADRVSPtrn] = crism_get_basenameADRVS_fromProp(propADRVS);
fnamelist = dir(dirfullpath_local);
[basenameADRVS,fnameADRVS_wext_local] = extractMatchedBasename_v2(basenameADRVSPtrn,[{fnamelist.name}]);
if ischar(basenameADRVS), basenameADRVS = {basenameADRVS}; end
if dwld == -1
    if ~isempty(basesnameCDR)
        for j=1:length(basenameADRVS)
            subpath = fullfile(subdir_local,basenameADRVS{j});
            fprintf('%s\n',subpath);
        end
    end
elseif dwld==1
    error('dwld==1 is not supported for folder_type=3');
end

dir_info = [];
dir_info.dirfullpath_local = dirfullpath_local;
dir_info.subdir_local      = subdir_local;
dir_info.subdir_remote     = subdir_remote;
dir_info.acro              = acro;


end