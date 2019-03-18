function [basename] = crism_readDownloadBasename(basenamePtr,subdir_local,subdir_remote,dwld,varargin)
% [basename] = crism_readDownloadBasename(basenamePtr,local_dir,remote_subdir,dwld,varargin)
%    search basenames that match 'basenamePtr' in 'subdir_local' and return
%    the actual name. If nothing can be found, then download any files that
%    matches 'baenamePtr' from 'remote_subdir' depending on 'dwld' option.
%  Input Parameters
%    basenamePtr: regular expression to find a file with mathed basename.
%    subdir_local: local sub-directory path to be searched 
%    subdir_remote: remote_sudir to be searched (input to 'pds_downloader')
%    dwld: {-1, 0, 1, 2}
%          if dwld>0, then this is passed to 'pds_downloader'
%          -1: show the list of file that match the input pattern.
%  Optional input parameters
%      'MATCH_EXACT'    : binary, if basename match should be exact match
%                         or not.
%                         (default) false
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false
%  Output parameters
%    basename: real basename matched.

global crism_env_vars
localrootDir = crism_env_vars.localCRISM_PDSrootDir;
url_local_root = crism_env_vars.url_local_root;

force = 0;
outfile = '';
mtch_exact = false;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MATCH_EXACT'
                mtch_exact = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            otherwise
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

dir_local = joinPath(localrootDir,url_local_root,subdir_local); 

fnamelist = dir(dir_local);
[basename] = extractMatchedBasename_v2(basenamePtr,[{fnamelist.name}],'exact',mtch_exact);
if dwld>0
    if (isempty(basename) && (dwld>0)) || force
        [dirs,files] = pds_downloader(subdir_local,...
            'Subdir_remote',subdir_remote,'BASENAMEPTRN',basenamePtr,...
            'DWLD',dwld,'OUT_FILE',outfile);
    %     fnamelist = dir(dir_ddr);
        [basename] = extractMatchedBasename_v2(basenamePtr,files);
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
end