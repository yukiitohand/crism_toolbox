function [remote_path] = crism_swap_to_remote_path(local_path)
% [remote_path] = crism_swap_to_remote_path(local_path)
%   Convert any path (absolute/relative) for the local machine to one for
%   remote access.
%   For now, this function only does something for Windows if
%   "remote_protocol" is set to "http".
%   Backslash '\' (a default seperator for Windows) is converted to Slash '/'
%
% Inputs
%  local_path: local file/directory path
% Output
%  remote_path: remote file/directory path

global crism_env_vars

if ~crism_env_vars.no_remote && strcmpi(filesep,'\') && strcmpi(crism_env_vars.remote_protocol,'http')
    remote_path = strrep(local_path,'\','/');
else
    remote_path = local_path;
end


end
