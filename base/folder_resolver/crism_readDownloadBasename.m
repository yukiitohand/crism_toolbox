function [basename,fname_wext_local,files_dwlded] = crism_readDownloadBasename(basenamePtr,subdir_local,subdir_remote,dwld,varargin)
% [basename,fname_wext_local,files_dwlded] = crism_readDownloadBasename(basenamePtr,local_dir,remote_subdir,dwld,varargin)
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
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false
%      'EXTENSION','EXT': Files with the extention will be downloaded. If
%                         it is empty, then files with any extension will
%                         be downloaded.
%                         (default) ''
%      'OVERWRITE'      : if overwrite the file if exists
%                         (default) 0
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
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
%  Output parameters
%    basename: basename matched.
%    fname_wext_local : file name with extensions that exist localy.
%    files_dwlded : relative path from subdir_local to the downloaded files.


global crism_env_vars
localrootDir = crism_env_vars.localCRISM_PDSrootDir;
url_local_root = crism_env_vars.url_local_root;

ext = '';
force = 0;
outfile = '';
mtch_exact = false;
overwrite = 0;
cap_filename  = true;
index_cache_update = false;
verbose = true;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case {'EXT','EXTENSION'}
                ext = varargin{i+1};
            case 'MATCH_EXACT'
                mtch_exact = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case 'VERBOSE'
                verbose = varargin{i+1};
            case 'INDEX_CACHE_UPDATE'
                index_cache_update = varargin{i+1};
            case 'CAPITALIZE_FILENAME'
                cap_filename = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

dir_local = joinPath(localrootDir,url_local_root,subdir_local); 

fnamelist = dir(dir_local);
[basename,fname_wext_local] = extractMatchedBasename_v2(basenamePtr,[{fnamelist.name}],'exact',mtch_exact);
files_dwlded = [];
if dwld>0
    if isempty(basename) || dwld>0 || force
        [dirs,files_dwlded] = crism_pds_downloader(subdir_local,...
            'Subdir_remote',subdir_remote,'BASENAMEPTRN',basenamePtr,...
            'DWLD',dwld,'OUT_FILE',outfile,'overwrite',overwrite,...
            'EXTENSION',ext,'INDEX_CACHE_UPDATE',index_cache_update,...
            'VERBOSE',verbose,'CAPITALIZE_FILENAME',cap_filename);
        
        % do the same thing again
        fnamelist = dir(dir_local);
        [basename,fname_wext_local] = extractMatchedBasename_v2(basenamePtr,[{fnamelist.name}],'exact',mtch_exact);
        
    end
elseif dwld == -1
    if ~isempty(outfile)
        fp = fopen(outfile,'a');
    end
    for j=1:length(fnamelist)
        fname = fnamelist(j).name;
        if ~isempty(regexpi(fname,basenamePtr,'ONCE'))
            subpath = joinPath(subdir_local,fname);
            fprintf('%s\n',subpath);
            if ~isempty(outfile)
                fprintf(fp,'%s\n',subpath);
            end
        end
    end
    if ~isempty(outfile)
        fclose(fp);
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
