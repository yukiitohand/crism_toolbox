function [subpath] = get_crism_pds_mro_path(yyyy_doy,range_mat,root_subpath,folder_func)
% [subpath] = get_crism_pds_mro_path(yyyy_doy,range_mat,root_subpath,folder_func)
%  get remote path using yyyy_doy
%
% Inputs
%  yyyy_doy: year and day of the year information, string
%  range_mat: nx2 array, elements are datetime objects.
%             each row, the first element is the beginning of the epoch and
%             the second one is the end date of the epoch.
%  root_subpath: string, subpath
%  folder_func: funciton pointer to produce the folder name. epoch id is the
%               only parameter to be used.
% Output
%  subpath: subpath to the folder 
%   something like
%   'mro-m-crism-3-rdr-targeted-v1/mrocr_2104/...'
%   How deep the folder depends on the function folder_func

[yyyy,doy] = dec_yyyy_doy(yyyy_doy);
[MM,dd] = doy2MMDD(doy,yyyy);
dt = datetime(yyyy,MM,dd);

grp = find(and(dt>=range_mat(:,1),dt<=range_mat(:,2)));

if isempty(grp)
    % fprintf('the specified yyyy_doy does not exist.\n');
    subpath = '';
else
    folder_name = folder_func(grp);
    subpath = joinPath(root_subpath,folder_name);
end



end
