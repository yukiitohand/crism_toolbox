function [WVdata] = crism_getWVfromWA(WAdata)
% [WVdata] = crism_getWVfromWA(WAdata)
%   Get CDR WV data for the given WA file.
%   Input: 
%     WAdata: CDR WA data, CRISMdata obj
%   Output: 
%     WVdata: CRISMdata obj
%   

if isempty(WAdata.img), WAdata.readimgi(); end

propWA = crism_getProp_basenameCDR4(WAdata.basename);

propWV = crism_create_propCDR6basename(...
    'acro','WV','Partition',propWA.partition,...
    'sclk',propWA.sclk,'sensor_id',propWA.sensor_id);

[dir_info,basenameWV] = crism_search_cdr_fromProp(propWV);
dirfullpath_local = dir_info.dirfullpath_local;

WVdata = CRISMdata(basenameWV,dirfullpath_local);

end