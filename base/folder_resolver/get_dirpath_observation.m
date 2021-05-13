function [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname] = get_dirpath_observation(basenameOBS,varargin)
% [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname,basenameOBS] = get_dirpath_observation(basenameOBS,varargin)
%  get directory path of the given basename of observation basename. 
%  The file could be downloaded using an option
%  Inputs
%   basenameOBS: basename of the observation file
%  Outputs
%   dirfullpath_local: full local directroy path of the obs file
%   subdir_local     : subdirectory path
%   subdir_remote    : subdirectory for the remote server
%   yyyy_doy         : yyyy_doy
%   dirname          : directory name
%  Optional Parameters (passed onto crism_search_observation_fromProp)
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false

propOBS = getProp_basenameOBSERVATION(basenameOBS);
[dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname,~] = crism_search_observation_fromProp(propOBS,varargin{:});

end
