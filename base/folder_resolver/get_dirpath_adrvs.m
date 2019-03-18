function [dirfullpath_local,subdir_local,subdir_remote,dirname] = get_dirpath_adrvs(basenameADRVS,varargin)
% [dirfullpath_local,subdir_local,subdir_remote,dirname] = get_dirpath_adrvs(basenameADRVS,varargin)
%  get directory path of the given basename of the ADR VS file. The file could
%  be downloaded using an option
%  Inputs
%   propADRVS: basename of the ADR VS file, can be empty.
%  Outputs
%   dirfullpath_local: full local directroy path of the CDR file
%   subdir_local     : subdirectory path
%   subdir_remote    : subdirectory for the remote server
%   dirname: directory name, two character acronym, VS
%  Optional Parameters (passed onto get_dirpath_adrvs_fromProp)
%      'DWLD','DOWNLOAD' : {0,-1}, -1: list all matched filenames. 0:
%                         nothing happens
%                         (default) 0
%      'OUT_FILE'       : path to the output file. if empty, nothing
%                         happens.
%                         (default) ''

propADRVS = getProp_basenameADRVS(basenameADRVS);
[dirfullpath_local,subdir_local,subdir_remote,~,acro] = get_dirpath_adrvs_fromProp(propADRVS,varargin{:});

dirname = acro;