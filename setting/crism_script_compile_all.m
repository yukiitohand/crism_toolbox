% crism_script_compile_all.m
% Script for compiling all the necessary C/MEX codes
%
% Automatically find the path to crism_toolbox, msl_toolbox, and pds3_toolbox

fpath_self = mfilename('fullpath');
[dirpath_self,filename] = fileparts(fpath_self);

idx_sep = strfind(dirpath_self,'crism_toolbox/setting');
dirpath_toolbox = dirpath_self(1:idx_sep-1);

pds3_toolbox_path  = joinPath(dirpath_toolbox, 'pds3_toolbox/');
crism_toolbox_path = joinPath(dirpath_toolbox, 'crism_toolbox/');
msl_toolbox_path   = joinPath(dirpath_toolbox, 'msl_toolbox/');
spice_toolbox_path = joinPath(dirpath_toolbox, 'spice/');

%% Prior checking if necessary files are accessible.
if ~exist(pds3_toolbox_path,'dir')
    error('pds3_toolbox does not exist. Get at github.com/yukiitohand/pds3_toolbox/');
end

if ~exist(msl_toolbox_path,'dir')
    fprintf('msl_toolbox is not detected.');
    msl_toolbox_exist = true;
else
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
pds3_toolbox_mex_include_path = joinPath(pds3_toolbox_path, 'mex_include');
crism_toolbox_mex_include_path  = joinPath(crism_toolbox_path,  'mex_include');
SpiceUsr_include_path = joinPath(spice_toolbox_path, 'mice/include/');
spice_lib_path = joinPath(spice_toolbox_path,'mice/lib/');

if msl_toolbox_exist
    msl_toolbox_mex_include_path  = joinPath(msl_toolbox_path,  'mex_include');
end

% 
source_filepaths_crism_proj = { ...
    joinPath(crism_toolbox_path,'spice/projection/','cahvor_iaumars_proj_crism2MSLDEM_v6_mex.c')     , ...
    joinPath(crism_toolbox_path,'spice/projection/','crism_combine_FOVap_v2_mex.c')                  , ...
    joinPath(crism_toolbox_path,'spice/projection/','crism_combine_FOVcell_PSF_1expo_v3_mex.c')      , ...
    joinPath(crism_toolbox_path,'spice/projection/','crism_combine_FOVcell_PSF_multiPxl_mex.c')      , ...
    joinPath(crism_toolbox_path,'spice/projection/','crism_gale_get_msldemFOV_scf2_L2_mex.c')        , ...
    joinPath(crism_toolbox_path,'spice/projection/','crism_gale_get_msldemFOVcell_PFF_L2fa2_mex.c')  , ...
    joinPath(crism_toolbox_path,'spice/projection/','crism_get_FOVap_mask_from_lList_crange_mex.c')  , ...
    joinPath(crism_toolbox_path,'spice/projection/','iaumars_get_msldemtUFOVmask_ctr_L2PBK_LL0_M3_4crism_mex.c'), ...
    joinPath(crism_toolbox_path,'spice/projection/mapper/','mapper_create_crismGLTPFFonMSLDEM_mex.c')    ...
};

source_filepaths_crism_proj_spice = { ...
    joinPath(crism_toolbox_path,'spice/projection/','crism_gale_get_lonlatwndw_wRadiusMaxMin_mex.c') ...
};

% MASTCAM <-> CRISM mapper utilities
%  only compiled when msl_toolboxes are installed
source_filepaths_crism_mastcam_mapper = { ...
    joinPath(crism_toolbox_path,'spice/projection/mapper/','mapper_create_crismPFFonMASTCAM_mex.c')    , ...    
    joinPath(crism_toolbox_path,'spice/projection/mapper/','mapper_create_crismGLTPFFonMASTCAM_mex.c') , ...
    joinPath(crism_toolbox_path,'spice/projection/mapper/','mapper_create_mastcam2crism_mex.c') ...
};

switch computer
    case 'MACI64'
        out_dir = joinPath(crism_toolbox_path,'mex_build','./maci64/');
    case 'GLNXA64'
        out_dir = joinPath(crism_toolbox_path,'mex_build','./glnxa64/');
    case 'PCWIN64'
        out_dir = joinPath(crism_toolbox_path,'mex_build','./pcwin64/');
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
        '-outdir',out_dir);
end

% mex files linked to SPICE/MICE
for i=1:length(source_filepaths_crism_proj_spice)
    filepath = source_filepaths_crism_proj_spice{i};
    fprintf('Compiling %s ...\n',filepath);
    mex(filepath, '-R2018a', ['-I' pds3_toolbox_mex_include_path], ...
        ['-I' msl_toolbox_mex_include_path], ...
        ['-I' crism_toolbox_mex_include_path], ...
        ['-I' SpiceUsr_include_path], ...
        joinPath(spice_lib_path,'cspice.a'), ...
        '-lm', ...
        '-outdir',out_dir);
end


if msl_toolbox_exist
    for i=1:length(source_filepaths_crism_mastcam_mapper)
        filepath = source_filepaths_crism_mastcam_mapper{i};
        fprintf('Compiling %s ...\n',filepath);
        mex(filepath, '-R2018a', ['-I' pds3_toolbox_mex_include_path], ...
            ['-I' msl_toolbox_mex_include_path], ...
            ['-I' crism_toolbox_mex_include_path], ...
            '-outdir',out_dir);
    end
end

% If you manually compile mex codes, include the two directories 
%     pds3_toolbox_mex_include_path
%     msl_toolbox_mex_include_path
%     crism_toolbox_mex_include_path
% using -I option.
% Also do not forget to add '-R2018a'

