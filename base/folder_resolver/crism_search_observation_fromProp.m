function [dir_info,basenameOBS,fnameOBS_wext_local,files_dwlded] = crism_search_observation_fromProp(propOBS,varargin)
% [dir_info,dirname,bnameOBS,fnameOBS_wext_local] = crism_search_observation_fromProp(propOBS,varargin)
%  get directory path of the given property of observation basename. 
%  The file could be downloaded using an option
%  Inputs
%   propCDR: basename of the CDR file
%  Outputs
%   dir_info: struct with the following fields
%       dirfullpath_local: full local directroy path of the CDR file
%       subdir_local     : subdirectory path
%       subdir_remote    : subdirectory for the remote server
%       yyyy_doy         : yyyy_doy
%       dirname          : directory name
%   basenameOBS: basename of the matched file
%   fnameOBS_wext_local : cell array of the filenames (with extensions) existing 
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

ext   = '';
dwld  = 0;
mtch_exact = false;
overwrite  = false;
index_cache_update = false;
celloutput = false;
verbose = true;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case {'EXT','EXTENSION'}
                ext = varargin{i+1};
            case 'MATCH_EXACT'
                mtch_exact = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case 'INDEX_CACHE_UPDATE'
                index_cache_update = varargin{i+1};
            case 'CELLOUTPUT'
                celloutput = varargin{i+1};
            case 'VERBOSE'
                verbose = varargin{i+1};
        end
    end
end

yyyy_doy = crism_searchOBSID2YYYY_DOY_v2(propOBS.obs_id);
dirname  = crism_get_dirname_fromPropOBS(propOBS);

if yyyy_doy == -1
    dir_info = []; basenameOBS = ''; fnameOBS_wext_local = [];
    return;
end

switch upper(propOBS.product_type)
    case {'EDR','TRR','DDR','TER','MTR','GLT'}
        product_type = propOBS.product_type;
    case {'(TRR|HKP)','(HKP|TRR)'}
        product_type = 'TRR';
    case {'(EDR|HKP)','(HKP|EDR)'}
        product_type = 'EDR';
    case 'HKP'
        switch propOBS.version
            case 0
                product_type = 'EDR';
            case 3
                product_type = 'TRR';
            otherwise
                error('Undefined version %d for product_type %s.',propOBS.version,propOBS.product_type);
        end
    otherwise
        error('Undefined product_type %s.',propOBS.product_type);
end

subdir_local  = crism_get_subdir_OBS_local(yyyy_doy,dirname,product_type);
[basenamePtrn] = crism_get_basenameOBS_fromProp(propOBS);
if no_remote
    [basenameOBS,fnameOBS_wext_local,files_dwlded]  = crism_readDownloadBasename( ...
        basenamePtrn,subdir_local,dwld,'Match_Exact',mtch_exact, ...
        'overwrite',overwrite,'EXTENSION',ext, ...
        'INDEX_CACHE_UPDATE',index_cache_update,'CELLOUTPUT',celloutput,'VERBOSE',verbose);
else
    subdir_remote = crism_get_subdir_OBS_remote(yyyy_doy,dirname,product_type);
    subdir_remote = crism_swap_to_remote_path(subdir_remote);
    [basenameOBS,fnameOBS_wext_local,files_dwlded]  = crism_readDownloadBasename( ...
        basenamePtrn,subdir_local,dwld,'Subdir_remote',subdir_remote, ...
        'Match_Exact',mtch_exact,'overwrite',overwrite,'EXTENSION',ext, ...
        'INDEX_CACHE_UPDATE',index_cache_update,'CELLOUTPUT',celloutput,'VERBOSE',verbose);
end


dirfullpath_local = fullfile(localrootDir,url_local_root,subdir_local);

dir_info = [];
dir_info.dirfullpath_local = dirfullpath_local;
dir_info.subdir_local      = subdir_local;
if ~no_remote
    dir_info.subdir_remote     = subdir_remote;
end
dir_info.yyyy_doy          = yyyy_doy;
dir_info.dirname           = dirname;

end