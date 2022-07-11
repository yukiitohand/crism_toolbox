function [dirs,files] = smb_downloader(subdir_local, ...
    localrootDir, remoterootDir, url_local_root, url_remote_root, varargin)
% [dirs,files] = smb_downloader(subdir_local,varargin)
% Get the all the files that match "basenamePtrn" in the specified
% sub directory using smb protocols
%
% Inputs:
% With these inputs, files that match [BASENAMEPTRN] at 
%          [remoterootDir]/[url_remote_root]/[subdir_remote] 
% are saved to
%          [localrootDir]/[url_local_root]/[subdir_local]
%
%  subdir_local    : local sub directory path
%  localrootDir    : root directory path at the local computer
%  remoterootDir   : root directory path at the remote server
%  url_local_root  : 
%  url_remote_root : 
%      
%   Optional Parameters
%      'SUBDIR_REMOTE   : (default) '' If empty, then SUBDIR_LOCAL is used.
%      'BASENAMEPTRN'   : Pattern for the regular expression for file.
%                         (default) '.*'
%      'EXTENSION','EXT': Files with the extention will be downloaded. If
%                         it is empty, then files with any extension will
%                         be downloaded.
%                         (default) ''
%      'DIRSKIP'        : if skip directories or walk into them
%                         (default) 1 (boolean)
%      'OVERWRITE'      : if overwrite the file if exists
%                         (default) 0
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'HTMLFILE'       : path to the html file to be read
%                         (default) ''
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'VERBOSE'        : boolean, whether or not to show the downloading
%                         operations.
%                         (default) true
%      'CAPITALIZE_FILENAME' : whether or not capitalize the filenames or
%      not
%        (default) true
%      'INDEX_CACHE_UPDATE' : boolean, whether or not to update index.html 
%        (default) false
%   Outputs
%      dirs: cell array, list of dirs in the directory
%      files: cell array, list of files downloaded
% 

% global pds_geosciences_node_env_vars
% localrootDir = pds_geosciences_node_env_vars.local_pds_geosciences_node_rootDir;
% url_local_root = pds_geosciences_node_env_vars.pds_geosciences_node_root_URL;
% url_remote_root = pds_geosciences_node_env_vars.pds_geosciences_node_root_URL;


basenamePtrn  = '.*';
ext           = '';
subdir_remote = '';
overwrite     = 0;
dirskip       = 1;
dwld          = 0;
outfile       = '';
cap_filename  = true;
index_cache_update = false;
verbose = true;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'BASENAMEPTRN'
                basenamePtrn = varargin{i+1};
            case {'EXT','EXTENSION'}
                ext = varargin{i+1};
            case 'SUBDIR_REMOTE'
                subdir_remote = varargin{i+1};
            case 'DIRSKIP'
                dirskip = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            case 'VERBOSE'
                verbose = varargin{i+1};
            case 'CAPITALIZE_FILENAME'
                cap_filename = varargin{i+1};
            case 'INDEX_CACHE_UPDATE'
                index_cache_update = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

if dwld==0
    if verbose
        fprintf('Nothing is performed with Download=%d\n',dwld);
    end
    return;
end

if ~isempty(ext)
    if ischar(ext)
        if ~strcmp(ext(1),'.')
            ext = ['.' ext];
        end
    elseif iscell(ext)
        for i=1:length(ext)
            if ~strcmp(ext{i}(1),'.')
                ext{i} = ['.' ext];
            end
        end
        
    end
end

no_local_directory = false;

url_local      = fullfile(url_local_root,subdir_local);
localTargetDir = fullfile(localrootDir,url_local);
if isempty(subdir_remote)
   subdir_remote = subdir_local;
end
url_remote = fullfile(remoterootDir, url_remote_root, subdir_remote);

if ~exist(localrootDir,'dir')
    fprintf('localrootdir "%s" does not exist.',localrootDir);
    flg = 1;
    while flg
        prompt = sprintf('Do you want to create it? (y/n)');
        ow = input(prompt,'s');
        if any(strcmpi(ow,{'y','n'}))
            flg=0;
        else
            fprintf('Input %s is not valid.\n',ow);
        end
    end
    if strcmpi(ow,'n')
        flg2 = 1;
        while flg2
            prompt = sprintf('Do you want to continue(y/n)?');
            ow_2 = input(prompt,'s');
            if any(strcmpi(ow_2,{'y','n'}))
                flg2=0;
            else
                fprintf('Input %s is not valid.\n',ow);
            end
        end
        if strcmpi(ow_2,'y')
            if dwld==2
                error('No local database, so dwld=%d is not valid',dwld);
            elseif dwld == 1
                fprintf('only remote url will be printed.\n');
            end
            no_local_directory = true;
        elseif strcmpi(ow_2,'n')
            fprintf('Process aborted...\n');
            return;
        end
    elseif strcmpi(ow,'y')
        [status] = mkdir(localrootDir);
        if status
            fprintf('localrootdir "%s" is created.\n',localrootDir);
            if isunix
                system(['chmod -R 777 ' localrootDir]);
                if verbose, fprintf('localrootdir "%s": permission is set to 777.\n',localrootDir); end
            end
        else
            error('Failed to create %s',localrootDir);
        end
    end
end





dirs = []; files = [];
errflg=0;
% dirnameList is the cell array of the directory/file names in 
dir_cachefilepath = fullfile(localTargetDir,'dir_struct.mat');
if ~exist(url_remote,'dir')
    errflg = 1;
