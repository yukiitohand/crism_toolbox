function [SWBWdata] = getSWBWfromWA(WAdata,acro)
% [SWdata] = getSWBWfromWA(WAdata,acro)
%   Get CDR SW/BW for the given WA file.
%   Input: 
%     WAdata: CDR WA data, CRISMdata obj
%     acro  : {'SW' or 'BW'}
%   Optinonal input
%    'band_inverse': boolean, (default) false
%   Output: 
%     SWBWdata: CRISMdata obj (SW or BW)
%   

if isempty(WAdata.img), WAdata.readimgi(); end

propWA = crism_getProp_basenameCDR4(WAdata.basename);

propSWBW = crism_create_propCDR6basename(...
    'acro',acro,'Partition',propWA.partition,...
    'sclk',propWA.sclk,'sensor_id',propWA.sensor_id);


[dir_info,basenameSWBW] = crism_search_cdr_fromProp(propSWBW);
dirfullpath_local = dir_info.dirfullpath_local;

if isempty(basenameSWBW)
    % sclk of SW BW may not match sclk or WA
    [basenameSWBW,propCDRmrb] = crism_searchCDRmrb(propSWBW);
    % basenameSWBW = search_withSCLK(propSWBW,dirfullpath_local);
end
SWBWdata = CRISMdata(basenameSWBW,dirfullpath_local);

end