function [subdir] = spicekrnl_mro_get_subdir_ck_crism(spicekrnl_env_vars,dirpath_opt)
% [subdir] = spicekrnl_mro_get_subdir_ck_crism(spicekrnl_env_vars,dirpath_opt)
%  get sub directory path for SPICE ck crism kernel.
%   spicekrnl_mro_get_subdir_ck_crism_[fldsys](spicekrnl_env_vars,dirpath_opt)
%
%  INPUTS
%    spicekrnl_env_vars: struct storing the information of the spice kernel
%    repository.
%    dirpath_opt: char/string
%  OUTPUT
%    subdir: char/string, depends on fldsys
%    

fldsys = spicekrnl_env_vars.fldsys;
get_subdir_func = str2func(['spicekrnl_mro_get_subdir_ck_crism_' fldsys]);
subdir = get_subdir_func(spicekrnl_env_vars,dirpath_opt);

end
