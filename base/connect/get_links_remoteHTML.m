function [lnks] = get_links_remoteHTML(html)
% [lnks] = get_links_remoteHTML(html)
%   match files in the html files obtained at the remote server
% Input
%   html: html text
% Output
%   lnks: struct having two fields
%     hyperlink: hyperlink, only the basename (or with extention) is read.
%                no slash will be attached
%     type     : type of the content at the link {'PARENTDIR','To Parent Directory','dir'}
%                if other types are specified, it will be regarded as a
%                file.
% The input will be directly passed to a function
%         get_links_remoteHTML_[remote_fldsys](html)

global crism_env_vars
remote_fldsys = crism_env_vars.remote_fldsys;

func = str2func(['get_links_remoteHTML_',remote_fldsys]);
lnks = func(html);

end