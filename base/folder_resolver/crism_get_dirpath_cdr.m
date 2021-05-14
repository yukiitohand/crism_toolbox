function [dir_info] = get_dirpath_cdr(basenameCDR,varargin)
% [dir_info] = get_dirpath_cdr(basenameCDR,varargin)
%  get directory path of the given basename of the CDR file. The file could
%  be downloaded using an option
%  Inputs
%   basenameCDR: basename of the CDR file
%  Outputs
%   dir_info struct
%       dirfullpath_local: full local directroy path of the CDR file
%       subdir_local     : subdirectory path
%       subdir_remote    : subdirectory for the remote server
%       acro             : acronym for the CDR data, usually same sa
%                          dirname
%       folder_type      : folder_type {1,2,3}
%       yyyy_doy         : year and day of the year
%       dirname          : same as acro
%  Optional Parameters (passed onto crism_search_cdr_fromProp.m)
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false

propCDR = getProp_basenameCDR(basenameCDR);
[dir_info] = crism_search_cdr_fromProp(propCDR,varargin{:});
dir_info.dirname = acro;
% dirname = acro;

end