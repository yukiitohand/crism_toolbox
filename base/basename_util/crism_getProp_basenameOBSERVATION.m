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

[ prop_init ]       = crism_create_propOBSbasename();
[basenameptrn] = crism_get_basenameOBS_fromProp(prop_init);

% baenameptrn = '(?<obs_class_type>[a-zA-Z]{3})(?<obs_id>[0-9a-fA-F]{8})_(?<obs_counter>[0-9a-fA-F]{2})_(?<activity_id>[a-zA-Z]{2})(?<activity_macro_num>[0-9]{3})(?<sensor_id>[sljSLJ]{1})_(?<product_type>[a-zA-Z]{3})(?<version>[0-9]{1})';

prop = regexpi(basename,basenameptrn,'names','once');

if length(prop)==1
    if ~isempty(prop)
        prop.activity_macro_num = str2double(prop.activity_macro_num);
        if ~isnan(str2double(prop.version))
            prop.version = str2double(prop.version);
        end
    end
else
    for i = 1:length(prop)
        if ~isempty(prop)
            prop{i}.activity_macro_num = str2double(prop{i}.activity_macro_num);
            if ~isnan(str2double(prop{i}.version))
                prop{i}.version = str2double(prop{i}.version);
            end
        end
    end
end

end