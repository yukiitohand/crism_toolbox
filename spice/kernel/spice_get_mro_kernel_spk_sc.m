function [fname_spk_sc_out,dirpath] = spice_get_mro_kernel_spk_sc( ...
    strt_datetime, end_datetime,dirpath_opt,varargin)
% [fname_spk_out,dirpath] = spice_get_mro_kernel_spk_sc( ...
%     strt_datetime, end_datetime,dirpath_opt,varargin)
%  Get corresponding spk sc kernel in the NAIF archive repository with
%  given start datetime and end datetime.
% INPUTS
%  strt_datetime: datetime object, date&time at the start
%  end_datetime : datetime object, date&time at the end
%  dirpath_opt: {'MRO','PDS'}
% OUTPUTS
%  fname_spk_sc_out: char/string selected filename of its cell array
%  dirpath       : directory path to the selected filename
% OPTIONAL Parameters
%  "EXT"  : char/string, extension
%    files with this extension is returned. If empty, filename with no
%    extension is returned. If 'all', filename with any extension is
%    returned.
%    (default) 'bsp'
%  "SUFFIX" : char/string, suffix should be placed like below:
%          mro_sc_psp_080701_080707[SUFFIX].bc
%    (default) ''
%  ## Some downloading options 
%   Following options are for how to deal with downloading from the naif
%   archive server.
%  "DOWNLOAD", "DWLD" : {-1, 0, 1, 2}
%     if dwld>0, then this is passed to 'pds_downloader'
%     -1: show the list of file that match the input pattern.
%     (default) 0
%  "FORCE": boolean, whether or not to perform procedure for "DOWNLOAD"
%    forcefully. "DOWNLOAD" option is always triggered if no files matches 
%    in the local repository regardless of "FORCE", not otherwise.
%  "OVERWRITE": boolean, whether or not to overwrite the local files with
%    the files at the remote archive serve.
%
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>
%
ext      = 'bsp';
suffix   = '';
% ## downloading options.
dwld      = 0;
force     = false;
overwrite = false;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'EXT'
                ext = varargin{i+1};
            case 'SUFFIX'
                suffix = varargin{i+1};
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
        subdir_local  = joinPath(NAIF_MROSPICE_subdir,'spk');
        subdir_remote = joinPath(NAIF_MROSPICE_subdir,'spk');
        dirpath = joinPath(localrootDir,url_local_root,subdir_local);
    case 'PDS'
        subdir_local  = joinPath(NAIF_MROSPICE_pds_subdir,'spk');
        subdir_remote = joinPath(NAIF_MROSPICE_pds_subdir,'spk');
        dirpath = joinPath(localrootDir,url_local_root,subdir_local);
    otherwise
        error('Undefined dirpath_opt %s',dirpath_opt);
end

%%
%==========================================================================
% Find corresponding PHASE
%
[spk_arch_infostruct] = mro_spice_get_spk_arch_info();
strt_times = [spk_arch_infostruct.START_TIME];
end_times  = [spk_arch_infostruct.END_TIME]  ;


if isempty(end_datetime)
    cond1 = true(size(strt_times));
else
    cond1 = strt_times <= end_datetime;
end
if isempty(strt_datetime)
    cond2 = true(size(end_times));
else
    cond2 = end_times  >= strt_datetime;
end

idx_slctd = and(cond1,cond2);

if strcmpi(ext,'all')
    ext = '[^\.]*$';
end

if all(idx_slctd)
    fname_spk_ptrn = ['mro_(ab|cruise|psp\d+)' suffix '\.' ext];
    [fname_spk_sc_out,regexp_out] = naif_readDownloadBasename( ...
        fname_spk_ptrn,subdir_local,subdir_remote,dwld, ...
        'ext_ignore',isempty(ext),'force',force,'overwrite',overwrite);
else
    idx_slctd = find(idx_slctd);
    if isempty(idx_slctd)
        fprintf('Not found\n');
        fname_spk_sc_out = [];
        return;
    end

    phases_slctd = {spk_arch_infostruct(idx_slctd).PHASE};


    %%
    %==========================================================================
    % Connect to the remote server to get archived spck files.
    %
    phase_ptrn = ['(' strjoin(phases_slctd,'|') ')'];
    fname_spk_ptrn = ['mro_' phase_ptrn suffix '\.' ext];

    [fname_spk_sc_out,regexp_out] = naif_readDownloadBasename( ...
        fname_spk_ptrn,subdir_local,subdir_remote,dwld, ...
        'ext_ignore',isempty(ext),'overwrite',overwrite);
end


end