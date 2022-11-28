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
dot_ext     = '.bsp';
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
                dot_ext = varargin{i+1};
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
% Resolving the directory path of the file
%
global mro_crism_spicekrnl_env_vars
localrootDir    = mro_crism_spicekrnl_env_vars.local_SPICEkernel_archive_rootDir;
url_local_root  = mro_crism_spicekrnl_env_vars.url_local_root;
no_remote = mro_crism_spicekrnl_env_vars.no_remote;

subdir_local = spicekrnl_mro_get_subdir_spk_de(mro_crism_spicekrnl_env_vars,dirpath_opt);
dirpath = fullfile(localrootDir,url_local_root,subdir_local);

%%
%==========================================================================
% Input interpretation
%==========================================================================
get_latest = (ischar(vr) && strcmpi(vr,'latest'));
if strcmpi(dot_ext,'all'), dot_ext = '(?<ext>\.[^\.]*)*$'; end
if (no_remote || dwld==0) && ~isempty(fname_spkde) && ~get_latest
    fname_spkde_ptrn   = ['^de(?<version>\d{3})(?<supplstr>\S*)' dot_ext];
    mtch = regexp(fname_spkde,fname_spkde_ptrn,'names');
    if isempty(mtch)
        error('Something wrong with the input fname');
    else % if ~get_latest
        fname_spkde_out = fname_spkde;
        vr_out = str2double(mtch.version);
    end
    if ~exist(fullfile(dirpath,fname_spkde_out),'file')
        error('%s is not found in %s.',fname_spkde_out,dirpath);
    end
else
    if ~isempty(fname_spkde)
        % If the fname_sclk is provided
        fname_spkde_ptrn   = ['^de(?<version>\d{3})(?<supplstr>\S*)' dot_ext];
        mtch = regexp(fname_spkde,fname_spkde_ptrn,'names');
        if isempty(mtch), error('Something wrong with the input fname');
        elseif ~get_latest
            fname_spkde_ptrn=sprintf('^de(?<version>%s)%s',mtch.version,mtch.supplstr);
        end
    else
        if isempty(vr) || get_latest, vr_str = '\d{3}';
        elseif isnumeric(vr)        , vr_str = sprintf('%03d',vr);
        elseif ischar(vr)           , vr_str = sprintf('%03s',vr);
        else, error('Invalid version input');
        end
        fname_spkde_ptrn = sprintf('^de(?<version>%s)\\S*', vr_str);
    end
    fname_spkde_ptrn = [fname_spkde_ptrn dot_ext];
    %%
    if no_remote, dwld = 0; end
    [fname_spkde_out,vr_out] = spice_get_kernel( ...
        mro_crism_spicekrnl_env_vars, mro_crism_spicekrnl_env_vars, fname_spkde_ptrn, ...
        'SUBDIR_LOCAL',subdir_local,'SUBDIR_REMOTE',subdir_local, ...
        'ext_ignore',isempty(dot_ext), 'GET_LATEST',get_latest, ...
        'DWLD',dwld,'overwrite',overwrite);

end