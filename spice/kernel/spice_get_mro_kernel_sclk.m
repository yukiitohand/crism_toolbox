function [fname_sclk_out,dirpath,vr_out] = spice_get_mro_kernel_sclk( ...
    dirpath_opt,varargin)
% [fname_sclk_out,dirpath,vr_out] = spice_get_mro_kernel_sclk( ...
%     dirpath_opt,varargin)
%  get sclk/MRO_SCLKSCET spice kernel from the database
% Usage:
% To get the latest version of the sclk kernel from NAIF archive: 
%
% >> [fname_sclk_out,dirpath,vr_out] = spice_get_mro_kernel_sclk('MRO', ...
%     'precision','high','version','latest');
%
% To get the latest version of the sclk kernel from NAIF PDS archive: 
%
% >> [fname_sclk_out,dirpath,vr_out] = spice_get_mro_kernel_sclk('PDS', ...
%     'precision','high','version','latest');
%
% To get the given file: 
%
% >> [fname_sclk_out,dirpath,vr_out] = spice_get_mro_kernel_sclk('MRO', ...
%     'filename', 'MRO_SCLKSCET.00026.65536.tsc');
%
% To get the latest version of the give filename: 
%
% >> [fname_sclk_out,dirpath,vr_out] = spice_get_mro_kernel_sclk('MRO', ...
%     'filename', 'MRO_SCLKSCET.00026.65536.tsc','version','latest');
%
% INPUTS
%  fname_sclk : char/string, MRO_SCLKSCET...
%  dirpath_opt: {'MRO','PDS'}
%  With 'latest' option, the latest version of the kernel is selected.
% OUTPUTS
%  fname_sclk_out: char/string, selected filename
%  dirpath       : directory path to the selected filename
%  vr            : double scalar, version of the selected kernel.
% OPTIONAL Parameters
%  "PRECISION": {'STANDARD'/256,'HIGH'/65536}
%   precision of the SCLK kernel
%   (default) HIGH/65536
%  "FILENAME"    : file name
%   (default) ''
%  "EXT"  : char/string, extension
%    files with this extension is returned. If empty, filename with no
%    extension is returned. If 'all', filename with any extension is
%    returned.
%    (default) 'tsc'
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


fname_sclk = '';
precision = 'HIGH';
ext = 'tsc';
vr = [];

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
                fname_sclk = varargin{i+1};
            case 'PRECISION'
                precision = varargin{i+1};
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
if strcmpi(ext,'all')
    ext = '[^\.]*$';
end
get_latest = false;
if ~isempty(fname_sclk)
    % If the fname_sclk is provided
    fname_sclk_ptrn_256 = ['MRO_SCLKSCET(\.|_)(?<version>\d{5})\.' ext];
    fname_sclk_ptrn_65536 = ['MRO_SCLKSCET(\.|_)(?<version>\d{5})(\.|_)65536\.' ext];
    
    mtch = regexp(fname_sclk,fname_sclk_ptrn_256,'names');
    if ~isempty(mtch)
        %  precision = 'STANDARD';
        if ischar(vr) && strcmpi(vr,'latest')
            fname_sclk_ptrn = fname_sclk_ptrn_256;
            get_latest = true;
        else
            fname_sclk_ptrn = sprintf( ...
                'MRO_SCLKSCET(\\.|_)(?<version>%s)\\.', mtch.version);
            fname_sclk_ptrn = [fname_sclk_ptrn ext];
        end
    else
        mtch = regexp(fname_sclk,fname_sclk_ptrn_65536,'names');
        if ~isempty(mtch)
            % precision = 'HIGH';
            if ischar(vr) && strcmpi(vr,'latest')
                fname_sclk_ptrn = fname_sclk_ptrn_65536;
                get_latest = true;
            else
                fname_sclk_ptrn = sprintf( ...
                    'MRO_SCLKSCET(\\.|_)(?<version>%s)(\\.|_)65536\\.', ...
                    mtch.version);
                fname_sclk_ptrn = [fname_sclk_ptrn ext];
            end
        else
            error('Something wrong with fname_sclk %s',fname_sclk);
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
    switch upper(precision)
        case {'STANDARD',256}
            fname_sclk_ptrn = sprintf( ...
                'MRO_SCLKSCET(\\.|_)(?<version>%s)\\.', vr_str);
        case {'HIGH',65536}
            fname_sclk_ptrn = sprintf( ...
                'MRO_SCLKSCET(\\.|_)(?<version>%s)(\\.|_)65536\\.', ...
                vr_str);
        otherwise
            error('Undefined presision %s',precision);
    end
    
    fname_sclk_ptrn = [fname_sclk_ptrn ext];

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
    case 'MRO'
        subdir_local  = joinPath(crism_env_vars.NAIF_MROSPICE_subdir,'sclk');
        subdir_remote = joinPath(crism_env_vars.NAIF_MROSPICE_subdir,'sclk');
        dirpath = joinPath(localrootDir,url_local_root,subdir_local);
    case 'PDS'
        subdir_local  = joinPath(crism_env_vars.NAIF_MROSPICE_pds_subdir,'sclk');
        subdir_remote = joinPath(crism_env_vars.NAIF_MROSPICE_pds_subdir,'sclk');
        dirpath = joinPath(localrootDir,url_local_root,subdir_local);
    otherwise
        error('Undefined dirpath_opt %s',dirpath_opt);
end
%
%
%%
%==========================================================================
% Depending on the version mode, return its fname and version.
%
[fname_sclk_out,vr_out] = spice_get_kernel(fname_sclk_ptrn, ...
    'SUBDIR_LOCAL',subdir_local,'SUBDIR_REMOTE',subdir_remote, ...
    'ext_ignore',isempty(ext), 'GET_LATEST',get_latest, ...
    'DWLD',dwld, ...
    'force',force,'overwrite',overwrite);

end