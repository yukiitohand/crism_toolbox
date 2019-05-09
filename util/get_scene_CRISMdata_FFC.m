function [crismdata_obj_scene] = get_scene_CRISMdata_FFC(basenames,dirpath,ffc_counter)
% [crismdata_obj_scene] = get_scene_CRISMdata_FFC(basenames,dirpath,ffc_counter)
% get scene CRISMdata obj for scene.
% INPUTS
%  basenames: basename of the CRISM data, or a cell array of it
%  dirpath  : path to the file, can be empty
%  ffc_counter: counter (normally 1('01') or 3('03')). Considered as
%               hexadecimal when char.
% OUTPUTS
%  crismdata_obj_scene: CRISMdata obj
% OPTIONAL PARAMETERS
% 

if ischar(ffc_counter)
    ffc_counter = hex2dec(ffc_counter);
end

if ischar(basenames) || isempty(basenames)
    basename = basenames;
elseif iscell(basenames)
    switch ffc_counter
        case 1
            idx = 1;
        case 3
            idx = 2;
        otherwise
            error('Check data');
    end
    basename = basenames{idx};
end

crismdata_obj_scene = get_CRISMdata(basename,dirpath);

switch upper(crismdata_obj_scene.lbl.OBSERVATION_TYPE)
    case 'FFC'
        if hex2dec(crismdata_obj_scene.prop.obs_counter) ~= ffc_counter
            error('crism_obs is something wrong');
        end
end

end