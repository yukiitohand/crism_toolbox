function [basenameOBS] = crism_get_basenameOBS_fromProp(prop)
% [basenameOBS] = crism_get_basenameOBS_fromProp(prop)
%  Input Parameters
%   prop: struct storing properties
%    'obs_class_type'       
%    'obs_id'               
%    'obs_counter'         
%    'activity_id'         
%    'activity_macro_num'
%    'product_type'
%    'sensor_id' 
%    'version'
%    'yyyy_doy'
%  Output Parameters
%   basenameOBS: string, like
%     cccnnnnnn_xx_aammms_tttv
%     ccc = class type of the obervation
%     nnnnnnn = observation id 
%     xx = observation counter
%     aa = activity id
%     mmm = activity macro number
%     s = sensor ID: S, L, or J 
%     ttt = product type (EDR, TRR for TRDR, DDR, LDR)
%     v = version

obs_class_type = prop.obs_class_type;
obs_id         = prop.obs_id;
obs_counter    = prop.obs_counter;
activity_id    = prop.activity_id;
activity_macro_num = prop.activity_macro_num;
product_type       = prop.product_type;
sensor_id          = prop.sensor_id;
vr                 = prop.version;

if isnumeric(obs_id)     , obs_id = sprintf('%08X',obs_id);           end
if isnumeric(obs_counter), obs_counter = sprintf('%02X',obs_counter); end
if isnumeric(activity_macro_num), activity_macro_num = sprintf('%03d',activity_macro_num); end
if isnumeric(vr)         , vr = sprintf('%1d',vr);                    end

basenameOBS = sprintf('%s%08s_%s_%s%s%s_%s%s',obs_class_type,obs_id,obs_counter,...
                 activity_id,activity_macro_num,sensor_id,product_type,vr);

end