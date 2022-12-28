function [WVdata] = crism_getWVfromWA(WAdata,varargin)
% [WVdata] = crism_getWVfromWA(WAdata)
%   Get CDR WV data for the given WA file.
%   Input: 
%     WAdata: CDR WA data, CRISMdata obj
%   Output: 
%     WVdata: CRISMdata obj
%   

% Test the files are downloaded or not.
propWVgen = crism_create_propCDR6basename('acro','WV');
[dir_info,basenameWV,fnameWV_wext_local] = crism_search_cdr_fromProp(propWVgen,varargin{:});
if isempty(fnameWV_wext_local)
    [dir_info,basenameWV,fnameWV_wext_local] = crism_search_cdr_fromProp(propWVgen,'dwld',2);
end

if isempty(WAdata.img), WAdata.readimgi(); end

propWA = crism_getProp_basenameCDR4(WAdata.basename);

propWV = crism_create_propCDR6basename(...
    'acro','WV','Partition',propWA.partition,...
    'sclk',propWA.sclk,'sensor_id',propWA.sensor_id);

[dir_info,basenameWV,fnameWV_wext_local] = crism_search_cdr_fromProp(propWV,varargin{:});

dirfullpath_local = dir_info.dirfullpath_local;

WVdata = CRISMdata(basenameWV,dirfullpath_local);

end
