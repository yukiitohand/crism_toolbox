function [basenameCDR4] = crism_get_basenameCDR4_fromProp(prop)
% [basenameCDR4] = crism_get_basenameCDR4_fromProp(prop)
%  Input Parameters
%   prop: struct storing properties
%    'level'
%    'partition'
%    'sclk'
%    'acro_calibration_type'
%    'frame_rate'
%    'binning'
%    'exposure'
%    'wavelength_filter'
%    'side'
%    'sensor_id'
%    'version'
%  Output Parameters
%   basenameCDR4: string, like
%     CDR4Ptttttttttt_pprbeeewsn_v
%     P = partition of sclk time
%     tttttttttt = s/c start or mean time 
%     pp = calib. type from SIS table 2-8
%     r = frame rate identifier, 0-4
%     b = binning identifier, 0-3
%     eee = exposure time parameter, 0-480 
%     w = wavelength filter, 0-3
%     s = side: 1 or 2, or 0 if N/A
%     n = sensor ID: S, L, or J
%     v = version

level     = prop.level;
partition = prop.partition;
sclk      = prop.sclk;
acro      = prop.acro_calibration_type;
frate     = prop.frame_rate;
binning   = prop.binning;
exposure  = prop.exposure;
wv_filter = prop.wavelength_filter;
side      = prop.side;
sensor_id = prop.sensor_id;
vr        = prop.version;

if isnumeric(level)    , level = sprintf('%1d',level);                end
if ~strcmpi(level,'4') , error('This is not CDR4 basename property'); end
if isnumeric(partition), partition = sprintf('%1d',partition);        end
if isnumeric(sclk)     , sclk = sprintf('%010d',sclk);                end
if isnumeric(frate)    , frate = sprintf('%1d',frate);                end
if isnumeric(binning)  , binning = sprintf('%1d',binning);            end
if isnumeric(exposure) , exposure = sprintf('%03d',exposure);         end
if isnumeric(wv_filter), wv_filter = sprintf('%1d',wv_filter);        end
if isnumeric(side)     , side = sprintf('%1d',side);                  end
if isnumeric(vr)       , vr = sprintf('%1d',vr);                      end

basenameCDR4 = sprintf('CDR%s%s%s_%s%s%s%s%s%s%s_%s',level,partition,sclk,...
                  acro,frate,binning,exposure,wv_filter,side,sensor_id,vr);

end

