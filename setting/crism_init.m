function crism_init(varargin)
% Load environmental variables for using crism_toolbox
% The variables stored in a global variable crism_env_vars
% USAGE
% >> crism_init
% >> crism_init crismToolbox.json
%
% 
    global crism_env_vars

    if isempty(varargin)
        crism_toolbox_json_fname = 'crismToolbox.json';
    elseif length(varargin)==1
        crism_toolbox_json_fname = varargin{1};
    else
        error('Too many input parameters.');
    end

    str = fileread(crism_toolbox_json_fname);
    crism_env_vars = jsondecode(str);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Backward compatibility
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % no_remote is determined based on the presence of the field 
    % 'remote_fldsys', if it is not defined in the json file.
    if ~isfield(crism_env_vars,'no_remote')
        if isfield(crism_env_vars,'remote_fldsys')
            crism_env_vars.no_remote = false;
        else
            crism_env_vars.no_remote = true;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [yesno,doyoucreate] = check_mkdir(crism_env_vars.localCRISM_PDSrootDir);
    switch lower(doyoucreate)
        case 'yes'
            [status] = mkdir(crism_env_vars.localCRISM_PDSrootDir);
            if status
                fprintf('%s is created...\n',crism_env_vars.localCRISM_PDSrootDir);
                [yesno777] = doyouwantto('change the permission to 777', '');
                if yesno777
                    chmod777(crism_env_vars.localCRISM_PDSrootDir,1);
                end
            else
                error('Failed to create %s', crism_env_vars.localCRISM_PDSrootDir);
            end
        case 'no'
            if strcmpi(yesno,'no')
                fprintf('No local database will be created. ');
                fprintf('Functionality of crism_toolbox may be limited.\n');
            end
        otherwise
            error('"doyoucreate" should be either of "yes" or "no".');
            
    end
    
    if exist(crism_env_vars.localCATrootDir,'dir')
    else
        fprintf('localCATrootDir is not configured. ');
        fprintf('Functionality of crism_toolbox may be limited.\n');
    end
    
    crism_env_vars.url_local_root = crism_env_vars.([crism_env_vars.local_fldsys '_URL']);
    crism_env_vars.url_local_root = fullfile(crism_env_vars.url_local_root);

    if crism_env_vars.no_remote
        if isfield(crism_env_vars,'remote_fldsys')
            fprintf('remote_fldsys is defined, but will not be used because no_remote=1\n');
        end
    else
        % remote_protocol is set to 'http' if not defined in the json file.
        if ~isfield(crism_env_vars,'remote_protocol')
            crism_env_vars.remote_protocol = 'http';
        end
        % "remoteCRISM_PDSrootDir" is set to empty char if not defined
        if ~isfield(crism_env_vars,'remoteCRISM_PDSrootDir')
            crism_env_vars.remoteCRISM_PDSrootDir = '';
        end
        if isfield(crism_env_vars,'remote_fldsys')
            crism_env_vars.url_remote_root = crism_env_vars.([crism_env_vars.remote_fldsys '_URL']);
            crism_env_vars.url_remote_root = crism_swap_to_remote_path(crism_env_vars.url_remote_root);
        else
            error('Define remote_fldsys is the json file, since no_remote=0\n');
        end
    end
    
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
        fprintf('%s is missing\n',fullfile(localCRISM_PDSrootDir,crism_pds_archiveURL,'edr','EDR','LUT_OBSID2YYYY_DOY.mat'));
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

    