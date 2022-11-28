function [fnames_spk_sc_out,dirpath] = spice_get_mro_kernel_spk_sc( ...
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
%  "OVERWRITE": boolean, whether or not to overwrite the local files with
%    the files at the remote archive serve.
%
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>
%
dot_ext = '.bsp';
suffix  = '';
% ## downloading options.
dwld      = 0;
overwrite = false;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'EXT'
                dot_ext = varargin{i+1};
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
global mro_crism_spicekrnl_env_vars
localrootDir    = mro_crism_spicekrnl_env_vars.local_SPICEkernel_archive_rootDir;
url_local_root  = mro_crism_spicekrnl_env_vars.url_local_root;

subdir_local = spicekrnl_mro_get_subdir_spk_sc(mro_crism_spicekrnl_env_vars,dirpath_opt);
dirpath = fullfile(localrootDir,url_local_root,subdir_local);

%%
%==========================================================================
% Find corresponding PHASE
%
[spk_arch_infostruct] = mro_spice_get_spk_sc_arch_info();
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

if strcmpi(dot_ext,'all') && dwld>0
    dot_ext = '(?<ext>\.[^\.]*)*$';
end

if all(idx_slctd)
    fname_spk_ptrn = ['mro_(ab|cruise|psp\d+)' suffix dot_ext];
    [fnames_spk_sc_out,regexp_out] = spicekrnl_readDownloadBasename( ...
        mro_crism_spicekrnl_env_vars, fname_spk_ptrn,subdir_local,subdir_local,dwld, ...
        'ext_ignore',isempty(dot_ext),'overwrite',overwrite);
else
    idx_slctd = find(idx_slctd);
    if isempty(idx_slctd)
        fprintf('Not found\n');
        fnames_spk_sc_out = [];
        return;
    end

    phases_slctd = {spk_arch_infostruct(idx_slctd).PHASE};

    if dwld==0
        fnames_spk_sc_out = cellfun(@(x) ['mro_' x suffix '.bsp'],phases_slctd, 'UniformOutput',false);
        idxFound = cellfun(@(x) exist(fullfile(dirpath,x),'file'),fnames_spk_sc_out);
        if ~all(idxFound)
            fnames_notfound = fnames_spk_sc_out(~idxFound);
            error(['%s is not found in ' dirpath '\n'], fnames_notfound{:});
        end
    else
        %%
        %==========================================================================
        % Connect to the remote server to get archived spck files.
        %
        phase_ptrn = ['(' strjoin(phases_slctd,'|') ')'];
        fname_spk_ptrn = ['mro_' phase_ptrn suffix dot_ext];
    
        [fnames_spk_sc_out,regexp_out] = spicekrnl_readDownloadBasename( ...
            mro_crism_spicekrnl_env_vars, fname_spk_ptrn,subdir_local,subdir_local,dwld, ...
            'ext_ignore',isempty(dot_ext),'overwrite',overwrite);
    end
end


end