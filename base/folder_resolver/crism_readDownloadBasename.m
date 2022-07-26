function [basename,fname_wext_local,files_remote] = crism_readDownloadBasename(basenamePtr,subdir_local,dwld,varargin)
% [basename,fname_wext_local,files_dwlded] = crism_readDownloadBasename(basenamePtr,local_dir,dwld,varargin)
%    search basenames that match 'basenamePtr' in 'subdir_local' and return
%    the actual name. If nothing can be found, then download any files that
%    matches 'baenamePtr' from 'remote_subdir' depending on 'dwld' option.
%  Input Parameters
%    basenamePtr: regular expression to find a file with mathed basename.
%    subdir_local: local sub-directory path to be searched 
%    subdir_remote: remote_sudir to be searched (input to 'pds_downloader')
%    dwld: {-1, 0, 1, 2}
%          if dwld>0, then this is passed to 'pds_downloader'
%          -1: show the list of file that match the input pattern present
%          in the local directory.
%  Optional input parameters
%      'Subdir_Remote'  : char, string, subdirectory path for the remote
%                         repository
%                         
%      'EXTENSION','EXT': Files with the extention will be downloaded. If
%                         it is empty, then files with any extension will
%                         be downloaded.
%                         (default) ''
%      'OVERWRITE'      : if overwrite the file if exists
%                         (default) 0
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'INDEX_CACHE_UPDATE' : boolean, whether or not to update index.html 
%        (default) false
%  Output parameters
%    basename: basename matched.
%    fname_wext_local : file name with extensions that exist localy.
%    files_remote : relative path from subdir_local to the remote files.


global crism_env_vars
localrootDir   = crism_env_vars.localCRISM_PDSrootDir;
url_local_root = crism_env_vars.url_local_root;
no_remote      = crism_env_vars.no_remote;
if isfield(crism_env_vars,'dir_tmp')
    dir_tmp = crism_env_vars.dir_tmp;
else
    dir_tmp = [];
end

ext = '';
mtch_exact = false;
overwrite = 0;
index_cache_update = false;
celloutput = false;
verbose = true;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'SUBDIR_REMOTE'
                subdir_remote = varargin{i+1};
            case {'EXT','EXTENSION'}
                ext = varargin{i+1};
            case 'MATCH_EXACT'
                mtch_exact = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case 'INDEX_CACHE_UPDATE'
                index_cache_update = varargin{i+1};
            case 'CELLOUTPUT'
                celloutput = varargin{i+1};
            case 'VERBOSE'
                verbose = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

% If you are not connecting remote network, you do not need to download
% anything.
if no_remote && dwld>0
    error(['No remote server is defined in crism_env_vars.\n' ...
           ['dwld=%d >0 is invalid. dwld can be either 0 or -1 for no_remote=1.'] ...
          ], dwld);
end

dir_local = fullfile(localrootDir,url_local_root,subdir_local);

if dwld <= 0
    if no_remote && ~isempty(dir_tmp)
        cache_dir = fullfile(dir_tmp,url_local_root,subdir_local);
        index_cache_fname = 'index.txt';
        index_cache_fpath = fullfile(cache_dir,index_cache_fname);
        if exist(index_cache_fpath,'file') && ~index_cache_update
            fid = fopen(index_cache_fpath,'r');
            fnamelist = textscan(fid,'%s');
            fclose(fid);
            fnamelist = reshape(fnamelist{1},1,[]);
        else
            if exist(dir_local,'dir')
                filelist = dir(dir_local);
                fnamelist = {filelist.name};
                if ~exist(cache_dir,'dir'), mkdir(cache_dir); end
                fid = fopen(index_cache_fpath,'w');
                fprintf(fid,'%s\r\n',fnamelist{:});
                fclose(fid);
            else
                fnamelist = {};
            end
        end
    else
        filelist = dir(dir_local);
        fnamelist = {filelist.name};
    end
    if ~isempty(fnamelist)
        [basename,fname_wext_local] = extractMatchedBasename_v2(basenamePtr, ...
            fnamelist,'exact',mtch_exact,'CellOutput',celloutput);
        files_remote = {};
    else
        basename = {}; fname_wext_local = {}; files_remote = {};
    end
elseif dwld>0
    [dirs,files_remote] = crism_pds_downloader(subdir_local,      ...
        'Subdir_remote',subdir_remote,'BASENAMEPTRN',basenamePtr, ...
        'DWLD',dwld,'overwrite',overwrite, 'EXTENSION',ext, ...
        'INDEX_CACHE_UPDATE',index_cache_update, ...
        'VERBOSE',verbose);%,'CAPITALIZE_FILENAME',cap_filename);
    % basename is searched from the remote database.
    [basename,fname_wext_local] = extractMatchedBasename_v2(basenamePtr, ...
        files_remote,'exact',mtch_exact,'CellOutput',celloutput);
        
    % Get the list of files in the local database after download is
    % performed.
    if dwld==1
        fnamelist = dir(dir_local);
        [~,fname_wext_local] = extractMatchedBasename_v2(basenamePtr, ...
            {fnamelist.name},'exact',mtch_exact,'CellOutput',celloutput);
    end
end

        
% for i=1:length(files_dwlded)
%     files_dwlded{i} = joinPath(dir_local,files_dwlded{i});
% end
% 
% for i=1:length(basename_wext)
%     basename_wext{i} = joinPath(dir_local,basename_wext{i});
% end

end
