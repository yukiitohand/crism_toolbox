function crism_init()
    global crism_env_vars
    str = fileread('crismToolbox.json');
    crism_env_vars = jsondecode(str);
    
    check_mkdir(crism_env_vars.localCRISM_PDSrootDir);
    check_mkdir(crism_env_vars.localCATrootDir);
    
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

function [] = check_mkdir(dirpath)
    exist_flg = exist(dirpath,'dir');
    if exist_flg
        %yesno = 1;
    else
        flg = 1;
        while flg
            prompt = sprintf('%s does not exist. Do you want to create?(y/n)',dirpath);
            ow = input(prompt,'s');
            if any(strcmpi(ow,{'y','n'}))
                flg=0;
            else
                fprintf('Input %s is not valid.\n',ow);
            end
        end
        if strcmpi(ow,'n')
            fprintf('No local database will be created.\n');
        elseif strcmpi(ow,'y')
            fprintf('%s is created...\n',dirpath);
        end
    end
end

    