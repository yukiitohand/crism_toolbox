function crism_setup()
    global crism_env_vars
    str = fileread('crismToolbox.json');
    crism_env_vars = jsondecode(str);
    
    crism_env_vars.url_local_root = crism_env_vars.([crism_env_vars.local_fldsys '_URL']);
    crism_env_vars.url_remote_root = crism_env_vars.([crism_env_vars.remote_fldsys '_URL']);
    
    global LUT_OBSID2YYYY_DOY
    if exist('LUT_OBSID2YYYY_DOY.mat','file')
        tmp = load('LUT_OBSID2YYYY_DOY.mat');
        LUT_OBSID2YYYY_DOY = tmp.LUT_OBSID2YYYY_DOY;
        clear tmp;
    else
        fprintf('%s is missing\n',joinPath(localCRISM_PDSrootDir,crism_pds_archiveURL,'edr/EDR/LUT_OBSID2YYYY_DOY.mat'));
    end

end