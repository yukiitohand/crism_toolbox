function [dir_SOURCE_OBS] = finddirdownload_SOURCE_OBS(basenames_SOURCE_OBS,varargin)
% [dir_SOURCE_OBS] = finddirdownload_SOURCE_OBS(basenames_SOURCE_OBS,varargin)
%   get local full paths for observation files
%   INPUTS
%    basenames_SOURCE_OBS: struct of basenames, field names are two character 
%                  activity IDs of the files, and their basenames are stored in
%                  the values If multiple files are in the same activity ID, 
%                  then its value becomes a cell of basenames.
%   OUTPUT
%    dir_SOURCE_OBS: same structure as basenames_SOURCE_OBS. 
%                    local full directroy paths are stored.
%   OPTIONAL PARAMETERS (passed onto get_dirpath_observation)
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false

dir_SOURCE_OBS = [];

fieldnms_source_obs = fieldnames(basenames_SOURCE_OBS);
for i=1:length(fieldnms_source_obs)
    actID = fieldnms_source_obs{i};
    if iscell(basenames_SOURCE_OBS.(actID))
        for k=1:length(basenames_SOURCE_OBS.(actID))
            basename = basenames_SOURCE_OBS.(actID){k};
            [dir_source] = get_dirpath_observation(basename,varargin{:});
            dir_SOURCE_OBS = addField(dir_SOURCE_OBS,actID,dir_source); 
        end
    elseif ischar(basenames_SOURCE_OBS.(actID))
        basename = basenames_SOURCE_OBS.(actID);
        [dir_source] = get_dirpath_observation(basename,varargin{:});
        dir_SOURCE_OBS = addField(dir_SOURCE_OBS,actID,dir_source);  
    else
        error('Value of the basenames_SOURCE_OBS.(%s) is not valid',actID);
    end
end

end