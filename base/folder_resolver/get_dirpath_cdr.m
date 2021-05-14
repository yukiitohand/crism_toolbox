function [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname] = get_dirpath_cdr(basenameCDR,varargin)
% [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname] = get_dirpath_cdr(basenameCDR,varargin)
%  get directory path of the given basename of the CDR file. The file could
%  be downloaded using an option
%  Inputs
%   basenameCDR: basename of the CDR file
%  Outputs
%   dirfullpath_local: full local directroy path of the CDR file
%   subdir_local     : subdirectory path
%   subdir_remote    : subdirectory for the remote server
%   yyyy_doy    : yyyy_doy, if applicable,
%   dirname: directory name, two character acronym.
%  Optional Parameters (passed onto get_dirpath_cdr_fromProp)
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false

propCDR = getProp_basenameCDR(basenameCDR);
[dirfullpath_local,subdir_local,subdir_remote,~,...
    acro,~,yyyy_doy] = get_dirpath_cdr_fromProp(propCDR,varargin{:});

dirname = acro;

end