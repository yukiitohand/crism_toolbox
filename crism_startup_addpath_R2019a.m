function [] = crism_startup_addpath_R2019a(varargin)
% crism_startup_addpath_R2019a
%  Add paths of crism_toolbox, while solving dependent toolboxes.
%  Dependent toolboxes: 
%     base
%     envi
%     pds3_toolbox
% 
%  USAGE
%  >> crism_startup_addpath_R2019a()
%  >> crism_startup_addpath_R2019a(error_if_not_unique)
%  >> crism_startup_addpath_R2019a(error_if_not_unique,silent_if_not_unique)
%  
% Optional Input Arguments
% error_if_not_unique: boolean, (default) false
%   whether throw an error if one of the dependent toolboxes cannot be 
%   found or multiple versions are detected.
% silent_if_not_unique: boolean, (default) false
%   whether print a meesage if one of the dependent toolboxes cannot be 
%   found or multiple versions are detected. If error_if_not_unique, then
%   this does not have any effect (since error will be thrown.)
%
% Also supports MATLAB versions < R2019b
% 

error_if_not_unique_default  = false;
silent_if_not_unique_default = false;

p = inputParser;
p.FunctionName = mfilename;
p.addOptional('error_if_not_unique' ,error_if_not_unique_default, ...
    @(x)validateattributes(x,'numeric',{'scalar','binary'},1));
p.addOptional('silent_if_not_unique',silent_if_not_unique_default, ...
    @(x)validateattributes(x,'numeric',{'scalar','binary'},2));

parse(p,varargin{:});

error_if_not_unique  = p.Results.error_if_not_unique;
silent_if_not_unique = p.Results.silent_if_not_unique;

%% Automatically find the path to toolboxes
fpath_self = mfilename('fullpath');
[dirpath_self,filename] = fileparts(fpath_self);
[toolbox_root_dir,crism_toolbox_dirname] = fileparts(dirpath_self);

%% find dependent toolboxes
dList = dir(toolbox_root_dir);
pathCell = strsplit(path, pathsep);

% base toolbox
[base_toolbox_dir,base_toolbox_dirname,Nt] = get_toolbox_dirname(dList, ...
    'base',error_if_not_unique,silent_if_not_unique);
if Nt==1 && ~check_path_exist(base_toolbox_dir, pathCell)
    addpath(base_toolbox_dir);
end

% envi toolbox
[envi_toolbox_dir,envi_toolbox_dirname,Nt] = get_toolbox_dirname(dList, ...
    'envi',error_if_not_unique,silent_if_not_unique);
if Nt==1 && ~check_path_exist(envi_toolbox_dir, pathCell)
    run(fullfile(envi_toolbox_dir,'envi_startup_addpath_R2019a'));
end

% pds3_toolbox
[pds3_toolbox_dir,pds3_toolbox_dirname,Nt] = get_toolbox_dirname(dList, ...
    'pds3_toolbox',error_if_not_unique,silent_if_not_unique);
if Nt==1 && ~check_path_exist(pds3_toolbox_dir, pathCell)
    run(fullfile(pds3_toolbox_dir,'pds3_startup_addpath_R2019a'));
end

%% crism_toolbox
crism_toolbox_dir = fullfile(toolbox_root_dir, crism_toolbox_dirname);
if ~check_path_exist(crism_toolbox_dir, pathCell)
    addpath( ...
        crism_toolbox_dir                                         , ...
        fullfile(crism_toolbox_dir,'base')                        , ...
        fullfile(crism_toolbox_dir,'base','atf_util')             , ...
        fullfile(crism_toolbox_dir,'base','basename_util')        , ...
        fullfile(crism_toolbox_dir,'base','connect')              , ...
        fullfile(crism_toolbox_dir,'base','folder_resolver')      , ...
        fullfile(crism_toolbox_dir,'base','lbl_util')             , ...
        fullfile(crism_toolbox_dir,'base','readwrite')            , ...
        fullfile(crism_toolbox_dir,'core')                        , ...
        fullfile(crism_toolbox_dir,'library')                     , ...
        fullfile(crism_toolbox_dir,'library','base')              , ...
        fullfile(crism_toolbox_dir,'library','conv')              , ...
        fullfile(crism_toolbox_dir,'library','folder_resolver')   , ...
        fullfile(crism_toolbox_dir,'library','util')              , ...
        fullfile(crism_toolbox_dir,'map')                         , ...
        fullfile(crism_toolbox_dir,'setting')                     , ...
        fullfile(crism_toolbox_dir,'spice')                       , ...
        fullfile(crism_toolbox_dir,'spice','cahv')                , ...
        fullfile(crism_toolbox_dir,'spice','kernel')              , ...
        fullfile(crism_toolbox_dir,'spice','projection')          , ...
        fullfile(crism_toolbox_dir,'spice','projection','mapper') , ...
        fullfile(crism_toolbox_dir,'spice','util')                , ...
        fullfile(crism_toolbox_dir,'util')                        , ...
        fullfile(crism_toolbox_dir,'util','ADRVS_util')           , ...
        fullfile(crism_toolbox_dir,'util','BP_util')              , ...
        fullfile(crism_toolbox_dir,'util','photocor')             , ...
        fullfile(crism_toolbox_dir,'util','r2if')                 , ...
        fullfile(crism_toolbox_dir,'util','vs')                     ...
    );
    cmp_arch = computer('arch');
    switch cmp_arch
        case 'maci64'
            % For Mac computers
            crism_mex_build_path = fullfile(crism_toolbox_dir,'mex_build','maci64');
        case 'glnxa64'
            % For Linux/Unix computers with x86-64 architechture.
            crism_mex_build_path = fullfile(crism_toolbox_dir,'mex_build','glnxa64');
        case 'win64'
            crism_mex_build_path = fullfile(crism_toolbox_dir,'mex_build','win64');
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
if ~verLessThan('matlab','9.9') % ge R2020b
    spice_dirname = 'spice';