end
if ~index_cache_update && exist(dir_cachefilepath,'file')
    load(dir_cachefilepath,'dir_struct');
else
    if exist(url_remote,'dir')
        dir_struct = dir(url_remote);
        dirnames   = {dir_struct.name};
        valid_idx  = not(or(strcmpi(dirnames,{'.'}),strcmpi(dirnames,{'..'})));
        dir_struct = dir_struct(valid_idx);
        % create the target directory and set 777
        url_local_splt = split(url_local,'/');
        dcur = localrootDir;
        if ~exist(localTargetDir,'dir') % if the directory doesn't exist,
            for i=1:length(url_local_splt)
                dcur = fullfile(dcur,url_local_splt{i});
                if ~exist(dcur,'dir')
                    [status] = mkdir(dcur);
                    if status
                        if verbose, fprintf('"%s" is created.\n',dcur); end
                        chmod777(dcur,verbose);
                    else
                        error('Failed to create %s',dcur);
                    end
                end
            end
        end
        if exist(dir_cachefilepath,'file')
            delete(dir_cachefilepath);
        end
        save(dir_cachefilepath,'dir_struct');
        chmod777(dir_cachefilepath,verbose);
    else
        errflg = 1;
    end
end

% 
if ~isempty(outfile)
    fp = fopen(outfile,'a');
end
if ~errflg
    
    fnamelist_local = dir(localTargetDir);
    fnamelist_local = {fnamelist_local(~[fnamelist_local.isdir]).name};
    match_flg = 0;
    for i=1:length(dir_struct)
        if dir_struct(i).isdir
            dirname = dir_struct(i).name;
            dirs = [dirs {dirname}];
            if dirskip
               % skip
            else
                % recursively access the directory
                if verbose
                    fprintf('Going to %s\n',fullfile(subdir_local,dirname));
                end
                [dirs_ch,files_ch] = smb_downloader(...
                    fullfile(subdir_local,lnks(i).hyperlink),...
                    'SUBDIR_REMOTE',fullfile(subdir_remote,dirname),...
                    'Basenameptrn',basenamePtrn,'EXT',ext,'dirskip',dirskip,...
                    'overwrite',overwrite,...
                    'dwld',dwld,'out_file',outfile,'CAPITALIZE_FILENAME',cap_filename, ...
                    'INDEX_CACHE_UPDATE',index_cache_update);
                for ii=1:length(dirs_ch)
                    dirs_ch{ii} = fullfile(dirname,dirs_ch{ii});
                end
                dirs = [dirs dirs_ch];
                for ii=1:length(files_ch)
                    files_ch{ii} = fullfile(dirname,files);
                end
                files = [files files_ch];
            end
        else
            filename = dir_struct(i).name;
            remoteFile = fullfile(url_remote,filename);
            if cap_filename
                filename_local = upper(filename);
            else
                filename_local = filename;
            end
            [~,~,ext_filename] = fileparts(filename);
            % Proceed if the filename matches the ptrn and extension
            % matches
            if ~isempty(regexpi(filename,basenamePtrn,'ONCE')) ...
                && ( isempty(ext) || ( ~isempty(ext) && any(strcmpi(ext_filename,ext)) ) )
                match_flg = 1;
                localTarget = fullfile(localTargetDir,filename_local);
                
                exist_idx = find(strcmpi(filename_local,fnamelist_local));
                exist_flg = ~isempty(exist_idx);
                
                switch dwld
                    case 2
                        if exist_flg && ~overwrite
                            % Skip downloading
                            if verbose
                                fprintf('Exist: %s\n',localTarget);
                                fprintf('Skip downloading\n');
                            end
                        else
                            if exist_flg && overwrite
                                if verbose
                                    fprintf('Exist: %s\n',localTarget);
                                    fprintf('Overwriting..');
                                    for ii=1:length(exist_idx)
                                        exist_idx_ii = exist_idx(ii);
                                        localExistFilePath = fullfile(localTargetDir,fnamelist_local{exist_idx_ii});
                                        fprintf('Deleting %s ...\n',localExistFilePath);
                                        delete(localExistFilePath);
                                    end
                                end
                            end
                            if verbose
                                fprintf(['Copy\t' remoteFile '\n\t-->\t' localTarget '\n']);
                            end
                            [err] = copyfile(localTarget,remoteFile);
                            if verbose
                                if err
                                    fprintf('......Download failed.\n');
                                else
                                    fprintf('......Done!\n');
                                    chmod777(localTarget,verbose);
                                end
                            end
                        end
                    case 1
                        if verbose
                            if no_local_directory
                                fprintf('%s\n',remoteFile);
                            else
                                fprintf('%s,%s\n',remoteFile,localTarget);
                            end
                            if ~isempty(outfile)
                                if no_local_directory
                                    fprintf(fp,'%s\n',remoteFile);
                                else
                                    fprintf(fp,'%s,%s\n',remoteFile,localTarget);
                                end
                            end
                        end
                    case 0
                        if verbose
                            fprintf('Nothing happens with dwld=0\n');
                        end
                    otherwise
                        error('dwld=%d is not defined\n',dwld);
                end
                
                files = [files {filename_local}];
            end

        end   
    end
    if match_flg==0
        if verbose
            fprintf('No file matches %s in %s.\n',basenamePtrn,subdir_remote);
        end
    end
end

if ~isempty(outfile)
    fclose(fp);
end

end
