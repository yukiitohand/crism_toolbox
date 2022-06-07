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
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false
%      'EXTENSION','EXT': Files with the extention will be downloaded. If
%                         it is empty, then files with any extension will
%                         be downloaded.
%                         (default) ''
%      'OVERWRITE'      : if overwrite the file if exists
%                         (default) 0
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'VERBOSE'        : boolean, whether or not to show the downloading
%                         operations.
%                         (default) true
%      'CAPITALIZE_FILENAME' : whether or not capitalize the filenames or
%      not
%        (default) true
%      'INDEX_CACHE_UPDATE' : boolean, whether or not to update index.html 
%        (default) false

global crism_env_vars
localrootDir   = crism_env_vars.localCRISM_PDSrootDir;
url_local_root = crism_env_vars.url_local_root;
no_remote      = crism_env_vars.no_remote;

ext = '';
dwld = 0;
force = 0;
outfile = '';

overwrite = 0;
cap_filename  = true;
index_cache_update = false;
verbose = true;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case {'EXT','EXTENSION'}
                ext = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            case 'VERBOSE'
                verbose = varargin{i+1};
            case 'INDEX_CACHE_UPDATE'
                index_cache_update = varargin{i+1};
            case 'CAPITALIZE_FILENAME'
                cap_filename = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

[subdir_local]  = crism_get_subdir_OBS_local('','EXTRAS/OTT/','edr_misc');


dirfullpath_local = joinPath(localrootDir,url_local_root,subdir_local);

[basenamePtrn] = crism_get_basenameOTT_fromProp(propOTT);

if no_remote
    [basenameOTT,fnameOTT_wext_local] = crism_readDownloadBasename(basenamePtrn,...
        subdir_local,dwld, ...
        'Force',force,'Out_File',outfile,...
        'overwrite',overwrite,'EXTENSION',ext, ...
        'INDEX_CACHE_UPDATE',index_cache_update, ...
        'VERBOSE',verbose,'CAPITALIZE_FILENAME',cap_filename);
else
    [subdir_remote] = crism_get_subdir_OBS_remote('','extras/ott/','edr_misc');
    [basenameOTT,fnameOTT_wext_local] = crism_readDownloadBasename(basenamePtrn,...
        subdir_local,dwld,'subdir_remote',subdir_remote, ...
        'Force',force,'Out_File',outfile,...
        'overwrite',overwrite,'EXTENSION',ext, ...
        'INDEX_CACHE_UPDATE',index_cache_update, ...
        'VERBOSE',verbose,'CAPITALIZE_FILENAME',cap_filename);
end
                
dir_info = [];
dir_info.dirfullpath_local = dirfullpath_local;
dir_info.subdir_local      = subdir_local;
if ~no_remote
    dir_info.subdir_remote     = subdir_remote;
end


end