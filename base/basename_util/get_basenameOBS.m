function [basenameOBS] = get_basenameOBS(varargin)
% [basenameOBS] = get_basenameOBS(varargin)
%  create basename pattern of observation with given property
%   Optional Parameters
%    'obs_class_type'       : (default) '(?<obs_class_type>[a-zA-Z]{3})'
%    'obs_id'               : (default) '(?<obs_id>[0-9a-fA-F]{8})'
%    'obs_counter'          : (default) '(?<obs_counter>[0-9a-fA-F]{2})'
%    'activity_id'          : (default) '(?<activity_id>[a-zA-Z]{2})'
%    'activity_macro_num'   : (default) '(?<activity_macro_num>[0-9]{3})'
%    'product_type'         : (default) '(?<product_type>[a-zA-Z]{3})'
%    'sensor_id'            : (default) '(?<sensor_id>[sljSLJ]{1})'
%    'version'              : (default) '(?<version>[0-9AY]{1})'
%    'yyyy_doy'             : (default) '(?<yyyy_doy>[0-9]{4}_[0-9]{3})'
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

[ prop ] = create_propOBSbasename( varargin{:} );

obs_class_type = prop.obs_class_type;
obs_id = prop.obs_id;
obs_counter = prop.obs_counter;
activity_id = prop.activity_id;
activity_macro_num = prop.activity_macro_num;
product_type = prop.product_type;
sensor_id = prop.sensor_id;
vr = prop.version;

if isnumeric(obs_id)
    obs_id = sprintf('%08X',obs_id);
end

if isnumeric(obs_counter)
    obs_counter = sprintf('%02X',obs_counter);
end

if isnumeric(activity_macro_num)
    activity_macro_num = sprintf('%03d',activity_macro_num);
end


if isnumeric(vr)
    vr = sprintf('%1d',vr);
end

basenameOBS = sprintf('%s%08s_%s_%s%s%s_%s%s',obs_class_type,obs_id,obs_counter,...
                 activity_id,activity_macro_num,sensor_id,product_type,vr);

end