elseif ~verLessThan('matlab','9.4') % ge R2018a
    spice_dirname = 'spice-r2020a';
else
     spice_dirname = 'spice-r2017b';
end
spice_toolbox_dir = fullfile(toolbox_root_dir,spice_dirname);
spice_mice_toolbox_dir = fullfile(spice_toolbox_dir,'mice');
if exist(spice_mice_toolbox_dir,'dir')
    addpath( ...
        fullfile(spice_mice_toolbox_dir,'lib')     , ...
        fullfile(spice_mice_toolbox_dir,'src','mice')  ...
    );
else
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

function [toolbox_dirpath,toolbox_dirname,Nt] = get_toolbox_dirname( ...
    dList,toolbox_dirname_wover,error_if_not_unique,silent_if_not_unique)
% [toolbox_dirpath,toolbox_dirname,Nt] = get_toolbox_dirname( ...
%     dList,toolbox_dirname_wover,error_if_not_unique,silent_if_not_unique)
%  get directory path to the toolbox specified by "toolbox_dirname_wover",
%  which is the directory name of the toolbox without a version suffix. 
%  Also the directory name of the toolbox with the version is returned.
%  If no such toolbox is found or multiple of them are found, then: 
%    throws an error when error_if_not_unique = true
%    outputs an message when error_if_not_unique = false and silent_if_not_unique = false
%    return empty when error_if_not_unique = false and silent_if_not_unique=true
%    and no toolbox is found
%    return cell arrays when error_if_not_unique = false and silent_if_not_unique=true
%    and multiple toolboxes are found.
%
%  Inputs:
%   dList: struct, output of dir function
%   toolbox_dirname_wover: directory name of the toolbox without version
%      numbers.
%   error_if_not_unique: boolean. whether or not to throw an error if no
%   toolbox or multiple toolboxes are detected.
%   silent_if_not_unique: boolean. whether or not to print a message if no
%   toolbox or multiple toolboxes are detected. No effect when
%   error_if_not_unique is true(1).
%  OUTPUTS
%   toolbox_dirpath: empty, char, cell array of chars.
%     directory path of the toolbox (with versions if exists).
%   toolbox_dirname: empty, char, cell array of chars.
%     directory name of the toolbox (without versions if exists).
%   Nt: number of toolboxes detected.

    dirname_ptrn = sprintf('(?<toolbox_dirname>%s(-[\\d\\.]+){0,1}[%s]{0,1})',...
        toolbox_dirname_wover,filesep);
    mtch_toolbox_dirname = regexpi({dList.name},dirname_ptrn,'names');
    mtchidx = find(not(cellfun('isempty',mtch_toolbox_dirname)));
    toolbox_root_dir = dList(1).folder;
    if length(mtchidx)==1
        toolbox_dirname = mtch_toolbox_dirname{mtchidx}.toolbox_dirname;
        toolbox_dirpath = fullfile(toolbox_root_dir, toolbox_dirname);
        Nt = 1;
    elseif isempty(mtchidx)
        toolbox_dirname = [];
        toolbox_dirpath = [];
        Nt = 0;
        if error_if_not_unique
            mid = strcat(toolbox_dirname_wover,':notfind');
            ME = MException(mid, ...
                ['Cannot find %s toolbox in\n %s', ...
                 'Download from\n', ...
                 '   https://github.com/yukiitohand/%s/'], ...
                toolbox_dirname_wover,toolbox_root_dir,toolbox_dirname_wover);

            throwAsCaller(ME);
        else
            if ~silent_if_not_unique
                fprintf(['Cannot find %s toolbox in.\n %s', ...
                       'If necessary, download it from\n', ...
                       '   https://github.com/yukiitohand/%s/\n', ...
                       'Otherwise, manually set path to %s toolbox.\n'
                      ], ...
                    toolbox_dirname_wover,toolbox_root_dir, ...
                    toolbox_dirname_wover,toolbox_dirname_wover);
            end
        end
    else % length(mtchidx)>1
        toolbox_dirname_struct = cat(2,mtch_toolbox_dirname{mtchidx});
        toolbox_dirname = {toolbox_dirname_struct.toolbox_dirname};
        toolbox_dirpath = cellfun(@(x) fullfile(toolbox_root_dir,x), ...
            toolbox_dirname, 'UniformOutput',false);
        Nt = length(mtchidx);
        if error_if_not_unique
            mid = strcat(toolbox_dirname_wover,':multifind');
            toolbox_root_dir = dList(1).folder;
            ME = MException(mid, ...
                ['Multiple %s toolboxes, %s, are detected in %s\n', ...
                 'Manually set path to %s toolbox.\n' ], ...
                toolbox_dirname_wover,strjoin(toolbox_dirname,','), ...
                toolbox_root_dir, toolbox_dirname_wover);
            throwAsCaller(ME);
        else
            if ~silent_if_not_unique
                fprintf([ ...
                    'Multiple %s toolboxes, %s, are detected in %s\n', ...
                    'Manually set path to %s toolbox.\n' ...
                    ], ...
                    toolbox_dirname_wover,strjoin(toolbox_dirname,', '), ...
                    toolbox_root_dir,toolbox_dirname_wover);
            end
        end
        
    end
end
