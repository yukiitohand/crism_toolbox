function crism_init()
    global crism_env_vars
    str = fileread('crismToolbox.json');
    crism_env_vars = jsondecode(str);
    
    [yesno,doyoucreate] = check_mkdir(crism_env_vars.localCRISM_PDSrootDir);
    switch lower(doyoucreate)
        case 'yes'
            mkdir(crism_env_vars.localCRISM_PDSrootDir);
            fprintf('%s is created...\n',crism_env_vars.localCRISM_PDSrootDir);
        case 'no'
            if strcmpi(yesno,'no')
                fprintf('No local database will be created. ');
                fprintf('Functionality of crism_toolbox may be limited.\n');
            end
        otherwise
            error('"doyoucreate" should be either of "yes" or "no".');
            
    end
    
    if exist(crism_env_vars.localCATrootDir)
    else
        fprintf('localCATrootDir is not configured. ');
        fprintf('Functionality of crism_toolbox may be limited.\n');
    end
    
    crism_env_vars.url_local_root = crism_env_vars.([crism_env_vars.local_fldsys '_URL']);
    crism_env_vars.url_remote_root = crism_env_vars.([crism_env_vars.remote_fldsys '_URL']);
    
    global CRISM_INDEX_OBS_CLASS_TYPE
    global CRISM_INDEX_OBS_ID
    global CRISM_INDEX_YYYY
    global CRISM_INDEX_DOY
    if exist('CRISM_LUT_OBSID2YYYY_DOY_v2.mat','file')
        lut_val = load('CRISM_LUT_OBSID2YYYY_DOY_v2.mat');
        CRISM_INDEX_OBS_CLASS_TYPE = lut_val.CRISM_INDEX_OBS_CLASS_TYPE;
        CRISM_INDEX_OBS_ID = lut_val.CRISM_INDEX_OBS_ID;
        CRISM_INDEX_YYYY = lut_val.CRISM_INDEX_YYYY;
        CRISM_INDEX_DOY = lut_val.CRISM_INDEX_DOY;
    else
        fprintf('%s is missing\n',joinPath(localCRISM_PDSrootDir,crism_pds_archiveURL,'edr/EDR/LUT_OBSID2YYYY_DOY.mat'));
    end

end

function [yesno,doyoucreate] = check_mkdir(dirpath)
    exist_flg = exist(dirpath,'dir');
    if exist_flg
        yesno = 'yes'; doyoucreate = 'no';
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
            yesno = 'yes';  doyoucreate = 'no';
        elseif strcmpi(ow,'y')
            yesno = 'no';  doyoucreate = 'yes';
        end
    end
end

    