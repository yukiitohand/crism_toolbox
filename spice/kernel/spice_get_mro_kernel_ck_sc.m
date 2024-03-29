function [fnames_ck_sc_out,dirpath] = spice_get_mro_kernel_ck_sc( ...
    fnames_ck,dirpath_opt,varargin)
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
%  "OVERWRITE": boolean, whether or not to overwrite the local files with
%    the files at the remote archive serve.
%
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>
%
dot_ext      = '.bc';
suffix   = '';
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
no_remote = mro_crism_spicekrnl_env_vars.no_remote;

subdir_local = spicekrnl_mro_get_subdir_ck_sc(mro_crism_spicekrnl_env_vars,dirpath_opt);
dirpath = fullfile(localrootDir,url_local_root,subdir_local);
if no_remote, dwld = 0; end

%% Get the datetime range of the input spck files
if ischar(fnames_ck), fnames_ck = {fnames_ck}; elseif isempty(fnames_ck), fnames_ck = {}; end
props_ck = crism_getProp_spice_ck_sc_basename(fnames_ck);
is_cksc = ~isempties(props_ck);
fnames_ck_sc = fnames_ck(is_cksc);

props_ck_nonarchvr = crism_getProp_spice_ck_sc_basename_nonarchvr(fnames_ck);
is_cksc_nonar = ~isempties(props_ck_nonarchvr);
fnames_ck_sc_nonar = fnames_ck(is_cksc_nonar);

if (~isempty(fnames_ck_sc) || ~isempty(fnames_ck_sc_nonar)) && dwld==0
    idxFound = cellfun(@(x) exist(fullfile(dirpath,x),'file'),fnames_ck_sc);
    if all(idxFound), fnames_ck_sc_out = fnames_ck_sc;
    else
        fnames_notfound = fnames_ck_sc(~idxFound);
        error(['%s is not found in ' dirpath '\n'], fnames_notfound{:});
    end
    
    if ~isempty(fnames_ck_sc_nonar)
        props_ck_nonarchvr = [props_ck_nonarchvr{:}];
        dt_min_cksc_na = min([props_ck_nonarchvr.time]);
        dt_max_cksc_na = max([props_ck_nonarchvr.time]);
        
        [archinfo] = spice_get_mro_kernel_ck_sc_arch_info();

        start_time_arch = datetime(archinfo.start_time,'InputFormat','yyMMdd');
        end_time_arch = datetime(archinfo.end_time,'InputFormat','yyMMdd');

        cond1 = start_time_arch <= dt_max_cksc_na;
        cond2 = end_time_arch   >= dt_min_cksc_na;

        idx_slctd = find(and(cond1,cond2));
        if isempty(idx_slctd)
            fprintf('Not found\n');
        else
            nis = length(idx_slctd);
            fnames_ck_sc_na = [repmat('mro_sc_',[nis,1]), ...
                archinfo.phase(idx_slctd,:),repmat('_',[nis,1]), ...
                archinfo.start_time(idx_slctd,:),repmat('_',[nis,1]), ...
                archinfo.end_time(idx_slctd,:),repmat('.bc',[nis,1])];
            fnames_ck_sc_na = reshape(cellstr(fnames_ck_sc_na),1,[]);

            idxFound = cellfun(@(x) exist(fullfile(dirpath,x),'file'),fnames_ck_sc_na);
            if all(idxFound), fnames_ck_sc_out = [fnames_ck_sc_out fnames_ck_sc_na];
            else
                fnames_notfound = fnames_ck_sc_na(~idxFound);
                error(['%s is not found in ' dirpath '\n'], fnames_notfound{:});
            end

            
        end

    end

    
