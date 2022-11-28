function [subdir] = spicekrnl_mro_get_subdir_spk_sc_naif(spicekrnl_env_vars,dirpath_opt)
% [subdir] = spicekrnl_mro_get_subdir_spk_sc_naif(spicekrnl_env_vars,dirpath_opt)
%  get sub directory path for SPICE spk sc kernel when
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
        subdir = fullfile(spicekrnl_env_vars.NAIF_MROSPICE_subdir,'spk');
    case 'PDS'
        subdir = fullfile(spicekrnl_env_vars.NAIF_MROSPICE_pds_subdir,'spk');
    otherwise
        error('Undefined dirpath_opt %s',dirpath_opt);
end

end