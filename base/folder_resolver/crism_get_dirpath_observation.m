function [dir_info,basenameOBS,fnameOBS_wext_local] = crism_get_dirpath_observation(basenameOBS,varargin)
% [dir_info,basenameOBS,fnameOBS_wext_local] = crism_get_dirpath_observation(basenameOBS,varargin)
%  get directory path of the given basename of observation basename. 
%  The file could be downloaded using an option
%  Inputs
%   basenameOBS: basename of the observation file
%  Outputs
%   dir_info struct
%       dirfullpath_local: full local directroy path of the obs file
%       subdir_local     : subdirectory path
%       subdir_remote    : subdirectory for the remote server
%       yyyy_doy         : yyyy_doy
%       dirname          : directory name
%   basenameOBS: basename of the matched file
%   fnameOBS_wext_local : cell array of the filenames (with extensions) existing 
%                      locally.
%  Optional Parameters (passed onto crism_search_observation_fromProp)
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

propOBS = getProp_basenameOBSERVATION(basenameOBS);
[dir_info,basenameOBS,fnameOBS_wext_local] = crism_search_observation_fromProp(propOBS,varargin{:});

end
