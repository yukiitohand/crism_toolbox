function [subdir_local] = get_subdir_CDR_local(acro,cdr_folder_type,yyyy_doy)
% [subdir_local] = get_subdir_CDR_local(acro,cdr_folder_type,yyyy_doy)
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

local_fldsys = crism_env_vars.local_fldsys;
get_subdir_CDR_local_func = str2func(['get_subdir_CDR_' local_fldsys]);
subdir_local = get_subdir_CDR_local_func(acro,cdr_folder_type,yyyy_doy);

end