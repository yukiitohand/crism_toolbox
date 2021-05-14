function [prop] = crism_getProp_basenameCDR4(basenameCDR4,varargin)
% [prop] = crism_getProp_basenameCDR4(basenameCDR4,varargin)
%   Get properties from the basename of CDR4
%  Input Parameters
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
%  Output Parameters
%   prop: struct storing properties
%    'level' = 4
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

[ prop_ori ]   = crism_create_propCDR4basename();
[basenameptrn] = crism_get_basenameCDR4_fromProp(prop_ori);

% ptrn_CDR4 = 'CDR(?<lelvel>[46]{1})(?<partition>[\d]{1})(?<sclk>[\d]{10})_(?<acro_calibration_type>[a-zA-Z]{2})(?<frame_rate>[0-4]{1})(?<binning>[0-3]{1})(?<exposure>[0-9]{3})(?<wavelength_filter>[0-3]{1})(?<side>[0-2]{1})(?<sensor_id>[sljSLJ]{1})_(?<version>[0-9]{1})';

prop = regexpi(basenameCDR4,basenameptrn,'names');

if ~isempty(prop)
    prop.partition = str2num(prop.partition);
    prop.sclk = str2num(prop.sclk);
    prop.frame_rate = str2num(prop.frame_rate);
    prop.binning = str2num(prop.binning);
    prop.exposure = str2num(prop.exposure);
    prop.wavelength_filter = str2num(prop.wavelength_filter);
    prop.side = str2num(prop.side);
    prop.version = str2num(prop.version);
    prop.level = 4;
end


end