function [basenameADRVS] = crism_get_basenameADRVS_fromProp(prop)
% [basenameCDR4] = crism_get_basenameADRVS_fromProp(prop)
%  Input Parameters
%   prop: struct storing properties
%    'partition'
%    'sclk'
%    'obs_id_short'
%    'binning'
%    'wavelength_filter'
%    'sensor_id'
%    'version'
%  Output Parameters
%   basenameADRVS: string, like
%     ADRPtttttttttt_nnnnn_VSbwn_v
%     P = partition of sclk time
%     tttttttttt = s/c start or mean time 
%     nnnnn = shortend observation id associated with this data
%     b = binning identifier, 0-3
%     w = wavelength filter, 0-3
%     n = sensor ID: S, L, or J
%     v = version

partition = prop.partition;
sclk      = prop.sclk;
obs_id_short = prop.obs_id_short;
acro      = prop.acro_calibration_type;
binning   = prop.binning;
wv_filter = prop.wavelength_filter;
sensor_id = prop.sensor_id;
vr        = prop.version;


if isnumeric(partition)
    partition = sprintf('%1d',partition);
end
if isnumeric(sclk)
    sclk = sprintf('%010d',sclk);
end

if isnumeric(binning)
    binning = sprintf('%1d',binning);
end

if isnumeric(wv_filter)
    wv_filter = sprintf('%1d',wv_filter);
end

if length(obs_id_short)>5 && strcmp(obs_id_short(1:3),'000') 
    obs_id_short = obs_id_short(4:8);
elseif length(obs_id_short)<5
    obs_id_short = sprintf('%05s',obs_id_short);
end

if isnumeric(vr)
    vr = sprintf('%1d',vr);
end


basenameADRVS = sprintf('ADR%s%s_%s_%s%s%s%s_%s',partition,sclk,obs_id_short,...
                  acro,binning,wv_filter,sensor_id,vr);

end