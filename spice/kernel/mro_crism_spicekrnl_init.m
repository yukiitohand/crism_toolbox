function mro_crism_spicekrnl_init(varargin)
% Load environmental variables for using SPICE kernel for 
% The variables stored in a global variable mro_crism_spicekrnl_env_vars
% USAGE
% >> mro_crism_spicekrnl_init
% >> mro_crism_spicekrnl_init mro_crism_spicekrnl_env.json
%
% 
global mro_crism_spicekrnl_env_vars

if isempty(varargin)
    spickrnl_env_json_fname = 'mro_crism_spicekrnl_env.json';
elseif length(varargin)==1
    spickrnl_env_json_fname = varargin{1};
else
    error('Too many input parameters.');
end

str = fileread(spickrnl_env_json_fname);
mro_crism_spicekrnl_env_vars = jsondecode(str);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Backward compatibility
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% no_remote is set to true, if it is not defined in the json file.
if ~isfield(mro_crism_spicekrnl_env_vars,'no_remote')
    mro_crism_spicekrnl_env_vars.no_remote = true;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mro_crism_spicekrnl_env_vars.url_local_root = mro_crism_spicekrnl_env_vars.([mro_crism_spicekrnl_env_vars.fldsys '_URL']);
mro_crism_spicekrnl_env_vars.url_local_root = fullfile(mro_crism_spicekrnl_env_vars.url_local_root);

if mro_crism_spicekrnl_env_vars.no_remote
    if ~exist( ...
            fullfile(mro_crism_spicekrnl_env_vars.local_SPICEkernel_archive_rootDir, ...
            mro_crism_spicekrnl_env_vars.url_local_root),'dir')
        error('%s does not exist.', mro_crism_spicekrnl_env_vars.local_SPICEkernel_archive_rootDir);
    end
else
    [yesno,doyoucreate] = check_mkdir(mro_crism_spicekrnl_env_vars.local_SPICEkernel_archive_rootDir);
    switch lower(doyoucreate)
        case 'yes'
            [status] = mkdir(mro_crism_spicekrnl_env_vars.local_SPICEkernel_archive_rootDir);
            if status
                fprintf('%s is created...\n',mro_crism_spicekrnl_env_vars.local_SPICEkernel_archive_rootDir);
                % [yesno777] = doyouwantto('change the permission to 777', '');
                % if yesno777
                %     chmod777(spicekrnl_env_vars.localCRISM_PDSrootDir,1);
                % end
            else
                error('Failed to create %s', mro_crism_spicekrnl_env_vars.local_SPICEkernel_archive_rootDir);
            end
        case 'no'
            if strcmpi(yesno,'no')
                fprintf('No local database will be created. ');
            end
        otherwise
            error('"doyoucreate" should be either of "yes" or "no".');    
    end

    if ~isfield(mro_crism_spicekrnl_env_vars,'remote_protocol')
        mro_crism_spicekrnl_env_vars.remote_protocol = 'https';
    end
    mro_crism_spicekrnl_env_vars.url_remote_root = mro_crism_spicekrnl_env_vars.([mro_crism_spicekrnl_env_vars.fldsys '_URL']);
    mro_crism_spicekrnl_env_vars.url_remote_root = crism_swap_to_remote_path(mro_crism_spicekrnl_env_vars.url_remote_root);     
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

    