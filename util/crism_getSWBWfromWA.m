function [SWBWdata] = crism_getSWBWfromWA(WAdata,acro,varargin)
% [SWBWdata] = crism_getSWBWfromWA(WAdata,acro)
%   Get CDR SW/BW for the given WA file.
%   Input: 
%     WAdata: CDR WA data, CRISMdata obj
%     acro  : {'SW' or 'BW'}
%   Optinonal input
%    'band_inverse': boolean, (default) false
%   Output: 
%     SWBWdata: CRISMdata obj (SW or BW)
%   

% Test the files are downloaded or not.
propSWBWgen = crism_create_propCDR6basename('acro',acro);
[dir_info,basenameSWBW,fnameSWBW_wext_local] = crism_search_cdr_fromProp(propSWBWgen,varargin{:});
if isempty(fnameSWBW_wext_local)
    [dir_info,basenameSWBW,fnameSWBW_wext_local] = crism_search_cdr_fromProp( ...
            propSWBWgen,'dwld',2);
end

if isempty(WAdata.img), WAdata.readimgi(); end

propWA = crism_getProp_basenameCDR4(WAdata.basename);

propSWBW = crism_create_propCDR6basename(...
    'acro',acro,'Partition',propWA.partition,...
    'sclk',propWA.sclk,'sensor_id',propWA.sensor_id);

[dir_info,basenameSWBW,fnameSWBW_wext_local] = crism_search_cdr_fromProp(propSWBW,varargin{:});
if isempty(basenameSWBW)
    fprintf('Matching %s cannot be found. Searching most recent prducts before SCLK ...\n',acro);
end

dirfullpath_local = dir_info.dirfullpath_local;

if isempty(basenameSWBW)
    % sclk of SW BW may not match sclk or WA
    [basenameSWBW,propCDRmrb] = crism_searchCDRmrb(propSWBW,varargin{:});
    % basenameSWBW = search_withSCLK(propSWBW,dirfullpath_local);
end
SWBWdata = CRISMdata(basenameSWBW,dirfullpath_local);

end