function [dir_info,basenameADRVS] = crism_search_adrvs_fromProp(propADRVS,varargin)
% [dir_info,basenameADRVS] = crism_search_adrvs_fromProp(propADRVS,varargin)
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
%  Optional Parameters
%      'DWLD','DOWNLOAD' : {0,-1}, -1: list all matched filenames. 0:
%                         nothing happens
%                         (default) 0
%      'OUT_FILE'       : path to the output file. if empty, nothing
%                         happens.
%                         (default) ''

global crism_env_vars
localCATrootDir = crism_env_vars.localCATrootDir;

dwld = 0;
outfile = '';

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            otherwise
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

if isempty(propADRVS)
    propADRVS = create_propADRVSbasename();
end

acro = propADRVS.acro_calibration_type;
subdir_local = joinPath('CAT_ENVI/aux_files/ADR/',acro);
dirfullpath_local = joinPath(localCATrootDir,subdir_local);
subdir_remote = '';

[basenameADRVSPtrn] = get_basenameADRVS_fromProp(propADRVS);
fnamelist = dir(dirfullpath_local);
[basenameADRVS] = extractMatchedBasename_v2(basenameADRVSPtrn,[{fnamelist.name}]);
if ischar(basenameADRVS), basenameADRVS = {basenameADRVS}; end
if dwld == -1
    if ~isempty(outfile)
        fp = fopen(outfile,'a');
    end
    if ~isempty(basesnameCDR)
        for j=1:length(basenameADRVS)
            subpath = joinPath(subdir_local,basenameADRVS{j});
            if ~isempty(outfile)
                fprintf(fp,'%s\n',subpath);
            end
            fprintf('%s\n',subpath);
        end
    end
    if ~isempty(outfile)
        fclose(fp);
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