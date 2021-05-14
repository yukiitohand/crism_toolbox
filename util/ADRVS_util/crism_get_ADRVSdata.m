function [ADRVSdataList] = crism_get_ADRVSdata(propADRVS,varargin)
% [ADRVSdataList] = crism_get_ADRVSdata(propADRVS,varargin)
% get ADRVSdata that match the input propADRVS. If propADRVS is empty, all
% ADRVSdata will be retured.
%  
% INPUT
%   propADRVS: property struct of the ADRVS data.
% OUTPUT
%   ADRVSdataList: List of CRISMdata obj of ADR VS data
% OPTIONAL Parameters
%   'DWLD','DOWNLOAD'
%     whether or not to show all the files to be read {0,-1}
%      (default) 0

dwld = 0;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

[dir_info,basenameADRVS] = crism_search_adrvs_fromProp(propADRVS,'Dwld',dwld);
dirfullpath_local = dir_info.dirfullpath_local;
if ischar(basenameADRVS),basenameADRVS = {basenameADRVs}; end
% read ADRVSdata
ADRVSdataList = CRISMdata.empty(1,0);
for i=1:length(basenameADRVS)
    adrvs_data_i = CRISMdata(basenameADRVS{i},dirfullpath_local);
     ADRVSdataList = [ADRVSdataList;adrvs_data_i];
end