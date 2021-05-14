function [subdir_remote] = get_subdir_CDR_remote(acro,cdr_folder_type,yyyy_doy)
% [subdir_remote] = get_subdir_CDR_remote(acro,cdr_folder_type,yyyy_doy)
%  get subdir_local that can be used for an input of pds_downloader.m. This
%  is a wrapper function for actually produce subdir, of which is named
%   'get_subdir_CDR_[local_fldsys](acro,cdr_folder_type,yyyy_doy)
%
%  INPUTS
%    acro: two character acronym for the CDR product
%    cdr_folder_type: cdr_folder_type {1,2}
%    yyyy_doy: string, year and day of the year
%  OUTPUT
%    subdir, string, depends on local_fldsys
%    
global crism_env_vars

remote_fldsys = crism_env_vars.remote_fldsys;
get_subdir_CDR_remote_func = str2func(['crism_get_subdir_CDR_' remote_fldsys]);
subdir_remote = get_subdir_CDR_remote_func(acro,cdr_folder_type,yyyy_doy);

end