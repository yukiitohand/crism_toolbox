function [name_info] = get_spectrumIDfromspectra_namesCRISMspclib(spectra_names)
% [name_info] = get_spectrumIDfromspectra_namesCRISMspclib(spectra_names)
%  get spectrumID and name from the specta_names in the header of
%  CRISMspclib
%  Input Parameters
%   spectra_names: character or cell. looks like 'SIDERITE NAGR03',
%                 or {'SIDERITE NAGR03',...}
%  Output Parameters
%   name_info, array of struct, having two fields
%     name
%     product_id
%     product_name
%   
ptrn_productID = '^\s*(?<name>([\S]+.*[\S]+|[\S]+))\s+(?<product_id>[\S]+)\s*$';
ptrn_RT = '^\s*RT_(?<name>([\S]+.*[\S]+|[\S]+))_(?<product_name>LH-JFM-[\w]+)\s*$';

if ischar(spectra_names)
    spectra_names = {spectra_names};
end

L = length(spectra_names);

name_info = struct(...
        'product_id'      , repmat({''},[L,1]),...
        'product_name'    , repmat({''},[L,1]),...
        'name'            , repmat({''},[L,1])...
        );

for i=1:L
    spc_name = spectra_names{i};
    mtch_productID = regexpi(spc_name,ptrn_productID,'names');
    if ~isempty(mtch_productID)
        name_info(i).product_id = mtch_productID.product_id;
        name_info(i).name       = mtch_productID.name;
    else
        mtch_RT = regexpi(spc_name,ptrn_RT,'names');
        if ~isempty(mtch_RT)
            name_info(i).product_name = mtch_RT.product_name;
            name_info(i).name         = mtch_RT.name;
        end
    end
end

end

