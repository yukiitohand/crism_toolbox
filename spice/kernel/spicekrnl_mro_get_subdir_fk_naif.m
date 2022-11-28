function [subdir] = spicekrnl_mro_get_subdir_fk_naif(spicekrnl_env_vars,dirpath_opt)
% [subdir] = spicekrnl_mro_get_subdir_fk_naif(spicekrnl_env_vars,dirpath_opt)
%  get sub directory path for SPICE fk kernel when
%       spice_krnl_env_vars.fldsys == 'naif'
%  INPUTS
%    spicekrnl_env_vars: struct storing the information of the spice kernel
%    repository.
%    dirpath_opt: char/string
%  OUTPUT
%    subdir: char/string, depends on fldsys
%    

switch upper(dirpath_opt)
    case 'MRO'
        subdir = fullfile(spicekrnl_env_vars.NAIF_MROSPICE_subdir,'fk');
    case 'PDS'
        subdir = fullfile(spicekrnl_env_vars.NAIF_MROSPICE_pds_subdir,'fk');
    otherwise
        error('Undefined dirpath_opt %s',dirpath_opt);
end

end