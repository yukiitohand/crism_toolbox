function [dir_info,basenameADRVS,fnameADRVS_wext_local] = crism_get_dirpath_adrvs(basenameADRVS,varargin)
% [dir_info,basenameADRVS,fnameADRVS_wext_local] = crism_get_dirpath_adrvs(basenameADRVS,varargin)
%  get directory path of the given basename of the ADR VS file. The file could
%  be downloaded using an option
%  Inputs
%   propADRVS: basename of the ADR VS file, can be empty.
%  Outputs
%   dir_info struct
%       dirfullpath_local: full local directroy path of the CDR file
%       subdir_local     : subdirectory path
%       subdir_remote    : subdirectory for the remote server
%       acro             : acronym for the CDR data, usually same sa
%                          dirname
%       dirname          : same as acro
%   basenameADRVS: basename of the matched file
%   fnameADRVS_wext_local : cell array of the filenames (with extensions) existing 
%                      locally.
%  Optional Parameters (passed onto crism_search_adrvs_fromProp)
%      'DWLD','DOWNLOAD' : {0,-1}, -1: list all matched filenames. 0:
%                         nothing happens
%                         (default) 0
%      'OUT_FILE'       : path to the output file. if empty, nothing
%                         happens.
%                         (default) ''

propADRVS = getProp_basenameADRVS(basenameADRVS);
[dir_info,basenameADRVS,fnameADRVS_wext_local] = crism_search_adrvs_fromProp(propADRVS,varargin{:});

dir_info.dirname = dir_info.acro;

end