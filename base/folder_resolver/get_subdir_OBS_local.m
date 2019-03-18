function [subdir_local] = get_subdir_OBS_local(yyyy_doy,base_dir,data_type)
% [subdir_loca] = get_subdir_OBS_local(yyyy_doy,base_dir,data_type)
%  get subdir_local that can be used for an input of pds_downloader.m. This
%  is a wrapper function for actually produce subdir, of which is named
%   'get_subdir_OBS_[local_fldsys](yyyy_doy,base_dir,data_type)
%
%  INPUTS
%    yyyy_doy: string, year and day of the year
%    base_dir: string, subfolder following after yyyy_doy
%    data_type: data type {'ter','mtr','trr','ddr','edr'}
%  OUTPUT
%    subdir, string, depends on local_fldsys
%    
global crism_env_vars

local_fldsys = crism_env_vars.local_fldsys;
get_subdir_OBS_local_func = str2func(['get_subdir_OBS_' local_fldsys]);
subdir_local = get_subdir_OBS_local_func(yyyy_doy,base_dir,data_type);


end