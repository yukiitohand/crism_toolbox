function [crismPFFonMASTCAMObj] = crism_get_PFFonMASTCAM(crismPFFonMSLDEMobj,MSTproj,varargin)
% [crismPFFonMASTCAMObj] = crism_get_PFFonMASTCAM(crismPFFonMSLDEMobj,MSTproj,varargin)
%  Create a crism -> mastcam map projection.
% INPUTS
%   crismPFFonMSLDEMobj: class object of CRISMPFFonMSLDEM
%   MSTproj : MASTCAMCameraProjectionMSLDEM_v2
% OUTPUTS
%   crismPFFonMASTCAMObj: class object of CRISMPFFonMASTCAM
% OPTIONAL Parameters
%    'CACHE_DIRPATH': 
%       (default) msl_env_vars.dirpath_cache
%    'SAVE_FILE': 
%       (default) 1
%    'FORCE': boolean, whether to process forcefully
%       (default) 0
%    {'LOAD_CACHE_IFEXIST','LCIE'}
%       (default) 1
%
%

pdir_cache = '/Volumes/LaCie5TB/data/crism2MSLDEMprojection/';
save_file = true;
force = false;
load_cache_ifexist = true;
cache_vr = ''; % {'v0','v1'}

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            % ## I/O OPTIONS #---------------------------------------------
            case 'CACHE_DIRPATH'
                pdir_cache = varargin{i+1};
                validateattributes(pdir_cache,{'char'},{},mfilename,'CACHE_DIRPATH');
            case 'SAVE_FILE'
                save_file = varargin{i+1};
                validateattributes(save_file,{'numeric','logical'},{'binary'},mfilename,'SAVE_FILE');
            case 'FORCE'
                force = varargin{i+1};
                validateattributes(force,{'numeric','logical'},{'binary'},mfilename,'FORCE');
            case {'LOAD_CACHE_IFEXIST','LCIE'}
                load_cache_ifexist = varargin{i+1};
                validateattributes(load_cache_ifexist,{'numeric','logical'}, ...
                    {'binary'},mfilename,'LOAD_CACHE_IFEXIST');
            case {'CACHE_VER','CACHE_VERSION'}
                cache_vr = varargin{i+1};
                validateattributes(cache_vr,{'char'},{},mfilename,'CACHE_VERSION');
                
            % ## PROCESSING OPTIONS #--------------------------------------
            case {'VARARGIN_PROCESS'}
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

if isempty(cache_vr)
   error('Please enter cache version with the option "CACHE_VER" or "CACHE_VERSION".'); 
end

%
validateattributes(crismPFFonMSLDEMobj, ...
    {'CRISMPFFonMSLDEM'},{},mfilename,'crismPFFonMSLDEMobj');
validateattributes(MSTproj, ...
    {'MASTCAMCameraProjectionMSLDEM_v2'},{},mfilename,'MSTproj');

%%
cache_dirname = '';

[targetID] = MSTproj.identifier;
[sourceID] = crismPFFonMSLDEMobj.basename_com;

dirpath_cache = joinPath(pdir_cache,cache_dirname);
if ~exist(dirpath_cache,'dir')
    mkdir(dirpath_cache);
end

basename_pffonmst = sprintf('%s_%s_PFF_%s',sourceID,targetID,cache_vr);
pffonmst_filepath = joinPath(dirpath_cache,[basename_pffonmst '.mat']);


% Evaluate to perform the 
[flg_reproc] = doyouwanttoprocess({pffonmst_filepath}, ...
    force,load_cache_ifexist);

if flg_reproc
    % Mask invisible pixels
    tic;
    [crismFOVcell_onmstimg,crismFOV_sofst_onmstimg,crismFOV_lofst_onmstimg, ...
        crismFOV_smpls_onmstimg,crismFOV_lines_onmstimg] ...
        = mapper_create_crismPFFonMASTCAM_mex(  ...
            crismPFFonMSLDEMobj.basename_com  , ... 0
            crismPFFonMSLDEMobj.dirpath       , ... 1
            crismPFFonMSLDEMobj.sample_offset , ... 2
            crismPFFonMSLDEMobj.line_offset   , ... 3
            crismPFFonMSLDEMobj.samples       , ... 4
            crismPFFonMSLDEMobj.lines         , ... 5
            MSTproj.mapper.msldemc2mastcam_mat     , ... 6
            MSTproj.mapper.mapcell_msldemc2mastcam , ... 7
            MSTproj.mapper.msldemc_chdr              ... 8
        );
    toc;
    
    if save_file
        save(pffonmst_filepath,'crismFOVcell_onmstimg', ...
            'crismFOV_sofst_onmstimg','crismFOV_lofst_onmstimg', ...
            'crismFOV_smpls_onmstimg','crismFOV_lines_onmstimg', ...
            'sourceID','targetID');
    end
else
    load(pffonmst_filepath,'crismFOVcell_onmstimg', ...
            'crismFOV_sofst_onmstimg','crismFOV_lofst_onmstimg', ...
            'crismFOV_smpls_onmstimg','crismFOV_lines_onmstimg', ...
            'sourceID','targetID');
end

crismPFFonMASTCAMObj = CRISMPFFonMASTCAM('','');
crismPFFonMASTCAMObj.basename = basename_pffonmst;
crismPFFonMASTCAMObj.dirpath  = dirpath_cache;
crismPFFonMASTCAMObj.PFFcell  = crismFOVcell_onmstimg;
crismPFFonMASTCAMObj.sample_offset = crismFOV_sofst_onmstimg;
crismPFFonMASTCAMObj.line_offset   = crismFOV_lofst_onmstimg;
crismPFFonMASTCAMObj.samples = crismFOV_smpls_onmstimg;
crismPFFonMASTCAMObj.lines   = crismFOV_lines_onmstimg;
crismPFFonMASTCAMObj.sourceID = sourceID;
crismPFFonMASTCAMObj.targetID = targetID;


%%


end