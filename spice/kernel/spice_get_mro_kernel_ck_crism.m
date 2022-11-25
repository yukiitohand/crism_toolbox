function [fname_ck_crism_out,dirpath] = spice_get_mro_kernel_ck_crism( ...
    basenames_ck,dirpath_opt,varargin)
% [fname_ck_crism_out,dirpath] = spice_get_mro_kernel_ck_crism( ...
%     basenames_ck,dirpath_opt,varargin)
%  Get corresponding ck crism kernel in the NAIF archive repository from
%  the list of filenames of ck crism kernel stored in "SOURCE_PRODUCT_ID"
%  in the CRISM DDR data.
% INPUTS
%  basenames_ck: cell array or char/string something like:
%        {'spck_2008_184_r_1.bc', 'spck_2008_185_r_1.bc', ...}
%    if there is no corresponding files that match the format of ck crism
%    kernel, then all the ck crism kernels will be returned.
%  dirpath_opt: {'MRO','PDS'}
% OUTPUTS
%  fname_ck_crism_out: char/string selected filename of its cell array
%  dirpath       : directory path to the selected filename
% OPTIONAL Parameters
%  "EXT"  : char/string, extension
%    files with this extension is returned. If empty, filename with no
%    extension is returned. If 'all', filename with any extension is
%    returned.
%    (default) 'bc'
%  "SUFFIX" : char/string, suffix should be placed like below:
%          mro_crm_psp_080701_080707[SUFFIX].bc
%    (default) ''
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

ext    = 'bc';
suffix = '';

% ## downloading options.
dwld      = 0;
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

subdir_local = spicekrnl_get_subdir_ck_crism(local_fldsys,dirpath_opt);
if isfield(spicekrnl_env_vars,'remote_fldsys') && ~isempty(spicekrnl_env_vars.remote_fldsys)
    subdir_remote = spicekrnl_get_subdir_ck_crism(spicekrnl_env_vars.remote_fldsys,dirpath_opt);
else
    subdir_remote = '';
end
dirpath = fullfile(localrootDir,url_local_root,subdir_local);

%% Get the datetime range of the input spck files
dt = [];
if isempty(basenames_ck)
else
    if ischar(basenames_ck)
        basenames_ck = {basenames_ck};
    end
    for i=1:length(basenames_ck)
        prop = crism_getProp_spice_ck_crism_basename(basenames_ck{i});
        if ~isempty(prop)
            [MM,DD] = doy2MMDD(prop.doy,prop.yyyy);
            dti = datetime(prop.yyyy,MM,DD);
            dt = [dt dti];
        end
    end
end
dt_min_spck = min(dt);
dt_max_spck = max(dt);




%%
%==========================================================================
% Connect to the remote server to get archived spck files.
%
fname_ck_arch_ptrn = ...
    ['mro_crm_(psp|cru)_(?<yymmdd_strt>\d{6})()_(?<yymmdd_end>\d{6})' suffix '\.'];


if isfield(spicekrnl_env_vars,'remote_fldsys') && ~isempty(spicekrnl_env_vars.remote_fldsys)
    [fnames_mtch,regexp_out] = spicekrnl_readDownloadBasename(fname_ck_arch_ptrn, ...
    subdir_local,subdir_remote,1,'ext_ignore',1, ...
    'match_exact',0,'overwrite',overwrite,'verbose',false);
else
    [fnames_mtch,regexp_out] = spicekrnl_readDownloadBasename(fname_ck_arch_ptrn, ...
    subdir_local,subdir_remote,0,'ext_ignore',1, ...
    'match_exact',0,'overwrite',overwrite,'verbose',false);
end


[props] = cellfun(@(x) crism_getProp_spice_ck_crism_arch_basename(x), ...
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

if strcmpi(ext,'all')
    ext = '[^\.]*$';
end

if all(idx_slctd)
    % If all the files are selected, then just perform the same operation
    % with EXT.
    fname_ck_arch_ptrn = [fname_ck_arch_ptrn ext];
    [fname_ck_crism_out,regexp_out] = spicekrnl_readDownloadBasename( ...
        fname_ck_arch_ptrn, subdir_local, subdir_local, dwld, ...
        'ext_ignore',isempty(ext), 'overwrite',overwrite);
else
    idx_slctd = find(idx_slctd);
    if isempty(idx_slctd)
        fprintf('Not found\n');
        fname_ck_crism_out = [];
        return;
    end

    fnames_slctd = fnames_mtch(idx_slctd);

    fname_ck_crism_out = [];
    for i=1:length(fnames_slctd)
        if ~isempty(fnames_slctd{i})
            fname_slctd = [fnames_slctd{i} '\.' ext];
        end
        [fname_ck_crism_out_1,~] = spicekrnl_readDownloadBasename(fname_slctd, ...
            subdir_local,subdir_local,dwld,'ext_ignore',isempty(ext), ...
            'overwrite',overwrite);
        if iscell(fname_ck_crism_out_1)
            fname_ck_crism_out = [fname_ck_crism_out fname_ck_crism_out_1];
        else
            fname_ck_crism_out = [fname_ck_crism_out {fname_ck_crism_out_1}];
        end
    end

    if length(fname_ck_crism_out)==1
        fname_ck_crism_out = fname_ck_crism_out{1};
    end
end

end