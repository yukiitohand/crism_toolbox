function [] = crism_startup_addpath()
%-------------------------------------------------------------------------%
% % Automatically find the path to toolboxes
fpath_self = mfilename('fullpath');
[dirpath_self,filename] = fileparts(fpath_self);

mtch = regexpi(dirpath_self,'(?<parent_dirpath>.*)/crism_toolbox[/]{0,1}','names');
toolbox_root_dir = mtch.parent_dirpath;


%-------------------------------------------------------------------------%
% name of the directory of each toolbox
base_toolbox_dirname          = 'base';
envi_toolbox_dirname          = 'envi';
pds3_toolbox_dirname          = 'pds3_toolbox';
crism_toolbox_dirname         = 'crism_toolbox';
spice_dirname                 = 'spice';

%-------------------------------------------------------------------------%
pathCell = strsplit(path, pathsep);

%-------------------------------------------------------------------------%
%%
% base toolbox
base_toolbox_dir = [toolbox_root_dir '/' base_toolbox_dirname '/'];
addpath(base_toolbox_dir);
% joinPath in base toolbox will be used in the following. "base" toolbox
% need to be loaded first. base/joinPath.m automatically determine the
% presence of trailing slash, so you do not need to worry it.
if exist(base_toolbox_dir,'dir')
    if ~check_path_exist(base_toolbox_dir, pathCell)
        addpath(base_toolbox_dir);
    end
else
    warning([ ...
        'base toolbox is not detected. Download from' '\n' ...
        '   https://github.com/yukiitohand/base/'
        ]);
end

%%
% envi toolbox
envi_toolbox_dir = joinPath(toolbox_root_dir, envi_toolbox_dirname);

if exist(envi_toolbox_dir,'dir')
    if ~check_path_exist(envi_toolbox_dir, pathCell)
        run(joinPath(envi_toolbox_dir,'envi_startup_addpath'));
    end
else
    warning([ ...
        'envi toolbox is not detected. Download from' '\n' ...
        '   https://github.com/yukiitohand/envi/'
        ]);
end

%%
pds3_toolbox_dir = joinPath(toolbox_root_dir, pds3_toolbox_dirname);

if exist(pds3_toolbox_dir,'dir')
    if ~check_path_exist(pds3_toolbox_dir, pathCell)
        run(joinPath(pds3_toolbox_dir,'pds3_startup_addpath'));
    end
else
    warning([ ...
        'pds3_toolbox is not detected. Download from' '\n' ...
        '   https://github.com/yukiitohand/pds3_toolbox/'
        ]);
end

%%
% crism_toolbox
crism_toolbox_dir = joinPath(toolbox_root_dir, crism_toolbox_dirname);
if ~check_path_exist(crism_toolbox_dir, pathCell)
    addpath( ...
        crism_toolbox_dir                                      , ...
        joinPath(crism_toolbox_dir,'base/')                    , ...
        joinPath(crism_toolbox_dir,'base/atf_util/')           , ...
        joinPath(crism_toolbox_dir,'base/basename_util/')      , ...
        joinPath(crism_toolbox_dir,'base/connect/')            , ...
        joinPath(crism_toolbox_dir,'base/folder_resolver/')    , ...
        joinPath(crism_toolbox_dir,'base/lbl_util/')           , ...
        joinPath(crism_toolbox_dir,'base/readwrite/')          , ...
        joinPath(crism_toolbox_dir,'core/')                    , ...
        joinPath(crism_toolbox_dir,'library/')                 , ...
        joinPath(crism_toolbox_dir,'library/base/')            , ...
        joinPath(crism_toolbox_dir,'library/conv/')            , ...
        joinPath(crism_toolbox_dir,'library/folder_resolver/') , ...
        joinPath(crism_toolbox_dir,'library/util/') , ...
        joinPath(crism_toolbox_dir,'map/')                     , ...
        joinPath(crism_toolbox_dir,'setting/')                 , ...
        joinPath(crism_toolbox_dir,'spice/')                   , ...
        joinPath(crism_toolbox_dir,'spice/cahv/')              , ...
        joinPath(crism_toolbox_dir,'spice/kernel/')            , ...
        joinPath(crism_toolbox_dir,'spice/projection/')        , ...
        joinPath(crism_toolbox_dir,'spice/projection/mapper/') , ...
        joinPath(crism_toolbox_dir,'spice/util/')              , ...
        joinPath(crism_toolbox_dir,'util/')                    , ...
        joinPath(crism_toolbox_dir,'util/ADRVS_util/')         , ...
        joinPath(crism_toolbox_dir,'util/BP_util/')            , ...
        joinPath(crism_toolbox_dir,'util/photocor/')           , ...
        joinPath(crism_toolbox_dir,'util/r2if/')               , ...
        joinPath(crism_toolbox_dir,'util/vs/')                   ...
    );
    cmp_arch = computer('arch');
    switch cmp_arch
        case 'maci64'
            % For Mac computers
            crism_mex_build_path = joinPath(crism_toolbox_dir,'mex_build/maci64/');
        case 'glnxa64'
            % For Linux/Unix computers with x86-64 architechture.
            crism_mex_build_path = joinPath(crism_toolbox_dir,'mex_build/glnxa64/');
        case 'win64'
            crism_mex_build_path = joinPath(crism_toolbox_dir,'mex_build/win64/');
        otherwise
            error('%s is not supported',cmp_arch);
    end

    if exist(crism_mex_build_path,'dir')
        addpath(crism_mex_build_path);
    else
        addpath(crism_mex_build_path);
        fprintf('Run crism_script_compile_all.m to compile C/MEX sources.\n');
    end
end

%% SPICE/MICE
spice_toolbox_dir = joinPath(toolbox_root_dir,spice_dirname);
spice_mice_toolbox_dir = joinPath(spice_toolbox_dir,'mice/');
if exist(spice_mice_toolbox_dir,'dir')
    addpath( ...
        joinPath(spice_mice_toolbox_dir,'lib/')     , ...
        joinPath(spice_mice_toolbox_dir,'src/mice/')  ...
    );
else
    addpath( ...
        joinPath(spice_mice_toolbox_dir,'lib/')     , ...
        joinPath(spice_mice_toolbox_dir,'src/mice/')  ...
    );
    fwrite(1, ...
        sprintf([ ...
            'Message:' '\n'...
            'SPICE/MICE does not seem to be detected.'     '\n'...
            'SPICE/MICE may be necessary for advanced map projection on high resolution DTM' '\n' ...
            'Download  mice.tar.Z and importMice.csh' '\n'...
            ' from'                          '\n'...
            '   https://naif.jpl.nasa.gov/naif/toolkit_MATLAB.html' '\n'...
            sprintf(' into %s',spice_toolbox_dir)                  '\n'...
            ' and run' '\n'...
            ' /bin/csh -f importMice.csh' '\n'...
          ]) ...
   );
end

end

%%
function [onPath] = check_path_exist(dirpath, pathCell)
    % pathCell = strsplit(path, pathsep, 'split');
    if ispc || ismac 
      onPath = any(strcmpi(dirpath, pathCell));
    else
      onPath = any(strcmp(dirpath, pathCell));
    end
end