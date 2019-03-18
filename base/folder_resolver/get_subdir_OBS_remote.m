function [subdir_remote] = get_subdir_OBS_remote(yyyy_doy,base_dir,data_type)
% [subdir_remote] = get_subdir_OBS_remote(yyyy_doy,base_dir,data_type)
%  get subdir_remote that can be used for an input of pds_downloader.m. 
%  This is a wrapper function for actually produce subdir, of which is 
%  named
%   'get_subdir_OBS_[remote_fldsys](yyyy_doy,base_dir,data_type)
%
%  INPUTS
%    yyyy_doy: string, year and day of the year
%    base_dir: string, subfolder following after yyyy_doy
%    data_type: data type {'ter','mtr','trr','ddr','edr'}
%  OUTPUT
%    subdir, string, depends on remote_fldsys
%    

global crism_env_vars

remote_fldsys = crism_env_vars.remote_fldsys;
get_subdir_OBS_remote_func = str2func(['get_subdir_OBS_' remote_fldsys]);
subdir_remote = get_subdir_OBS_remote_func(yyyy_doy,base_dir,data_type);


end