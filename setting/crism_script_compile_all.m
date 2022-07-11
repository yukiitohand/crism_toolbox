function [] = crism_script_compile_all(varargin)
% crism_script_compile_all.m
% Script for compiling all the necessary C/MEX codes
%
% Automatically find the path to crism_toolbox, msl_toolbox, and pds3_toolbox

mexCompileOpt = {};
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MEXCOMPILEOPT'
                mexCompileOpt = varargin{i+1};
                if ~iscell(mexCompileOpt)
                    mexCompileOpt = {mexCompileOpt};
                end
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

fpath_self = mfilename('fullpath');
[dirpath_self,filename] = fileparts(fpath_self);

idx_sep = strfind(dirpath_self,'setting');
crism_toolbox_path = dirpath_self(1:idx_sep-1);
[dirpath_toolbox] = fileparts(crism_toolbox_path);

pds3_toolbox_path  = fullfile(dirpath_toolbox, 'pds3_toolbox');
% crism_toolbox_path = fullfile(dirpath_toolbox, 'crism_toolbox');
msl_toolbox_path   = fullfile(dirpath_toolbox, 'msl_toolbox');
spice_toolbox_path = fullfile(dirpath_toolbox, 'spice');

%% Prior checking if necessary files are accessible.
if ~exist(pds3_toolbox_path,'dir')
    error('pds3_toolbox does not exist. Get at github.com/yukiitohand/pds3_toolbox/');
end

if exist(msl_toolbox_path,'dir')
    msl_toolbox_exist = true;
else
    fprintf('msl_toolbox is not detected.');
    msl_toolbox_exist = false;
end

if ~exist(spice_toolbox_path,'dir')
    error(sprintf(['SPICE/MICE does not seem to be detected. Download'     '\n'...
           ' mice.tar.Z and importMice.csh' '\n'...
           ' from'                          '\n'...
           '   https://naif.jpl.nasa.gov/naif/toolkit_MATLAB.html' '\n'...
           sprintf(' into %s',spice_toolbox_path)                  '\n'...
           ' and run' '\n'...
           ' /bin/csh -f importMice.csh' '\n'...
          ]));
end

% Sorry, these functions are currently not supported for MATLAB 9.3 or
% earlier. These requires another 
if verLessThan('matlab','9.4')
    error('You need MATLAB version 9.4 or newer');
end

%% Set source code paths and the output directory path.
pds3_toolbox_mex_include_path  = fullfile(pds3_toolbox_path, 'mex_include');
crism_toolbox_mex_include_path = fullfile(crism_toolbox_path,'mex_include');
SpiceUsr_include_path = fullfile(spice_toolbox_path,'mice','include');
spice_lib_path = fullfile(spice_toolbox_path,'mice','lib');

if msl_toolbox_exist
    msl_toolbox_mex_include_path  = fullfile(msl_toolbox_path,  'mex_include');
end

% 
source_filepaths_crism_proj = { ...
    fullfile(crism_toolbox_path,'spice','projection','cahvor_iaumars_proj_crism2MSLDEM_v6_mex.c')     , ...
    fullfile(crism_toolbox_path,'spice','projection','crism_combine_FOVap_v2_mex.c')                  , ...
    fullfile(crism_toolbox_path,'spice','projection','crism_combine_FOVcell_PSF_1expo_v3_mex.c')      , ...
    fullfile(crism_toolbox_path,'spice','projection','crism_combine_FOVcell_PSF_multiPxl_mex.c')      , ...
    fullfile(crism_toolbox_path,'spice','projection','crism_gale_get_msldemFOV_scf2_L2_mex.c')        , ...
    fullfile(crism_toolbox_path,'spice','projection','crism_gale_get_msldemFOVcell_PFF_L2fa2_mex.c')  , ...
    fullfile(crism_toolbox_path,'spice','projection','crism_get_FOVap_mask_from_lList_crange_mex.c')  , ...
    fullfile(crism_toolbox_path,'spice','projection','iaumars_get_msldemtUFOVmask_ctr_L2PBK_LL0_M3_4crism_mex.c'), ...
    fullfile(crism_toolbox_path,'spice','projection','mapper','mapper_create_crismGLTPFFonMSLDEM_mex.c')    ...
};

