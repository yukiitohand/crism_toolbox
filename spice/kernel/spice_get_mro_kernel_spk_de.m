function [fname_spkde_out,dirpath,vr_out] = spice_get_mro_kernel_spk_de( ...
    dirpath_opt,varargin)
% [fname_spkde_out,dirpath,vr_out] = spice_get_mro_kernel_spk_de( ...
%     dirpath_opt,varargin)
%  get spk/de???[.???] spice kernel from the database
% Usage:
% To get the latest version of the kernel from NAIF archive: 
%
% >> [fname_spkde_out,dirpath,vr_out] = spice_get_mro_kernel_spk_de('generic', ...
%     'version','latest');
%
% To get the latest version of the kernel from NAIF PDS archive: 
%
% >> [fname_spkde_out,dirpath,vr_out] = spice_get_mro_kernel_spk_de('PDS', ...
%     'version','latest');
%
% To get the given file: 
%
% >> [fname_spkde_out,dirpath,vr_out] = spice_get_mro_kernel_spk_de('generic', ...
%     'filename', 'de410.bsp);
%
% To get the latest version of the give filename: 
%
% >> [fname_spkde_out,dirpath,vr_out] = spice_get_mro_kernel_spk_de('generic', ...
%     'filename', 'de410.bsp', 'version','latest');
%
% INPUTS
%  fname_spkde : char/string, 'de???[.???]'
%  dirpath_opt : {'GENERIC','GENERIC_OLD','PDS'}
%  With 'latest' option, the latest version of the kernel is selected.
% OUTPUTS
%  fname_spkde_out : char/string, selected filename
%  dirpath         : directory path to the selected filename
%  vr              : double scalar, version of the selected kernel.
% OPTIONAL Parameters
%  "FILENAME"    : char, file name
%    (default) ''
%  "EXT"  : char/string, extension
%    files with this extension is returned. If empty, filename with no
%    extension is returned. If 'all', filename with any extension is
%    returned.
%    (default) 'bsp'
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
%  "OVERWRITE": boolean, whether or not to overwrite the local files with
%    the files at the remote archive serve.
%
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>
% 


fname_spkde = '';
ext         = 'bsp';
vr          = [];

% ## downloading options.
dwld      = 0;
overwrite = false;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'FILENAME'
                fname_spkde = varargin{i+1};
            case 'EXT'
                ext = varargin{i+1};
            case 'VERSION'
                vr = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
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
if ~isempty(fname_spkde)
    % If the fname_sclk is provided
    fname_spkde_ptrn   = ['de(?<version>\d{3})(?<supplstr>\S*)\.' ext];
    mtch = regexp(fname_spkde,fname_spkde_ptrn,'names');
    if isempty(mtch)
        error('Something wrong with the input fname');
    else
        if ischar(vr) && strcmpi(vr,'latest')
            get_latest = true;
        else
            fname_spkde_ptrn=sprintf('de(?<version>%s)%s\\.', ...
                mtch.version,mtch.supplstr);
            fname_spkde_ptrn = [fname_spkde_ptrn ext];
        end
    end
else
    if isempty(vr)
        vr_str = '\d{3}';
    else
        if isnumeric(vr)
            vr_str = num2str(vr,'%03d');
        elseif ischar(vr) && strcmpi(vr,'latest')
            vr_str = '\d{3}';
            get_latest = true;
        else
            error('Invalid version input');
        end
    end
    fname_spkde_ptrn = sprintf('de(?<version>%s)\\S*\\.', vr_str);
    fname_spkde_ptrn = [fname_spkde_ptrn ext];
end
%
%%
%==========================================================================
% Resolving the directory path of the file
%
global spicekrnl_env_vars
localrootDir    = spicekrnl_env_vars.local_SPICEkernel_archive_rootDir;
url_local_root  = spicekrnl_env_vars.crismlnx_URL;
local_fldsys    = spicekrnl_env_vars.local_fldsys;

subdir_local = spicekrnl_get_subdir_spk_de(local_fldsys,dirpath_opt);
if isfield(spicekrnl_env_vars,'remote_fldsys') && ~isempty(spicekrnl_env_vars.remote_fldsys)
    subdir_remote = spicekrnl_get_subdir_spk_de(spicekrnl_env_vars.remote_fldsys,dirpath_opt);
else
    subdir_remote = '';
end
dirpath = fullfile(localrootDir,url_local_root,subdir_local);
%
%%
%==========================================================================
% Depending on the version mode, return its fname and version.
%
[fname_spkde_out,vr_out] = spice_get_kernel(fname_spkde_ptrn, ...
    'SUBDIR_LOCAL',subdir_local,'SUBDIR_REMOTE',subdir_remote, ...
    'ext_ignore',isempty(ext), 'GET_LATEST',get_latest, ...
    'DWLD',dwld,'overwrite',overwrite);

end