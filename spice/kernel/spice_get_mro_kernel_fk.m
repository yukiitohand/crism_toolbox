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

fname_fk  = '';
dot_ext   = '.tf';
arch_code = 'NAIF'; % {'NAIF','INTERNAL'}
vr        = [];
verbose   = true;


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
            case 'ARCHIVE_CODE'
                arch_code = varargin{i+1};
            case 'VERBOSE'
                verbose = varargin{i+1};
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
no_remote       = mro_crism_spicekrnl_env_vars.no_remote;
fldsys          = mro_crism_spicekrnl_env_vars.fldsys;

%%
%==========================================================================
% Input interpretation
%==========================================================================
get_latest = (ischar(vr) && strcmpi(vr,'latest'));
if strcmpi(dot_ext,'all'), dot_ext = '(?<ext>\.[^\.]*)*$'; end
if ~isempty(fname_fk) && ischar(fname_fk), fname_fk = {fname_fk}; end
if (no_remote || dwld==0) && ~isempty(fname_fk) && ~get_latest
    % If the fname_fk is provided
    fname_fk_ptrn_naifver  = ['^mro_v(?<version>\d{2})' dot_ext];
    fname_fk_ptrn_internalver = ['^MRO_CRISM_FK_0000_000_N_(?<version>\d+)' dot_ext];
    mtch_naifver     = regexpi(fname_fk,fname_fk_ptrn_naifver,'names');
    mtch_internalver = regexpi(fname_fk,fname_fk_ptrn_internalver,'names');

    fname_fk_out = []; dirpath = []; vr_out = [];
    for i=1:length(mtch_naifver)
        fname_fk_i = fname_fk{i};
        if ~isempty(mtch_internalver{i})
            mtch_internalver_i = mtch_internalver{i};
            if strcmpi(fldsys,'naif') % You won't find this in the naif spice archive
                if verbose
                    fprintf('Skipping %s\nWill not be found if fldsys==%s.\n', fname_fk_i, fldsys);
                end
            else
                subdir_local = spicekrnl_mro_get_subdir_fk_internal_version(mro_crism_spicekrnl_env_vars);
                dirpath_i = fullfile(localrootDir,url_local_root,subdir_local);
                if exist(fullfile(dirpath_i,fname_fk_i),'file')
                    vr_out = [vr_out str2double(mtch_internalver_i.version)];
                    fname_fk_out = [fname_fk_out {fname_fk_i}];
                    dirpath = [dirpath {dirpath_i}];
                else
                    % Adhoc processing...
                    vr_str = sprintf('(%02s|%s)',mtch_internalver_i.version,mtch_internalver_i.version);
                    fname_fk_ptrn_internalver = sprintf('^MRO_CRISM_FK_0000_000_N_(?<version>%s)',vr_str);
                    fname_fk_ptrn_internalver = [fname_fk_ptrn_internalver dot_ext];
                    [fname_fk_out_i,vr_out_i] = spice_get_kernel( ...
                        mro_crism_spicekrnl_env_vars, fname_fk_ptrn_internalver, ...
                        'SUBDIR_LOCAL',subdir_local,'SUBDIR_REMOTE',subdir_local, ...
                        'ext_ignore',isempty(dot_ext), 'GET_LATEST',get_latest, ...
                        'DWLD',dwld,'overwrite',overwrite);
                    if isempty(fname_fk_out_i)
                        error('Something wrong with the input fname');
                    else
                        vr_out = [vr_out vr_out_i];
                        fname_fk_out = [fname_fk_out {fname_fk_out_i}];
                        dirpath = [dirpath {dirpath_i}];
                    end
                    
                end
            end
        elseif ~isempty(mtch_naifver{i})
            mtch_naifver_i = mtch_naifver{i};
            subdir_local = spicekrnl_mro_get_subdir_fk_naifarchive_version(mro_crism_spicekrnl_env_vars,dirpath_opt);
            dirpath_i = fullfile(localrootDir,url_local_root,subdir_local);
            if exist(fullfile(dirpath_i,fname_fk_i),'file')
                vr_out = [vr_out str2double(mtch_naifver_i.version)];
                fname_fk_out = [fname_fk_out {fname_fk_i}];
                dirpath = [dirpath {dirpath_i}];
            else
                error('%s is not found in %s.',fname_fk_i,dirpath_i);
            end
        else
            error('Something wrong with the input fname');
        end
    end
