function [subdir] = spicekrnl_get_subdir_fk(fldsys,dirpath_opt)


global spicekrnl_env_vars
switch lower(fldsys)
    case 'crismlnx'
        switch upper(dirpath_opt)
            case 'CRISM'
                subdir  = fullfile(spicekrnl_env_vars.CRISMLNX_CRISM_subdir,'fk');
            case 'NAIF'
                subdir  = fullfile(spicekrnl_env_vars.CRISMLNX_NAIF_subdir,'fk');
            otherwise
                error('Undefined dirpath_opt %s',dirpath_opt);
        end
    case 'naif'
        switch upper(dirpath_opt)
            case 'MRO'
                subdir = fullfile(spicekrnl_env_vars.NAIF_MROSPICE_subdir,'fk');
            case 'PDS'
                subdir = fullfile(spicekrnl_env_vars.NAIF_MROSPICE_pds_subdir,'fk');
            otherwise
                error('Undefined dirpath_opt %s',dirpath_opt);
        end

end

end
