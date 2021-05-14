function [dir_info,basenameOTT,fnameOTT_wext_local] = crism_get_dirpath_ott(basenameOTT,varargin)
% [dir_info,basenameOTT,fnameOTT_wext_local] = crism_get_dirpath_ott(basenameOTT,varargin)
%  get directory path of the OTT files. The file could
%  be downloaded using an option
%  Inputs
%   basenameOTT: basename of the OTT file
%  Outputs
%   dir_info struct
%       dirfullpath_local: full local directroy path of the CDR file
%       subdir_local     : subdirectory path
%       subdir_remote    : subdirectory for the remote server
%   basenameOTT  : basename of the matched file
%   fnameOTT_wext_local : cell array of the filenames (with extensions) existing 
%                      locally.
%  Optional Parameters (passed onto crism_search_ott_fromProp)
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false

propOTT = getProp_basenameOTT(basenameOTT);
[dir_info,basenameOTT,fnameOTT_wext_local] = get_dirpath_ott_fromProp(propOTT,varargin{:});

end