function [entry_atf] = get_entryATF_fromProp(prop)
% [entry_atf] = get_entryATF_fromProp(prop)
%   Convert properties from observation to an entry in CDR ATF data.
%  Input Parameters
%   prop: struct storing properties
%    'yyyy_doy'
%    'obs_class_type'
%    'obs_id'
%    'obs_counter'
%    'activity_id' --> always set to '(?<activity_id>[a-zA-Z]{2})'
%    'activity_macro_num'
%    'sensor_id'
%    'version'
%    'product_type'
%  Onput Parameters
%   entry_atf: string, like
%     yyyy_doy/cccnnnnnnnn/xx_aammms
%     yyyy_doy: day of the year
%     ccc = class type of the obervation
%     nnnnnnn = observation id 
%     xx = observation counter
%     aa = activity id
%     mmm = activity macro number
%     s = sensor ID: S, L, or J 

obs_class_type = prop.obs_class_type;
obs_id = prop.obs_id;
obs_counter = prop.obs_counter;
% activity_id = prop.activity_id;
activity_id = '(?<activity_id>[a-zA-Z]{2})';
activity_macro_num = prop.activity_macro_num;
sensor_id = prop.sensor_id;
yyyy_doy = prop.yyyy_doy;

if isnumeric(obs_id)
    obs_id = sprintf('%08X',obs_id);
end

if isnumeric(obs_counter)
    obs_counter = sprintf('%02X',obs_counter);
end

if isnumeric(activity_macro_num)
    activity_macro_num = sprintf('%03d',activity_macro_num);
end


entry_atf = sprintf('%s/%s%s/%s_%s%s%s',yyyy_doy,obs_class_type,obs_id,...
                    obs_counter,activity_id,activity_macro_num,sensor_id);

end