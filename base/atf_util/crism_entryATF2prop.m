function [prop] = crism_entryATF2prop(entry_atf)
% [prop] = crism_entryATF2prop(entry_atf)
%   Get properties from the string entry in CDR ATF data.
%  Input Parameters
%   entry_atf: string, like
%     yyyy_doy/cccnnnnnnnn/xx_aammms
%     yyyy_doy: day of the year
%     ccc = class type of the obervation
%     nnnnnnn = observation id 
%     xx = observation counter
%     aa = activity id
%     mmm = activity macro number
%     s = sensor ID: S, L, or J 
%  Output Parameters
%   prop: struct storing properties
%    'yyyy_doy'
%    'obs_class_type'
%    'obs_id'
%    'obs_counter'
%    'activity_id'
%    'activity_macro_num'
%    'sensor_id'
%    'version'
%    'product_type'

[ prop ] = create_propOBSbasename();
ptrn = crism_get_entryATF_fromProp(prop);

prop_atf = regexpi(entry_atf,ptrn,'names');
if ~isempty(prop_atf)
    fldnms = fieldnames(prop_atf);
    for i=1:length(fldnms)
        fldnm = fldnms{i};
        prop.(fldnm) = prop_atf.(fldnm);
    end
    prop.activity_macro_num = str2num(prop.activity_macro_num);
else
    prop = [];
end

end