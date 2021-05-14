function [ prop ] = create_propOBSbasename( varargin )
% [ prop ] = create_propOBSbasename( varargin )
%   return struct of the basename of EDR, DDR, LDR, and TRDR
%  Output
%   prop: struct storing properties
%    'obs_class_type'       : (default) '(?<obs_class_type>[a-zA-Z]{3})'
%    'obs_id'               : (default) '(?<obs_id>[0-9a-fA-F]{8})'
%    'obs_counter'          : (default) '(?<obs_counter>[0-9a-fA-F]{2})'
%    'activity_id'          : (default) '(?<activity_id>[a-zA-Z]{2})'
%    'activity_macro_num'   : (default) '(?<activity_macro_num>[0-9]{3})'
%    'product_type'         : (default) '(?<product_type>[a-zA-Z]{3})'
%    'sensor_id'            : (default) '(?<sensor_id>[sljSLJ]{1})'
%    'version'              : (default) '(?<version>[0-9A-Z]{1})'
%    'yyyy_doy'             : (default) '(?<yyyy_doy>[0-9]{4}_[0-9]{3})'
%
%   Optional Parameters
%    'OBS_CLASS_TYPE', 'OBS_ID', 'OBS_COUNTER', 'ACTIVITY_ID', 'ACTIVITY_MACRO_NUM', 'PRODUCT_TYPE',
%    'SENSOR_ID', 'VERSION'
% 
%  * Reference *
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


obs_class_type       = '(?<obs_class_type>[a-zA-Z]{3})';
obs_id               = '(?<obs_id>[0-9a-fA-F]{8})';
obs_counter          = '(?<obs_counter>[0-9a-fA-F]{2})';
activity_id          = '(?<activity_id>[a-zA-Z]{2})';
activity_macro_num   = '(?<activity_macro_num>[0-9]{3})';
product_type         = '(?<product_type>[a-zA-Z]{3})';
sensor_id            = '(?<sensor_id>[sljSLJ]{1})';
vr                   = '(?<version>[0-9a-zA-Z]{1})';
yyyy_doy             = '(?<yyyy_doy>[0-9]{4}_[0-9]{3})';

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'OBS_CLASS_TYPE'
                obs_class_type = varargin{i+1};
            case 'OBS_ID'
                obs_id = varargin{i+1};
            case 'OBS_COUNTER'
                obs_counter = varargin{i+1};
            case 'ACTIVITY_ID'
                activity_id = varargin{i+1};
            case 'ACTIVITY_MACRO_NUM'
                activity_macro_num = varargin{i+1};
            case 'PRODUCT_TYPE'
                product_type = varargin{i+1};
            case 'SENSOR_ID'
                sensor_id = varargin{i+1};
            case 'YYYY_DOY'
                yyyy_doy = varargin{i+1};
            case 'VERSION'
                vr = varargin{i+1};
             otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);   
        end
    end
end

prop = [];
prop.obs_class_type = obs_class_type;
prop.obs_id = obs_id;
prop.obs_counter = obs_counter;
prop.activity_id = activity_id;
prop.activity_macro_num = activity_macro_num;
prop.product_type = product_type;
prop.sensor_id = sensor_id;
prop.version = vr;
prop.yyyy_doy = yyyy_doy;

end