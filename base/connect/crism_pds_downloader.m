function [dirs,files] = crism_pds_downloader(subdir_local,varargin)
% [] = crism_pds_downloader(subdir_local)
% read files from PDS. This is an internal function. Please be careful
% using this directly.
%
% Inputs:
%  subdir_local: subdirectory path
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
%      'PROTOCOL'       : internet protocol for downloading
%                         (default) 'http'
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

global crism_env_vars
localrootDir    = crism_env_vars.localCRISM_PDSrootDir;
remoterootDir   = crism_env_vars.remoteCRISM_PDSrootDir;
local_fldsys    = crism_env_vars.local_fldsys;
remote_fldsys   = crism_env_vars.remote_fldsys;
url_local_root  = crism_env_vars.url_local_root;
url_remote_root = crism_env_vars.url_remote_root;
protocol = crism_env_vars.remote_protocol;


basenamePtrn  = '.*';
ext           = '';
subdir_remote = '';
overwrite     = 0;
dirskip       = 1;
dwld          = 0;
html_file     = '';
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
            case 'SUBDIR_REMOTE'
                subdir_remote = varargin{i+1};
            case 'PROTOCOL'
                protocol = varargin{i+1};
            case {'EXT','EXTENSION'}
                ext = varargin{i+1};
            case 'DIRSKIP'
                dirskip = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case 'HTML_FILE'
                html_file = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            case 'INDEX_CACHE_UPDATE'
                index_cache_update = varargin{i+1};
            case 'VERBOSE'
                verbose = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

% First always test if the file system is consistent.
url_local = joinPath(url_local_root,subdir_local);
if ~isempty(subdir_local)
    if ~(is_subdir_pds_crism_pub(url_local) == strcmpi(local_fldsys,'pds_mro'))
        error('subdir_local (%s) and local_fldsys (%s) are not consistent',url_local,local_fldsys);
    end
end

if isempty(subdir_remote)
   if strcmpi(local_fldsys,remote_fldsys)
       subdir_remote = subdir_local;
       url_remote = joinPath(url_remote_root, subdir_remote);
   else
       error('specified file systems for the local and remote computers are different."subdir_remote" cannot be empty.');
   end
else
    if strcmpi(protocol,'http') && isHTTP_fullpath(subdir_remote)
        url_remote = getURLfrom_HTTP_fullpath(subdir_remote);
    else
        url_remote = joinPath(url_remote_root,subdir_remote);
    end
end

if ~isempty(subdir_remote)
    if ~(is_subdir_pds_crism_pub(url_remote) == strcmpi(remote_fldsys,'pds_mro'))
        fprintf(2,'subdir_remote (%s) and remote_fldsys (%s) are not consistent.\n',...
            url_remote,remote_fldsys);
        fprintf(1,'cannot download file matches %s\n', basenamePtrn);
        fprintf(1,'check functions crism_toolbox/base/folder_resolverget_crism_pds_mro_path_xxx\n');
        dirs = []; files = [];
        return;
    end
end

switch protocol
    case {'http'}
        % All the parameters are passed to pds_universal_downloader.m
        [dirs,files] = pds_universal_downloader(subdir_local, ...
            localrootDir, url_local_root, url_remote_root, @crism_get_links_remoteHTML, ...
            'BASENAMEPTRN',basenamePtrn,'SUBDIR_REMOTE',subdir_remote, ...
            'CAPITALIZE_FILENAME', true,'VERBOSE',true,'EXT',ext,'DIRSKIP',dirskip, ...
            'protocol',protocol,'overwrite',overwrite,'dwld',dwld, ...
            'OUT_FILE',outfile, 'HTML_FILE', html_file, ...
            'INDEX_CACHE_UPDATE',index_cache_update);

    case {'smb'}
        % All the parameters are passed to smb_downloader.m
        [dirs,files] = smb_downloader(subdir_local, ...
            localrootDir, remoterootDir, url_local_root, url_remote_root, ...
            'BASENAMEPTRN',basenamePtrn, 'SUBDIR_REMOTE', subdir_remote, ...
            'CAPITALIZE_FILENAME', true,'VERBOSE',true,'EXT',ext,'DIRSKIP',dirskip, ...
            'overwrite',overwrite,'dwld',dwld,'OUT_FILE',outfile, ...
            'INDEX_CACHE_UPDATE',index_cache_update);
    otherwise
        error('Undefined protocol %s.',protocol);
end

end


function [flg] = is_subdir_pds_crism_pub(subdir)
ptrn = 'mro/mro-m-crism-.*/mrocr_.*/';
flg = ~isempty(regexpi(subdir,ptrn,'once'));
end
