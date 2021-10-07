function [fname_ik_out,dirpath,vr_out] = spice_get_mro_crism_kernel_ik( ...
    dirpath_opt,varargin)
% [fname_ik_out,dirpath,vr_out] = spice_get_mro_crism_kernel_ik( ...
%     dirpath_opt,varargin)
%  get ik/mro_crism_v??[.??] spice kernel from the database
% Usage:
% To get the latest version of the kernel from NAIF archive: 
%
% >> [fname_ik_out,dirpath,vr_out] = spice_get_mro_crism_kernel_ik('MRO', ...
%     'version','latest');
%
% To get the latest version of the kernel from NAIF PDS archive: 
%
% >> [fname_ik_out,dirpath,vr_out] = spice_get_mro_crism_kernel_ik('PDS', ...
%     'version','latest');
%
% To get the given file: 
%
% >> [fname_ik_out,dirpath,vr_out] = spice_get_mro_crism_kernel_ik('MRO', ...
%     'filename', 'mro_crism_v11.tf');
%
% To get the latest version of the give filename: 
%
% >> [fname_ik_out,dirpath,vr_out] = spice_get_mro_crism_kernel_fk('MRO', ...
%     'filename', 'mro_crism_v11.tf','version','latest');
%
% INPUTS
%  fname_ik : char/string, mro_crism_v??[.??]
%  dirpath_opt: {'MRO','PDS'}
%  With 'latest' option, the latest version of the kernel is selected.
% OUTPUTS
%  fname_ik_out: char/string, selected filename
%  dirpath       : directory path to the selected filename
%  vr            : double scalar, version of the selected kernel.
% OPTIONAL Parameters
%  "FILENAME"    : char, file name
%    (default) ''
%  "EXT"  : char/string, extension
%    files with this extension is returned. If empty, filename with no
%    extension is returned. If 'all', filename with any extension is
%    returned.
%    (default) 'ti'
%  "VERSION"  : scalar or 'latest'
%    The version number. If empty, all the versions are matched.
%   (default) []
%  ## Some downloading options 
%   Following options are for how to deal with downloading from the naif
%   archive server.
%  "DOWNLOAD", "DWLD" : {-1, 0, 1, 2}
%     if dwld>0, then this is passed to 'pds_downloader'
%     -1: show the list of file that match the input pattern.
%     (default) 0
%  "FORCE": boolean, whether or not to perform procedure for "DOWNLOAD"
%    forcefully. "DOWNLOAD" option is always triggered if no files matches 
%    in the local repository regardless of "FORCE"
%  "OVERWRITE": boolean, whether or not to overwrite the local files with
%    the files at the remote archive serve.
%
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>
% 

fname_ik  = '';
ext = 'ti';
vr        = [];

% ## downloading options.
dwld      = 0;
force     = false;
overwrite = false;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'FILENAME'
                fname_ik = varargin{i+1};
            case 'EXT'
                ext = varargin{i+1};
            case 'VERSION'
                vr = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});   
        end
    end
end
%%
%==========================================================================
% Input interpretation
%==========================================================================
get_latest = false;
if strcmpi(ext,'all')
    ext = '[^\.]*$';
end
if ~isempty(fname_ik)
    % If the fname_sclk is provided
    fname_ik_ptrn   = ['mro_crism_v(?<version>\d{2})\\.' ext];
    mtch = regexp(fname_ik,fname_ik_ptrn,'names');
    if isempty(mtch)
        error('Something wrong with the input fname');
    else
        if ischar(vr) && strcmpi(vr,'latest')
            get_latest = true;
        else
            fname_ik_ptrn=sprintf('mro_crism_v(?<version>%s)\\.', ...
                mtch.version);
            fname_ik_ptrn = [fname_ik_ptrn ext];
        end
    end
else
    if isempty(vr)
        vr_str = '\d{2}';
    else
        if isnumeric(vr)
            vr_str = num2str(vr,'%02d');
        elseif ischar(vr) && strcmpi(vr,'latest')
            vr_str = '\d{2}';
            get_latest = true;
        else
            error('Invalid version input');
        end
    end
    fname_ik_ptrn = sprintf('mro_crism_v(?<version>%s)\\.', vr_str);
    fname_ik_ptrn = [fname_ik_ptrn ext];
end
%
%%
%==========================================================================
% Resolving the directory path of the file
%
global naif_archive_env_vars
% global crism_env_vars

localrootDir    = naif_archive_env_vars.local_naif_archive_rootDir;
url_local_root  = naif_archive_env_vars.naif_archive_root_URL;
url_remote_root = naif_archive_env_vars.naif_archive_root_URL;

NAIF_MROSPICE_subdir     = naif_archive_env_vars.NAIF_MROSPICE_subdir;
NAIF_MROSPICE_pds_subdir = naif_archive_env_vars.NAIF_MROSPICE_pds_subdir;

switch upper(dirpath_opt)
    case 'MRO'
        subdir_local  = joinPath(NAIF_MROSPICE_subdir,'ik');
        subdir_remote = joinPath(NAIF_MROSPICE_subdir,'ik');
        dirpath = joinPath(localrootDir,url_local_root,subdir_local);
    case 'PDS'
        subdir_local  = joinPath(NAIF_MROSPICE_pds_subdir,'ik');
        subdir_remote = joinPath(NAIF_MROSPICE_pds_subdir,'ik');
        dirpath = joinPath(localrootDir,url_local_root,subdir_local);
    otherwise
        error('Undefined dirpath_opt %s',dirpath_opt);
end
%
%%
%==========================================================================
% Depending on the version mode, return its fname and version.
%
[fname_ik_out,vr_out] = spice_get_kernel(fname_ik_ptrn, ...
    'SUBDIR_LOCAL',subdir_local,'SUBDIR_REMOTE',subdir_remote, ...
    'ext_ignore',isempty(ext), 'GET_LATEST',get_latest, ...
    'DWLD',dwld, ...
    'force',force,'overwrite',overwrite);

end