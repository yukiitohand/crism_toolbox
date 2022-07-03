function [dir_SOURCE_OBS,files_local] = crism_finddirdownload_SOURCE_OBS(basenames_SOURCE_OBS,varargin)
% [dir_SOURCE_OBS,files_local] = crism_finddirdownload_SOURCE_OBS(basenames_SOURCE_OBS,varargin)
%   get local full paths for observation files
%   INPUTS
%    basenames_SOURCE_OBS: struct of basenames, field names are two character 
%                  activity IDs of the files, and their basenames are stored in
%                  the values If multiple files are in the same activity ID, 
%                  then its value becomes a cell of basenames.
%   OUTPUT
%    dir_SOURCE_OBS: same structure as basenames_SOURCE_OBS. 
%                    local full directroy paths are stored.
%    files_local:  same structure as basenamesOBS. all filenames with
%             extensions present locally are listed.
%   OPTIONAL PARAMETERS (passed onto crism_get_dirpath_observation)
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

dir_SOURCE_OBS = [];
files_local = [];

fieldnms_source_obs = fieldnames(basenames_SOURCE_OBS);
for i=1:length(fieldnms_source_obs)
    actID = fieldnms_source_obs{i};
    if iscell(basenames_SOURCE_OBS.(actID))
        for k=1:length(basenames_SOURCE_OBS.(actID))
            basename = basenames_SOURCE_OBS.(actID){k};
            [dir_info,~,files_localk] = crism_get_dirpath_observation(basename,varargin{:});
            if ~isempty(dir_info)
                dir_source = dir_info.dirfullpath_local;
                dir_SOURCE_OBS = addField(dir_SOURCE_OBS,actID,dir_source);
                if k==1 && iscell(files_local)
                    files_local = addField({files_local},actID,files_localk);
                else
                    files_local = addField(files_local,actID,files_localk);
                end
            else
                if k==1
                    dir_SOURCE_OBS = addField(dir_SOURCE_OBS,actID,{''});
                    files_local = addField(files_local,actID,{''});
                else
                    dir_SOURCE_OBS = addField(dir_SOURCE_OBS,actID,'');
                    files_local = addField(files_local,actID,'');
                end
                fprintf('SOURCE OBSERVATION: %s does not exist.\n',basename);
            end
        end
    elseif ischar(basenames_SOURCE_OBS.(actID))
        basename = basenames_SOURCE_OBS.(actID);
        [dir_info,~,files_localk] = crism_get_dirpath_observation(basename,varargin{:});
        if ~isempty(dir_info)
            dir_source = dir_info.dirfullpath_local;
            dir_SOURCE_OBS = addField(dir_SOURCE_OBS,actID,dir_source);
            files_local.(actID)=files_localk;
        else
            dir_SOURCE_OBS = addField(dir_SOURCE_OBS,actID,dir_source);
            files_local.(actID)=files_localk;
            fprintf('SOURCE OBSERVATION: %s does not exist.\n',basename);
        end
    else
        error('Value of the basenames_SOURCE_OBS.(%s) is not valid',actID);
    end
end

end