else
    if ~isempty(fnames_ck_sc)
        if length(props_ck)>1
            props_ck = [props_ck{:}];
            dt_min_cksc = min([props_ck.start_time]);
            dt_max_cksc = max([props_ck.end_time]);
        else
            dt_min_cksc = []; dt_max_cksc = [];
        end
        
        if length(props_ck_nonarchvr)>1
            props_ck_nonarchvr = [props_ck_nonarchvr{:}];
            dt_min_cksc_na = min([props_ck_nonarchvr.time]);
            dt_max_cksc_na = max([props_ck_nonarchvr.time]);
        else
            dt_min_cksc_na = []; dt_max_cksc_na = [];
        end
        dt_min_cksc = min(dt_min_cksc,dt_min_cksc_na);
        dt_max_cksc = min(dt_max_cksc,dt_max_cksc_na);


    else
        dt_min_cksc = []; dt_max_cksc = [];
    end

    %%
    %==========================================================================
    % Get all archived spck files.
    %
     fname_ck_sc_ptrn = ['mro_sc_(psp|cru)_(?<yymmdd_strt>\d{6})_(?<yymmdd_end>\d{6})' suffix '\.'];
    
    if mro_crism_spicekrnl_env_vars.no_remote
        [fnames_mtch,regexp_out] = spicekrnl_readDownloadBasename( ...
            mro_crism_spicekrnl_env_vars, fname_ck_sc_ptrn, ...
            subdir_local,subdir_local,0,'ext_ignore',1, ...
            'match_exact',0,'overwrite',overwrite,'verbose',false);
    else
        [fnames_mtch,regexp_out] = spicekrnl_readDownloadBasename( ...
            mro_crism_spicekrnl_env_vars, fname_ck_sc_ptrn, ...
            subdir_local,subdir_local,1,'ext_ignore',1, ...
            'match_exact',0,'overwrite',overwrite,'verbose',false);
    end
    [props] = crism_getProp_spice_ck_sc_basename(fnames_mtch);
    props = [props{:}];
    strt_times = [props.start_time];
    end_times  = [props.end_time]  ;

    %==========================================================================
    % Select 
    %
    if isempty(dt_max_cksc), cond1 = true(size(strt_times));
    else, cond1 = strt_times<=dt_max_cksc;
    end
    if isempty(dt_min_cksc), cond2 = true(size(end_times));
    else, cond2 = end_times>=dt_min_cksc;
    end

    idx_slctd = and(cond1,cond2);
    
    fnames_ck_sc_out = [];
    if strcmpi(dot_ext,'all'), dot_ext = '(?<ext>\.[^\.]*)*$'; end

    if all(idx_slctd)
        % If all the files are selected, then just perform the same operation
        % with EXT.
        fname_ck_sc_ptrn = [fname_ck_sc_ptrn dot_ext];
        [fnames_ck_sc_out,regexp_out] = spicekrnl_readDownloadBasename( ...
            mro_crism_spicekrnl_env_vars, fname_ck_sc_ptrn, ...
            subdir_local, subdir_local, dwld, ...
            'ext_ignore',isempty(dot_ext),'overwrite',overwrite);
    else
        idx_slctd = find(idx_slctd);
        if isempty(idx_slctd)
            fprintf('Not found\n');
            fnames_ck_sc_out = [];
            return;
        end
        fnames_slctd = fnames_mtch(idx_slctd);
        for i=1:length(fnames_slctd)
            if ~isempty(fnames_slctd{i})
                fname_slctd = [fnames_slctd{i} dot_ext];
            end
            [fname_ck_sc_out_1,~] = spicekrnl_readDownloadBasename( ...
                mro_crism_spicekrnl_env_vars, fname_slctd, ...
                subdir_local,subdir_remote,dwld, ...
                'ext_ignore',isempty(dot_ext),'overwrite',overwrite);
            if iscell(fname_ck_sc_out_1)
                fnames_ck_sc_out = [fnames_ck_sc_out fname_ck_sc_out_1];
            else
                fnames_ck_sc_out = [fnames_ck_sc_out {fname_ck_sc_out_1}];
            end
        end
        if length(fnames_ck_sc_out)==1
            fnames_ck_sc_out = fnames_ck_sc_out{1};
        end
    end
end

end