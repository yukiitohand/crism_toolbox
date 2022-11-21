function [fname_ck_sc_out,dirpath] = spice_get_mro_kernel_ck_sc( ...
    basenames_ck,dirpath_opt,varargin)
%  Get corresponding ck sc kernel in the NAIF archive repository from
%  the list of filenames of ck sc kernel stored in "SOURCE_PRODUCT_ID" in 
%  the CRISM DDR data.
% INPUTS
%  basenames_ck: cell array or char/string something like:
%       {'mro_sc_psp_080701_080707.bc', 'mro_sc_psp_080701_080707.bc', ...}
%    if there is no corresponding files that match the format of ck sc
%    kernel, then all the ck sc kernels will be returned.
%  dirpath_opt: {'MRO','PDS'}
% OUTPUTS
%  fname_ck_sc_out: char/string selected filename of its cell array
%  dirpath       : directory path to the selected filename
% OPTIONAL Parameters
%  "EXT"  : char/string, extension
%    files with this extension is returned. If empty, filename with no
%    extension is returned. If 'all', filename with any extension is
%    returned.
%    (default) 'bc'
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
ext      = 'bc';
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
%% Get the datetime range of the input spck files
if isempty(basenames_ck)
    dt_min_spck = []; dt_max_spck = [];
else
    if ischar(basenames_ck)
        basenames_ck = {basenames_ck};
    end
    props = cellfun(@(x) crism_getProp_spice_ck_sc_basename(x), ...
        basenames_ck,'UniformOutput',false);
    is_cksc = ~isempties(props);
    props = [props{is_cksc}];
    dt_min_spck = min([props.start_time]);
    dt_max_spck = max([props.end_time]);
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
        subdir_local  = joinPath(NAIF_MROSPICE_subdir,'ck');
        subdir_remote = joinPath(NAIF_MROSPICE_subdir,'ck');
        dirpath = joinPath(localrootDir,url_local_root,subdir_local);
    case 'PDS'
        subdir_local  = joinPath(NAIF_MROSPICE_pds_subdir,'ck');
        subdir_remote = joinPath(NAIF_MROSPICE_pds_subdir,'ck');
        dirpath = joinPath(localrootDir,url_local_root,subdir_local);
    otherwise
        error('Undefined dirpath_opt %s',dirpath_opt);
end

%%
%==========================================================================
% Connect to the remote server to get archived spck files.
%
 fname_ck_sc_ptrn = ...
     ['mro_sc_(psp|cru)_(?<yymmdd_strt>\d{6})()_(?<yymmdd_end>\d{6})' suffix '\.'];

[fnames_mtch,regexp_out] = naif_readDownloadBasename(fname_ck_sc_ptrn, ...
    subdir_local,subdir_remote,1,'ext_ignore',1, ...
    'match_exact',0,'overwrite',overwrite,'verbose',false);
[props] = cellfun(@(x) crism_getProp_spice_ck_sc_basename(x), ...
    fnames_mtch, 'UniformOutput', false);
props = [props{:}];
strt_times = [props.start_time];
end_times  = [props.end_time]  ;
%
%%
%==========================================================================
% Select 
%
if isempty(dt_max_spck)
    cond1 = true(size(strt_times));
else
    cond1 = strt_times<=dt_max_spck;
end
if isempty(dt_min_spck)
    cond2 = true(size(end_times));
else
    cond2 = end_times>=dt_min_spck;
end

idx_slctd = and(cond1,cond2);

fname_ck_sc_out = [];
if strcmpi(ext,'all')
    ext = '[^\.]*$';
end

if all(idx_slctd)
    % If all the files are selected, then just perform the same operation
    % with EXT.
    fname_ck_sc_ptrn = [fname_ck_sc_ptrn ext];
    [fname_ck_sc_out,regexp_out] = naif_readDownloadBasename( ...
        fname_ck_sc_ptrn, subdir_local, subdir_remote, dwld, ...
        'ext_ignore',isempty(ext), 'force',force, 'overwrite',overwrite);
else
    idx_slctd = find(idx_slctd);
    if isempty(idx_slctd)
        fprintf('Not found\n');
        fname_ck_sc_out = [];
        return;
    end
    fnames_slctd = fnames_mtch(idx_slctd);
    for i=1:length(fnames_slctd)
        if ~isempty(fnames_slctd{i})
            fname_slctd = [fnames_slctd{i} '\.' ext];
        end
        [fname_ck_sc_out_1,~] = naif_readDownloadBasename(fname_slctd, ...
            subdir_local,subdir_remote,dwld,'ext_ignore',isempty(ext), ...
            'overwrite',overwrite);
        if iscell(fname_ck_sc_out_1)
            fname_ck_sc_out = [fname_ck_sc_out fname_ck_sc_out_1];
        else
            fname_ck_sc_out = [fname_ck_sc_out {fname_ck_sc_out_1}];
        end
    end
    if length(fname_ck_sc_out)==1
        fname_ck_sc_out = fname_ck_sc_out{1};
    end
end



end