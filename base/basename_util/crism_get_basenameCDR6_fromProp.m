function [basenameCDR6] = crism_get_basenameCDR6_fromProp(prop)
% [basenameCDR6] = crism_get_basenameCDR6_fromProp(prop)
%  Input Parameters
%   prop: struct storing properties
%    'level'
%    'partition'
%    'sclk'
%    'acro_calibration_type'
%    'sensor_id'
%    'version'
%  Output Parameters
%   basenameCDR6: string, like
%     CDR6_P_tttttttttt_pp_n_v
%     P = partition of sclk time
%     tttttttttt = s/c start or mean time 
%     pp = calib. type from SIS table 2-8
%     n = sensor ID: S, L, or J
%     v = version

level     = prop.level;
partition = prop.partition;
sclk      = prop.sclk;
acro      = prop.acro_calibration_type;
sensor_id = prop.sensor_id;
vr        = prop.version;

if isnumeric(level)    , level = sprintf('%1d',level);                end
if ~strcmpi(level,'6') , error('This is not CDR6 basename property'); end
if isnumeric(partition), partition = sprintf('%1d',partition);        end
if isnumeric(sclk)     , sclk = sprintf('%010d',sclk);                end
if isnumeric(vr)       , vr = sprintf('%1d',vr);                      end

basenameCDR6 = sprintf('CDR%s_%s_%s_%s_%s_%s',level,partition,sclk,...
                  acro,sensor_id,vr);

end