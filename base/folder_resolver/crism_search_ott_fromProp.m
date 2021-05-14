function [dir_info,basenameOTT] = crism_search_ott_fromProp(propOTT,varargin)
% [dir_info,basenameOTT] = crism_search_ott_fromProp(propOTT,varargin)
%  get directory path of the OTT files. The file could
%  be downloaded using an option
%  Inputs
%   basenameOTT: basename of the OTT file
%  Outputs
%   dir_info struct
%       dirfullpath_local: full local directroy path of the CDR file
%       subdir_local     : subdirectory path
%       subdir_remote    : subdirectory for the remote server
%   basenameOTT  : basename of the matched file
%  Optional Parameters 
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false

global crism_env_vars
localrootDir = crism_env_vars.localCRISM_PDSrootDir;
url_local_root = crism_env_vars.url_local_root;

dwld = 0;
force = 0;
outfile = '';

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

[subdir_local]  = crism_get_subdir_OBS_local('','EXTRAS/OTT/','edr_misc');
[subdir_remote] = crism_get_subdir_OBS_remote('','extras/ott/','edr_misc');

dirfullpath_local = joinPath(localrootDir,url_local_root,subdir_local);

[basenamePtrn] = get_basenameOTT_fromProp(propOTT);
[basenameOTT] = crism_readDownloadBasename(basenamePtrn,...
                    subdir_local,subdir_remote,dwld,'Force',force,'Out_File',outfile);
                
dir_info = [];
dir_info.dirfullpath_local = dirfullpath_local;
dir_info.subdir_local      = subdir_local;
dir_info.subdir_remote     = subdir_remote;


end