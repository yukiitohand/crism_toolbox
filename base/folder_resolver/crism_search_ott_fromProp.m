function [dir_info,basenameOTT,fnameOTT_wext_local] = crism_search_ott_fromProp(propOTT,varargin)
% [dir_info,basenameOTT,fnameOTT_wext_local] = crism_search_ott_fromProp(propOTT,varargin)
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
%   fnameOTT_wext_local : cell array of the filenames (with extensions) existing 
%                      locally.
%  Optional Parameters
%      'EXTENSION','EXT': Files with the extention will be downloaded. If
%                         it is empty, then files with any extension will
%                         be downloaded.
%                         (default) ''
%      'OVERWRITE'      : if overwrite the file if exists
%                         (default) 0
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'INDEX_CACHE_UPDATE' : boolean, whether or not to update index.html 
%        (default) false

global crism_env_vars
localrootDir   = crism_env_vars.localCRISM_PDSrootDir;
url_local_root = crism_env_vars.url_local_root;
no_remote      = crism_env_vars.no_remote;

ext = '';
dwld = 0;
overwrite = 0;
index_cache_update = false;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case {'EXT','EXTENSION'}
                ext = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case 'INDEX_CACHE_UPDATE'
                index_cache_update = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

[subdir_local]  = crism_get_subdir_OBS_local('',fullfile('EXTRAS','OTT'),'edr_misc');


dirfullpath_local = fullfile(localrootDir,url_local_root,subdir_local);

[basenamePtrn] = crism_get_basenameOTT_fromProp(propOTT);

if no_remote
    [basenameOTT,fnameOTT_wext_local] = crism_readDownloadBasename(basenamePtrn,...
        subdir_local,dwld,'overwrite',overwrite,'EXTENSION',ext, ...
        'INDEX_CACHE_UPDATE',index_cache_update);
else
    [subdir_remote] = crism_get_subdir_OBS_remote('',fullfile('extras','ott'),'edr_misc');
    subdir_remote = crism_swap_to_remote_path(subdir_remote);
    [basenameOTT,fnameOTT_wext_local] = crism_readDownloadBasename(basenamePtrn,...
        subdir_local,dwld,'subdir_remote',subdir_remote, ...
        'overwrite',overwrite,'EXTENSION',ext, ...
        'INDEX_CACHE_UPDATE',index_cache_update);
end
                
dir_info = [];
dir_info.dirfullpath_local = dirfullpath_local;
dir_info.subdir_local      = subdir_local;
if ~no_remote
    dir_info.subdir_remote     = subdir_remote;
end


end