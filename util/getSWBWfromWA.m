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

propWA = getProp_basenameCDR4(WAdata.basename);

propSWBW = create_propCDR6basename(...
    'acro',acro,'Partition',propWA.partition,...
    'sclk',propWA.sclk,'sensor_id',propWA.sensor_id);


[dirfullpath_local,~,~,basenameSWBW,~,~,~] = get_dirpath_cdr_fromProp(propSWBW);

if isempty(basenameSWBW)
    % sclk of SW BW may not match sclk or WA
    [basenameSWBW,propCDRmrb] = crism_searchCDRmrb(propSWBW);
    % basenameSWBW = search_withSCLK(propSWBW,dirfullpath_local);
end
SWBWdata = CRISMdata(basenameSWBW,dirfullpath_local);

end