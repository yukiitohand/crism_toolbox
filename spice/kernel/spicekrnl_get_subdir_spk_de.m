function [subdir] = spicekrnl_get_subdir_spk_de(fldsys,dirpath_opt)


%
global spicekrnl_env_vars
switch lower(fldsys)
    case 'crismlnx'
        switch upper(dirpath_opt)
            case 'CRISM'
                subdir  = fullfile(spicekrnl_env_vars.CRISMLNX_CRISM_subdir,'spk');
            case 'NAIF'
                subdir  = fullfile(spicekrnl_env_vars.CRISMLNX_CRISM_subdir,'spk');
            otherwise
                error('Undefined dirpath_opt %s',dirpath_opt);
        end
    case 'naif'
        switch upper(dirpath_opt)
            case 'PDS'
                subdir = fullfile(spicekrnl_env_vars.NAIF_MROSPICE_pds_subdir,'spk');
            case 'GENERIC'
                subdir = fullfile(spicekrnl_env_vars.NAIF_GENERICSPICE_subdir,'spk','planets');
            case 'GENERIC_OLD'
                subdir = fullfile(spicekrnl_env_vars.NAIF_MROSPICE_subdir,'spk','planets','a_old_versions');
            otherwise
                error('Undefined dirpath_opt %s',dirpath_opt);
        end

end

end
