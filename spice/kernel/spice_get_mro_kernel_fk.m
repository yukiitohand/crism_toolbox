function [fname_fk_out,dirpath,vr_out] = spice_get_mro_kernel_fk( ...
    dirpath_opt,varargin)
% [fname_fk_out,dirpath,vr_out] = spice_get_mro_kernel_fk( ...
%     dirpath_opt,varargin)
%  get fk/mro_v??[.??] spice kernel from the database
% Usage:
% To get the latest version of the kernel from NAIF archive: 
%
% >> [fname_fk_out,dirpath,vr_out] = spice_get_mro_kernel_fk('MRO', ...
%     'version','latest');
%
% To get the latest version of the kernel from NAIF PDS archive: 
%
% >> [fname_fk_out,dirpath,vr_out] = spice_get_mro_kernel_fk('PDS', ...
%     'version','latest');
%
% To get the given file: 
%
% >> [fname_fk_out,dirpath,vr_out] = spice_get_mro_kernel_fk('MRO', ...
%     'filename', 'mro_v11.tf');
%
% To get the latest version of the give filename: 
%
% >> [fname_fk_out,dirpath,vr_out] = spice_get_mro_kernel_fk('MRO', ...
%     'filename', 'mro_v11.tf','version','latest');
%
% INPUTS
%  fname_fk : char/string, mro_v??[.??]
%  dirpath_opt: {'MRO','PDS'}
%  With 'latest' option, the latest version of the kernel is selected.
% OUTPUTS
%  fname_fk_out: char/string, selected filename
%  dirpath       : directory path to the selected filename
%  vr            : double scalar, version of the selected kernel.
% OPTIONAL Parameters
%  "FILENAME"    : char, file name
%    (default) ''
%  "EXT"  : char/string, extension
%    files with this extension is returned. If empty, filename with no
%    extension is returned. If 'all', filename with any extension is
%    returned.
%    (default) 'tf'
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

fname_fk = '';
dot_ext  = '.tf';
vr       = [];

% ## downloading options.
dwld      = 0;
overwrite = false;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'FILENAME'
                fname_fk = varargin{i+1};
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
global spicekrnl_env_vars
localrootDir    = spicekrnl_env_vars.local_SPICEkernel_archive_rootDir;
url_local_root  = spicekrnl_env_vars.url_local_root;
local_fldsys    = spicekrnl_env_vars.local_fldsys;

subdir_local = spicekrnl_get_subdir_fk(local_fldsys,dirpath_opt);
dirpath = fullfile(localrootDir,url_local_root,subdir_local);

%%
%==========================================================================
% Input interpretation
%==========================================================================
get_latest = (ischar(vr) && strcmpi(vr,'latest'));
if strcmpi(dot_ext,'all'), dot_ext = '(?<ext>\.[^\.]*)*$'; end
if ~isempty(fname_fk) && dwld==0 && ~get_latest
    % If the fname_fk is provided
    fname_fk_ptrn_naif = ['^mro_v(?<version>\d{2})' dot_ext];
    mtch = regexpi(fname_fk,fname_fk_ptrn_naif,'names');
    if isempty(mtch)
        error('Something wrong with the input fname');
    else
        fname_fk_out =fname_fk;
        vr_out = str2double(mtch.version);
    end
    if ~exist(fullfile(dirpath,fname_fk_out),'file')
        error('%s is not found in %s.',fname_fk_out,dirpath);
    end
else
    if ~isempty(fname_fk)
        % If the fname_fk is provided
        fname_fk_ptrn_naif = ['^mro_v(?<version>\d{2})\.' dot_ext];
        mtch = regexp(fname_fk,fname_fk_ptrn_naif,'names');
        if isempty(mtch)
            error('Something wrong with the input fname');
        else
            if ~get_latest
                fname_fk_ptrn_naif=sprintf('^mro_v(?<version>%s)\\.', ...
                    mtch.version);
                fname_fk_ptrn_naif = [fname_fk_ptrn_naif dot_ext];
            end
        end
    else
        if isempty(vr)
            vr_str = '\d{2}';
        else
            if isnumeric(vr)
                vr_str = num2str(vr,'%02d');
            elseif get_latest
                vr_str = '\d{2}';
            else
                error('Invalid version input');
            end
        end
        fname_fk_ptrn_naif = sprintf('^mro_v(?<version>%s)\\.', vr_str);
        fname_fk_ptrn_naif = [fname_fk_ptrn_naif dot_ext];
    end

    %%
    %==========================================================================
    % Depending on the version mode, return its fname and version.
    %
    [fname_fk_out,vr_out] = spice_get_kernel(fname_fk_ptrn_naif, ...
        'SUBDIR_LOCAL',subdir_local,'SUBDIR_REMOTE',subdir_remote, ...
        'ext_ignore',isempty(dot_ext), 'GET_LATEST',get_latest, ...
        'DWLD',dwld,'overwrite',overwrite);

end

end