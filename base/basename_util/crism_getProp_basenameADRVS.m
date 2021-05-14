function [prop] = crism_getProp_basenameADRVS(basenameADRVS,varargin)
% [prop] = crism_getProp_basenameADRVS(basenameADRVS,varargin)
%   Get properties from the basename of ADR VS data
%  Input Parameters
%   basenameADRVS: string, like
%     ADRPtttttttttt_nnnnn_VSbwn_v
%     P = partition of sclk time
%     tttttttttt = s/c start or mean time 
%     nnnnn = shortend observation id associated with this data
%     b = binning identifier, 0-3
%     w = wavelength filter, 0-3
%     n = sensor ID: S, L, or J
%     v = version
%  Output Parameters
%   prop: struct storing properties
%    'partition'
%    'sclk'
%    'obs_id_short'
%    'acro_calibration_type' (= 'VS')
%    'binning'
%    'wavelength_filter'
%    'sensor_id'
%    'version'

[ prop_ori ]   = crism_create_propADRVSbasename();
[basenameptrn] = crism_get_basenameADRVS_fromProp(prop_ori);

% ptrn_CDR4 = 'CDR(?<lelvel>[46]{1})(?<partition>[\d]{1})(?<sclk>[\d]{10})_(?<acro_calibration_type>[a-zA-Z]{2})(?<frame_rate>[0-4]{1})(?<binning>[0-3]{1})(?<exposure>[0-9]{3})(?<wavelength_filter>[0-3]{1})(?<side>[0-2]{1})(?<sensor_id>[sljSLJ]{1})_(?<version>[0-9]{1})';

prop = regexpi(basenameADRVS,basenameptrn,'names');

if ~isempty(prop)
    prop.partition = str2num(prop.partition);
    prop.sclk = str2num(prop.sclk);
    prop.binning = str2num(prop.binning);
    prop.wavelength_filter = str2num(prop.wavelength_filter);
    prop.version = str2num(prop.version);
    prop.acro_calibration_type = 'VS';
end


end