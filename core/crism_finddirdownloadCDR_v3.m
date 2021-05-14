function [dir_cdr,files_local] = crism_finddirdownloadCDR_v3(basenamesCDR,varargin)
% [dir_cdr,files_local] = crism_finddirdownloadCDR_v3(basenamesCDR,varargin)
%   get local full paths for CDR files
%   INPUTS
%    basenamesCDR: struct of CDR basenames, field names are two character 
%                  acronyms of CDR files, and their basenames are stored in
%                  the values If multiple files are in the same acronym, 
%                  then its value becomes a cell of basenames.
%   OUTPUT
%    dir_cdr: same structure as basenamesCDR. local full directroy paths
%             are stored.
%    files_local:  same structure as basenamesCDR. all filenames with
%             extensions present locally are listed.
%   OPTIONAL PARAMETERS (passed onto crism_get_dirpath_cdr)
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false
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

dir_cdr = [];
files_local = [];

fieldnms_cdr = fieldnames(basenamesCDR);
for i=1:length(fieldnms_cdr)
    acro = fieldnms_cdr{i};
    if iscell(basenamesCDR.(acro))
        for k=1:length(basenamesCDR.(acro))
            basename_acro = basenamesCDR.(acro){k};
            [dir_info,~,files_localk] = crism_get_dirpath_cdr(basename_acro,varargin{:});
            dir_acro = dir_info.dirfullpath_local;
            dir_cdr = addField(dir_cdr,acro,dir_acro); 
            files_local = addField(files_local,acro,files_localk);
        end
    elseif ischar(basenamesCDR.(acro))
        basename_acro = basenamesCDR.(acro);
        [dir_info,~,files_localk] = crism_get_dirpath_cdr(basename_acro,varargin{:});
        dir_acro = dir_info.dirfullpath_local;
        dir_cdr = addField(dir_cdr,acro,dir_acro);
        files_local.(acro)=files_localk;
    else
        error('Value of the basenamesCDR.(%s) is not valid',acro);
    end
end

end
