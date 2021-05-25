function [crismTypeLib] = readCRISMTypeLibrary(varargin)
% read CRISM type library from its origial file. See the source for the
% default location for the library
% Output Parameters
%   crismTypeLib: struct having the field
%     'wavelength'
%     'ratioed_cor' : corrected ratioed spectrum
%     'ratioed' : ratioed spectrum
%     'nume_cor': corrected numerator
%     'nume'    : denominator
%     'deno_cor' : corrected denominator
%     'deno'    : denominator
%     'lbl' : label information for the file
%  Optional Parameters
%    'DIR' : root directory of the library
%       (default) crism_env_vars.dir_crismTypeLib
%       path to the directory where 'mrocr_8001' is saved.

global crism_env_vars

dir_crismTypeLib = crism_env_vars.dir_crismTypeLib;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'DIR'
                dir_crismTypeLib = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error('Unrecognized option: %s.',varargin{i});
        end
    end
end


dir_crismTypeLib_data = joinPath(dir_crismTypeLib,'mrocr_8001/data/');

if ~exist(dir_crismTypeLib_data,'dir')
    error('"%s" does not exist.',dir_crismTypeLib_data);
end

fnamelist = dir(joinPath(dir_crismTypeLib_data,'*.lbl'));
bnames = cell(1,length(fnamelist));
for i = 1:length(fnamelist)
    [~,bname,~] = fileparts(fnamelist(i).name);
    bnames{i} = bname;
end
crismTypeLib = struct('name', bnames);
for i=1:length(bnames)
    lbl = pds3lblread(joinPath(dir_crismTypeLib_data,[bnames{i} '.lbl']));
    fpath = joinPath(dir_crismTypeLib_data,[bnames{i} '.tab']);
    [ tab ] = crismTABread(fpath,lbl);
    L = length(tab.data);
    crismTypeLib(i).wavelength = reshape([tab.data.WAVELENGTH],[L,1]);
    crismTypeLib(i).ratioed_cor = reshape([tab.data.CRISM_RATIOED_IF_CORRECTED],[L,1]);
    crismTypeLib(i).raioed = reshape([tab.data.CRISM_RATIOED_IF],[L,1]);
    crismTypeLib(i).nume_cor = reshape([tab.data.CRISM_IF_NUMERATOR_CORRECTED],[L,1]);
    crismTypeLib(i).nume = reshape([tab.data.CRISM_IF_NUMERATOR],[L,1]);
    crismTypeLib(i).deno_cor = reshape([tab.data.CRISM_IF_DENOMINATOR_CORRECTED],[L,1]);
    crismTypeLib(i).deno = reshape([tab.data.CRISM_IF_DENOMINATOR],[L,1]);
    crismTypeLib(i).lbl = lbl;
    
end


end
