function [diropt] = mro_crism_spicekrnl_get_diropt_default()

global mro_crism_spicekrnl_env_vars
if isempty(mro_crism_spicekrnl_env_vars)
    error('Perform "spicekrnl_init" first.');
end

fldsys = mro_crism_spicekrnl_env_vars.fldsys;
get_diropt_func = str2func(['mro_crism_spicekrnl_get_diropt_default_' fldsys]);
diropt = get_diropt_func();

end
