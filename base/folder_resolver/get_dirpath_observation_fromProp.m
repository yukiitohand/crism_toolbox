function [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname,basenameOBS] = get_dirpath_observation_fromProp(propOBS,varargin)
% [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname,basenameOBS] = get_dirpath_observation_fromProp(propOBS,varargin)
%  get directory path of the given property of observation basename. 
%  The file could be downloaded using an option
%  Inputs
%   propCDR: basename of the CDR file
%  Outputs
%   dirfullpath_local: full local directroy path of the CDR file
%   subdir_local     : subdirectory path
%   subdir_remote    : subdirectory for the remote server
%   yyyy_doy         : yyyy_doy
%   dirname          : directory name
%   basenameOBS: basename of the matched file
%  Optional Parameters
%      'MATCH_EXACT'    : binary, if basename match should be exact match
%                         or not.
%                         (default) false
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
mtch_exact = false;
overwrite = false;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MATCH_EXACT'
                mtch_exact = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
        end
    end
end

yyyy_doy = searchOBSID2YYYY_DOY(propOBS.obs_id);
[dirname] = get_dirname_fromPropOBS(propOBS);


switch lower(propOBS.product_type)
    case {'edr','trr','ddr','ter','mtr','glt'}
        product_type = propOBS.product_type;
    case 'hkp'
        switch propOBS.version
            case 0
                product_type = 'EDR';
            case 3
                product_type = 'TRR';
            otherwise
                error('Undefined version %d for product_type %s.',propOBS.version,propOBS.product_type);
        end
    otherwise
        error('Undefined version product_type %s.',propOBS.product_type);
end

subdir_local = get_subdir_OBS_local(yyyy_doy,dirname,product_type);
subdir_remote = get_subdir_OBS_remote(yyyy_doy,dirname,product_type);

[basenamePtrn] = get_basenameOBS_fromProp(propOBS);
[basenameOBS] = crism_readDownloadBasename(basenamePtrn,...
                    subdir_local,subdir_remote,dwld,'Match_Exact',mtch_exact,...
                    'Force',force,'Out_File',outfile,'overwrite',overwrite);


dirfullpath_local = joinPath(localrootDir,url_local_root,subdir_local);

end