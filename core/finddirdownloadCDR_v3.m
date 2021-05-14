function [dir_cdr] = finddirdownloadCDR_v3(basenamesCDR,varargin)
% [dir_cdr] = finddirdownloadCDR_v3(basenamesCDR,varargin)
%   get local full paths for CDR files
%   INPUTS
%    basenamesCDR: struct of CDR basenames, field names are two character 
%                  acronyms of CDR files, and their basenames are stored in
%                  the values If multiple files are in the same acronym, 
%                  then its value becomes a cell of basenames.
%   OUTPUT
%    dir_cdr: same structure as basenamesCDR. local full directroy paths
%             are stored.
%   OPTIONAL PARAMETERS (passed onto crism_get_dirpath_cdr)
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false

dir_cdr = [];

fieldnms_cdr = fieldnames(basenamesCDR);
for i=1:length(fieldnms_cdr)
    acro = fieldnms_cdr{i};
    if iscell(basenamesCDR.(acro))
        for k=1:length(basenamesCDR.(acro))
            basename_acro = basenamesCDR.(acro){k};
            [dir_info] = crism_get_dirpath_cdr(basename_acro,varargin{:});
            dir_acro = dir_info.dirfullpath_local;
            dir_cdr = addField(dir_cdr,acro,dir_acro); 
        end
    elseif ischar(basenamesCDR.(acro))
        basename_acro = basenamesCDR.(acro);
        [dir_info] = crism_get_dirpath_cdr(basename_acro,varargin{:});
        dir_acro = dir_info.dirfullpath_local;
        dir_cdr = addField(dir_cdr,acro,dir_acro);
    else
        error('Value of the basenamesCDR.(%s) is not valid',acro);
    end
end

end
