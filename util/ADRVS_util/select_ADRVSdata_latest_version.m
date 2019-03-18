function [ADRVSdataList_latest,idxes_latest] = select_ADRVSdata_latest_version(ADRVSdataList)
% [ADRVSdataList_latest,idxes_latest] = select_ADRVSdata_latest_version(ADRVSdataList)
%   Select the most recent version of the processed data. If the data is
%   same other than version number, older versions are removed.
%  Input: 
%    ADRVSdataList: List of CRISMdata obj of ADR VS data
%  Output:
%    ADRVSdataList_latest: List of selected CRISMdata obj of ADR VS data
%    idxes_latest: index information of the selected ones in the original
%                    ADRVSdataList

propADRVSList = [ADRVSdataList.prop];
partition_list = {ADRVSdataList.partition};
sclk_list = {ADRVSdataList.sclk};
obsid_list = {propADRVSList.obs_id_short};
binning_list  = {propADRVSList.binning};
wvfil_list  = {propADRVSList.wavlength_filter};
ver_list = {propADRVSList.version};
sensor_id_list = {ADRVSdataList.sensor_id};

identifiers = cellfun(@(p,sclk,obs_id,binning,wvfil,sensor_id) sprintf('%d%d%s%d%d%s',p,sclk,obs_id,binning,wvfil,sensor_id),...
    partition_list,sclk_list,obsid_list,binning_list,wvfil_list,sensor_id_list);


identifiers_unique = unique(identifiers);

ADRVSdataList_latest = CRISMdata.empty(1,0);
idxes_latest = [];
for i=1:length(identifiers_unique)
    idx_mtch = find(strcmpi(identifiers_unique{i},identifiers));
    ver_list_mtch = ver_list(idx_mtch);
    [~,latest_one_idx] = max(ver_list_mtch);
    latest_idx = idx_mtch(latest_one_idx);
    idxes_latest = [idxes_latest,latest_idx];
    ADRVSdataList_latest = [ADRVSdataList_latest,ADRVSdataList(latest_idx)];
end

end
    

