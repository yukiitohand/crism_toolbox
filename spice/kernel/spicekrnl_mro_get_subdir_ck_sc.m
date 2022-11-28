function [subdir] = spicekrnl_mro_get_subdir_ck_sc(spicekrnl_env_vars,dirpath_opt)
% [subdir] = spicekrnl_mro_get_subdir_ck_sc(spicekrnl_env_vars,dirpath_opt)
%  get sub directory path for SPICE ck sc kernel.
%   spicekrnl_mro_get_subdir_ck_sc_[fldsys](spicekrnl_env_vars,dirpath_opt)
%
%  INPUTS
%    spicekrnl_env_vars: struct storing the information of the spice kernel
%    repository.
%    dirpath_opt: char/string
%  OUTPUT
%    subdir: char/string, depends on fldsys
%    

fldsys = spicekrnl_env_vars.fldsys;
get_subdir_func = str2func(['spicekrnl_mro_get_subdir_ck_sc_' fldsys]);
subdir = get_subdir_func(spicekrnl_env_vars,dirpath_opt);

end
