function [ fmt ] = crismHKFMTread( product_type,varargin )
% [ fmt ] = crismHKFMTread( lbl )
%   Read the meta/header information of the House Keeping TABLE file.
%   
%   Inputs
%       product_type: "TARGETED_RDR" or "EDR" (case insensitive)
%   Outputs
%       fmt: struct of the *.FMT file.
%   Optional Parameters
%       'Fname' : file name
%           (default) "TRDRHK.FMT" for product_type = 'Targeted RDR'
%                     "EDRHK.FMT" for product_type = 'EDR'
%       'DirPath': 
%           (default) depends on the local database filesystem
%      for product_type = 'EDR'
%    'CLEARCACHE': Boolean, (default) false
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false

clearcache = false;
global crism_env_vars
localrootDir = crism_env_vars.localCRISM_PDSrootDir;
url_local_root = crism_env_vars.url_local_root;

switch upper(product_type)
    case 'TARGETED_RDR'
        product_type_acro = 'TRDR';
        subdir_local  = crism_get_subdir_OBS_local('','LABEL/','trr_misc');
        subdir_remote = crism_get_subdir_OBS_remote('','LABEL/','trr_misc');
        dirfullpath_local = joinPath(localrootDir,url_local_root,subdir_local);
    case 'EDR'
        product_type_acro = 'EDR';
        subdir_local  = crism_get_subdir_OBS_local('','LABEL/','edr_misc');
        subdir_remote = crism_get_subdir_OBS_remote('','LABEL/','edr_misc');
        dirfullpath_local = joinPath(localrootDir,url_local_root,subdir_local);
    otherwise
        error('product_type %s is not valid.',product_type);
end
fmtfname = [product_type_acro 'HK.FMT'];

dwld = 0;
force = 0;
outfile = '';

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'FNAME'
                fmtfname = varargin{i+1};
            case 'DIRPATH'
                dirfullpath_local = varargin{i+1};
            case 'CLEARCACHE'
                clearcache = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            otherwise
                error('The option %s is not defined',varargin{i});
        end
    end
end

crism_readDownloadBasename(fmtfname, subdir_local,...
    subdir_remote,dwld,'Force',force,'Out_File',outfile);

cachefilepath = joinPath(dirfullpath_local,[fmtfname '.mat']);
if exist(cachefilepath,'file') && ~clearcache
    load(cachefilepath,'fmt');
else
    fmtfpath = joinPath(dirfullpath_local, fmtfname);
    fmt = pds3lblread(fmtfpath);
    save(cachefilepath,'fmt');
end

end
