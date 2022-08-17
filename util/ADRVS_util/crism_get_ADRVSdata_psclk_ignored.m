function [ADRVSdataList_s,idxes_selected] = crism_get_ADRVSdata_psclk_ignored(ADRVSdataList)
% [ADRVSdataList_s,idxes_selected] = crism_get_ADRVSdata_psclk_ignored(ADRVSdataList)
%   Remove all the ADRVSdata that are same except partition and sclk time.
%   Because such data seem to be duplicates. Among them, usually ADRVSdata 
%   withsclk=0 tend to be selected.
%  Input: 
%    ADRVSdataList: List of CRISMdata obj of ADR VS data
%  Output:
%    ADRVSdataList_s: List of selected CRISMdata obj of ADR VS data
%    idxes_selected: index information of the selected ones in the original
%                    ADRVSdataList

propADRVSList = [ADRVSdataList.prop];
% partition_list = {ADRVSdataList.partition};
sclk_list = {propADRVSList.sclk};
obsid_list = {propADRVSList.obs_id_short};
binning_list  = {propADRVSList.binning};
wvfil_list  = {propADRVSList.wavelength_filter};
% ver_list = {propADRVSList.version};
sensor_id_list = {propADRVSList.sensor_id};

identifiers = cellfun(@(obs_id,binning,wvfil,sensor_id) sprintf('%s%d%d%s',obs_id,binning,wvfil,sensor_id),...
    obsid_list,binning_list,wvfil_list,sensor_id_list,'UniformOutput',false);


identifiers_unique = unique(identifiers);

ADRVSdataList_s = CRISMADRVSdata.empty(1,0);
idxes_selected = [];
for i=1:length(identifiers_unique)
    idx_mtch = find(strcmpi(identifiers_unique{i},identifiers));
    sclk_list_mtch = cell2mat(sclk_list(idx_mtch));
    [~,idx_oldest_one] = min(sclk_list_mtch);
    oldest_idx = idx_mtch(idx_oldest_one);
    idxes_selected = [idxes_selected,oldest_idx];
    ADRVSdataList_s = [ADRVSdataList_s,ADRVSdataList(oldest_idx)];
end

end


