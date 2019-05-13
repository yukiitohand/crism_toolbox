function [crismdata_obj_scene] = get_scene_CRISMdata_FFC(basenames,dirpath,ffc_counter)
% [crismdata_obj_scene] = get_scene_CRISMdata_FFC(basenames,dirpath,ffc_counter)
% get scene CRISMdata obj for scene. Return empty if no data is found.
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

if isempty(basenames)
    crismdata_obj_scene = [];
else
    if ischar(basenames)
        basenames = {basenames};
    end

    propList = cellfun(@(x) getProp_basenameOBSERVATION(x), basenames);
    obs_ctrs = cellfun(@(x) hex2dec(x), {propList.obs_counter});
    idx = find(obs_ctrs==ffc_counter);
    
    if isempty(idx)
        crismdata_obj_scene = [];
    elseif length(idx)>2
        error('Something wrong.');
    else
        basename = basenames{idx};
        crismdata_obj_scene = get_CRISMdata(basename,dirpath);
    end
end


end