function [prop] = crism_getProp_basenameOBSERVATION(basename,varargin)
% [prop] = crism_getProp_basenameOBSERVATION(basename,varargin)
%   Get properties from the basename of EDR, DDR, LDR, and TRDR
%  Input Parameters
%   basename: string, like
%     cccnnnnnn_xx_aammms_tttv
%     ccc = class type of the obervation
%     nnnnnnn = observation id 
%     xx = observation counter
%     aa = activity id
%     mmm = activity macro number
%     s = sensor ID: S, L, or J 
%     ttt = product type (EDR, TRR for TRDR, DDR, LDR)
%     v = version
%  Output Parameters
%   prop: struct storing properties
%    'obs_class_type'
%    'obs_id'
%    'obs_counter'
%    'activity_id'
%    'activity_macro_num'
%    'product_type'
%    'sensor_id'
%    'version'

[ prop ]       = crism_create_propOBSbasename();
[basenameptrn] = crism_get_basenameOBS_fromProp(prop);

% baenameptrn = '(?<obs_class_type>[a-zA-Z]{3})(?<obs_id>[0-9a-fA-F]{8})_(?<obs_counter>[0-9a-fA-F]{2})_(?<activity_id>[a-zA-Z]{2})(?<activity_macro_num>[0-9]{3})(?<sensor_id>[sljSLJ]{1})_(?<product_type>[a-zA-Z]{3})(?<version>[0-9]{1})';

prop_basename = regexpi(basename,basenameptrn,'names');
if ~isempty(prop_basename)
    fldnms = fieldnames(prop_basename);
    for i=1:length(fldnms)
        fldnm = fldnms{i};
        prop.(fldnm) = prop_basename.(fldnm);
    end
    prop.activity_macro_num = str2num(prop.activity_macro_num);
    if ~isempty(str2num(prop.version))
        prop.version = str2num(prop.version);
    end
else
    prop = [];
end

end