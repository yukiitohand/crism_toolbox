function [fname_pck_out,dirpath,vr_out] = spice_get_mro_kernel_pck( ...
    dirpath_opt,varargin)
% [fname_pck_out,dirpath,vr_out] = spice_get_mro_kernel_pck( ...
%     dirpath_opt,varargin)
%  get pck/pck?????[.???] spice kernel from the database
% Usage:
% To get the latest version of the kernel from NAIF archive: 
%
% >> [fname_pck_out,dirpath,vr_out] = spice_get_mro_kernel_pck('generic', ...
%     'version','latest');
%
% To get the latest version of the kernel from NAIF PDS archive: 
%
% >> [fname_pck_out,dirpath,vr_out] = spice_get_mro_kernel_pck('PDS', ...
%     'version','latest');
%
% To get the given file: 
%
% >> [fname_pck_out,dirpath,vr_out] = spice_get_mro_kernel_pck('generic', ...
%     'filename', 'pck00008.tpc');
%
% To get the latest version of the give filename: 
%
% >> [fname_pck_out,dirpath,vr_out] = spice_get_mro_kernel_pck('generic', ...
%     'filename', 'pck00008.tpc', 'version','latest');
%
% INPUTS
%  fname_pck   : char/string, 'pck?????[.???]'
%  dirpath_opt : {'GENERIC','MRO','PDS'}
%  With 'latest' option, the latest version of the kernel is selected.
% OUTPUTS
%  fname_pck_out : char/string, selected filename
%  dirpath       : directory path to the selected filename
%  vr            : double scalar, version of the selected kernel.
% OPTIONAL Parameters
%  "FILENAME"    : char, file name
%    (default) ''
%  "EXT"  : char/string, extension
%    files with this extension is returned. If empty, filename with no
%    extension is returned. If 'all', filename with any extension is
%    returned.
%    (default) 'tpc'
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

fname_pck = '';
ext = 'tpc';
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
                fname_pck = varargin{i+1};
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
if ~isempty(fname_pck)
    % If the fname_sclk is provided
    fname_pck_ptrn   = ['pck(?<version>\d{5})\.' ext];
    mtch = regexp(fname_pck,fname_pck_ptrn,'names');
    if isempty(mtch)
        error('Something wrong with the input fname');
    else
        if ischar(vr) && strcmpi(vr,'latest')
            get_latest = true;
        else
            fname_pck_ptrn=sprintf('pck(?<version>%s)\\.',mtch.version);
            fname_pck_ptrn = [fname_pck_ptrn ext];
        end
    end
else
    if isempty(vr)
        vr_str = '\d{5}';
    else
        if isnumeric(vr)
            vr_str = num2str(vr,'%05d');
        elseif ischar(vr) && strcmpi(vr,'latest')
            vr_str = '\d{5}';
            get_latest = true;
        else
            error('Invalid version input');
        end
    end
    fname_pck_ptrn = sprintf('pck(?<version>%s)\\.', vr_str);
    fname_pck_ptrn = [fname_pck_ptrn ext];
end
%
%%
%==========================================================================
% Resolving the directory path of the file
%
global naif_archive_env_vars
global crism_env_vars

localrootDir    = naif_archive_env_vars.local_naif_archive_rootDir;
url_local_root  = naif_archive_env_vars.naif_archive_root_URL;
url_remote_root = naif_archive_env_vars.naif_archive_root_URL;

switch upper(dirpath_opt)
    case 'GENERIC'
        subdir_local  = joinPath(crism_env_vars.NAIF_GENERICSPICE_subdir,'pck');
        subdir_remote = joinPath(crism_env_vars.NAIF_GENERICSPICE_subdir,'pck');
        dirpath = joinPath(localrootDir,url_local_root,subdir_local);
    case 'MRO'
        subdir_local  = joinPath(crism_env_vars.NAIF_MROSPICE_subdir,'pck');
        subdir_remote = joinPath(crism_env_vars.NAIF_MROSPICE_subdir,'pck');
        dirpath = joinPath(localrootDir,url_local_root,subdir_local);
    case 'PDS'
        subdir_local  = joinPath(crism_env_vars.NAIF_MROSPICE_pds_subdir,'pck');
        subdir_remote = joinPath(crism_env_vars.NAIF_MROSPICE_pds_subdir,'pck');
        dirpath = joinPath(localrootDir,url_local_root,subdir_local);
    otherwise
        error('Undefined dirpath_opt %s',dirpath_opt);
end
%
%%
%==========================================================================
% Depending on the version mode, return its fname and version.
%
[fname_pck_out,vr_out] = spice_get_kernel(fname_pck_ptrn, ...
    'SUBDIR_LOCAL',subdir_local,'SUBDIR_REMOTE',subdir_remote, ...
    'ext_ignore',isempty(ext), 'GET_LATEST',get_latest, ...
    'DWLD',dwld, ...
    'force',force,'overwrite',overwrite);

end