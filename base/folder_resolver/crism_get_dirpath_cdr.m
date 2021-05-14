function [dir_info,basenameCDR,fnameCDR_wext_local] = crism_get_dirpath_cdr(basenameCDR,varargin)
% [dir_info,basenameCDR,fnameCDR_wext_local] = crism_get_dirpath_cdr(basenameCDR,varargin)
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
%   basenameCDR: basename of the matched file
%   fnameCDR_wext_local : cell array of the filenames (with extensions) existing 
%                      locally.
%  Optional Parameters (passed onto crism_search_cdr_fromProp.m)
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

propCDR = crism_getProp_basenameCDR(basenameCDR);
[dir_info,basenameCDR,fnameCDR_wext_local] = crism_search_cdr_fromProp(propCDR,varargin{:});
dir_info.dirname = dir_info.acro;

end