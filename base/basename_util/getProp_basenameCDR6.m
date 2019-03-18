function [prop] = getProp_basenameCDR6(basenameCDR6,varargin)
% [prop] = getProp_basenameCDR6(basenameCDR6)
%   Get properties from the basename of CDR6
%  Input Parameters
%   basenameCDR6: string, like
%     CDR6_P_tttttttttt_pp_n_v
%     P = partition of sclk time
%     tttttttttt = s/c start or mean time 
%     pp = calib. type from SIS table 2-8
%     n = sensor ID: S, L, or J
%     v = version
%  Output Parameters
%   prop: struct storing properties
%    'partition'
%    'sclk'
%    'acro_calibration_type'
%    'sensor_id'
%    'version'


[ prop_ori ] = create_propCDR6basename();
[basenameptrn] = get_basenameCDR6_fromProp(prop_ori);

% ptrn_CDR6 = 'CDR6_(?<partition>[\d]{1})_(?<sclk>[\d]{10})_(?<acro>[a-zA-Z]{2})_(?<sensor_id>[sljSLJ]{1})_(?<version>[0-9]{1})';

prop = regexpi(basenameCDR6,basenameptrn,'names');
if ~isempty(prop)
    prop.partition = str2num(prop.partition);
    prop.sclk = str2num(prop.sclk);
    prop.version = str2num(prop.version);
    prop.level = 6;
end

end