else
    if ~isempty(fname_fk)
        % If the fname_fk is provided
        fname_fk_ptrn_naifver     = ['^mro_v(?<version>\d{2})' dot_ext];
        fname_fk_ptrn_internalver = ['^MRO_CRISM_FK_0000_000_N_(?<version>\d+)' dot_ext];
        mtch_naifver     = regexpi(fname_fk,fname_fk_ptrn_naifver,'names');
        mtch_internalver = regexpi(fname_fk,fname_fk_ptrn_internalver,'names');
    
        fname_fk_out = []; dirpath = []; vr_out = [];
        for i=1:length(mtch_naifver)
            fname_fk_i = fname_fk{i};
            if ~isempty(mtch_internalver{i})
                mtch_internalver_i = mtch_internalver{i};
                if strcmpi(fldsys,'naif') % You won't find this in the naif spice archive
                    if verbose
                        fprintf('Skipping %s\nWill not be found if fldsys==%s.\n', fname_fk_i, fldsys);
                    end
                else
                    if ~get_latest
                        fname_fk_ptrn_internalver= sprintf('^MRO_CRISM_FK_0000_000_N_(?<version>%s)',mtch_internalver_i.version);
                        fname_fk_ptrn_internalver = [fname_fk_ptrn_naifver dot_ext];
                    end
                    subdir_local = spicekrnl_mro_get_subdir_fk_internal_version(mro_crism_spicekrnl_env_vars);
                    dirpath_i = fullfile(localrootDir,url_local_root,subdir_local);
                    [fname_fk_out_i,vr_out_i] = spice_get_kernel( ...
                    mro_crism_spicekrnl_env_vars, fname_fk_ptrn_internalver, ...
                        'SUBDIR_LOCAL',subdir_local,'SUBDIR_REMOTE',subdir_local, ...
                    'ext_ignore',isempty(dot_ext), 'GET_LATEST',get_latest, ...
                    'DWLD',dwld,'overwrite',overwrite);
                
                    vr_out = [vr_out vr_out_i];
                    fname_fk_out = [fname_fk_out {fname_fk_out_i}];
                    dirpath = [dirpath {dirpath_i}];
                end
            elseif ~isempty(mtch_naifver{i})
                mtch_naifver_i = mtch_naifver{i};
                subdir_local = spicekrnl_mro_get_subdir_fk_naifarchive_version(mro_crism_spicekrnl_env_vars,dirpath_opt);
                dirpath_i = fullfile(localrootDir,url_local_root,subdir_local);
                if ~get_latest
                    fname_fk_ptrn_naifver=sprintf('^mro_v(?<version>%s)',mtch_naifver_i.version);
                    fname_fk_ptrn_naifver = [fname_fk_ptrn_naifver dot_ext];
                end
                [fname_fk_out_i,vr_out_i] = spice_get_kernel( ...
                    mro_crism_spicekrnl_env_vars, fname_fk_ptrn_naifver, ...
                    'SUBDIR_LOCAL',subdir_local,'SUBDIR_REMOTE',subdir_local, ...
                    'ext_ignore',isempty(dot_ext), 'GET_LATEST',get_latest, ...
                    'DWLD',dwld,'overwrite',overwrite);
                
                vr_out = [vr_out vr_out_i];
                fname_fk_out = [fname_fk_out {fname_fk_out_i}];
                dirpath = [dirpath {dirpath_i}];
            else
                error('Something wrong with the input fname');
            end
        end
    else
        switch upper(arch_code)
            case 'NAIF'
                if isempty(vr) || get_latest, vr_str = '\d{2}';
                elseif isnumeric(vr)        , vr_str = sprintf('%02d',vr);
                elseif ischar(vr)           , vr_str = sprintf('%02s',vr);
                else, error('Invalid version input');
                end
                subdir_local = spicekrnl_mro_get_subdir_fk_naifarchive_version(mro_crism_spicekrnl_env_vars,dirpath_opt);
                dirpath = fullfile(localrootDir,url_local_root,subdir_local);
                fname_fk_ptrn_naifver = sprintf('^mro_v(?<version>%s)', vr_str);
                fname_fk_ptrn_naifver = [fname_fk_ptrn_naifver dot_ext];
                [fname_fk_out,vr_out] = spice_get_kernel( ...
                    mro_crism_spicekrnl_env_vars, fname_fk_ptrn_naifver, ...
                    'SUBDIR_LOCAL',subdir_local,'SUBDIR_REMOTE',subdir_local, ...
                    'ext_ignore',isempty(dot_ext), 'GET_LATEST',get_latest, ...
                    'DWLD',dwld,'overwrite',overwrite);
            case 'INTERNAL'
                if isempty(vr) || get_latest, vr_str = '\d+';
                elseif isnumeric(vr)        , vr_str = sprintf('(%02d|%d)',vr,vr);
                elseif ischar(vr)           , vr_str = sprintf('(%02s|%s)',vr,vr);
                else, error('Invalid version input');
                end
                subdir_local = spicekrnl_mro_get_subdir_fk_internal_version(mro_crism_spicekrnl_env_vars);
                dirpath = fullfile(localrootDir,url_local_root,subdir_local);
                fname_fk_ptrn_internalver= sprintf('^MRO_CRISM_FK_0000_000_N_(?<version>%s)',vr_str);
                fname_fk_ptrn_internalver = [fname_fk_ptrn_internalver dot_ext];
                [fname_fk_out,vr_out] = spice_get_kernel( ...
                    mro_crism_spicekrnl_env_vars, fname_fk_ptrn_internalver, ...
                    'SUBDIR_LOCAL',subdir_local,'SUBDIR_REMOTE',subdir_local, ...
                    'ext_ignore',isempty(dot_ext), 'GET_LATEST',get_latest, ...
                    'DWLD',dwld,'overwrite',overwrite);
            otherwise
                error('Undefined ARCHIVE_CODE = %s',arch_code);
        end
    end
end

end