source_filepaths_crism_proj_spice = { ...
    fullfile(crism_toolbox_path,'spice','projection','crism_gale_get_lonlatwndw_wRadiusMaxMin_mex.c') ...
};

source_filepaths_crism_misc = { ...
    fullfile(crism_toolbox_path,'util','vs','crism_vscor_patch_vs_artifact_v2_internal_mex.c') ...
};

% MASTCAM <-> CRISM mapper utilities
%  only compiled when msl_toolboxes are installed
source_filepaths_crism_mastcam_mapper = { ...
    fullfile(crism_toolbox_path,'spice','projection','mapper','mapper_create_crismPFFonMASTCAM_mex.c')    , ...    
    fullfile(crism_toolbox_path,'spice','projection','mapper','mapper_create_crismGLTPFFonMASTCAM_mex.c') , ...
    fullfile(crism_toolbox_path,'spice','projection','mapper','mapper_create_mastcam2crism_mex.c') ...
};

switch computer
    case 'MACI64'
        out_dir = fullfile(crism_toolbox_path,'mex_build','maci64');
    case 'GLNXA64'
        out_dir = fullfile(crism_toolbox_path,'mex_build','glnxa64');
    case 'PCWIN64'
        out_dir = fullfile(crism_toolbox_path,'mex_build','pcwin64');
    otherwise
        error('Undefined computer type %s.\n',computer);
end

if ~exist(out_dir,'dir')
    mkdir(out_dir);
end

%% Compile files one by one
for i=1:length(source_filepaths_crism_proj)
    filepath = source_filepaths_crism_proj{i};
    fprintf('Compiling %s ...\n',filepath);
    mex(filepath, '-R2018a', ['-I' pds3_toolbox_mex_include_path], ...
        ['-I' msl_toolbox_mex_include_path], ...
        ['-I' crism_toolbox_mex_include_path], ...
        mexCompileOpt{:}, ...
        '-outdir',out_dir);
end

for i=1:length(source_filepaths_crism_misc)
    filepath = source_filepaths_crism_misc{i};
    fprintf('Compiling %s ...\n',filepath);
    mex(filepath, '-R2018a', ['-I' pds3_toolbox_mex_include_path], ...
        ['-I' crism_toolbox_mex_include_path], ...
        ['-I' crism_toolbox_mex_include_path], ...
        mexCompileOpt{:}, ...
        '-outdir',out_dir);
end




if msl_toolbox_exist
    % mex files linked to SPICE/MICE
    for i=1:length(source_filepaths_crism_proj_spice)
        filepath = source_filepaths_crism_proj_spice{i};
        fprintf('Compiling %s ...\n',filepath);
        mex(filepath, '-R2018a', ['-I' pds3_toolbox_mex_include_path], ...
            ['-I' msl_toolbox_mex_include_path], ...
            ['-I' crism_toolbox_mex_include_path], ...
            ['-I' SpiceUsr_include_path], ...
            fullfile(spice_lib_path,'cspice.a'), ...
            mexCompileOpt{:}, ...
            '-lm', ...
            '-outdir',out_dir);
    end
    for i=1:length(source_filepaths_crism_mastcam_mapper)
        filepath = source_filepaths_crism_mastcam_mapper{i};
        fprintf('Compiling %s ...\n',filepath);
        mex(filepath, '-R2018a', ['-I' pds3_toolbox_mex_include_path], ...
            ['-I' msl_toolbox_mex_include_path], ...
            ['-I' crism_toolbox_mex_include_path], ...
            mexCompileOpt{:}, ...
            '-outdir',out_dir);
    end
end

end
