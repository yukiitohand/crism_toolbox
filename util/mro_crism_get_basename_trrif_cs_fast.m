function [basename_trrif_cs,errcode,dir_trr,basename_trrhkp_cs] = mro_crism_get_basename_trrif_cs_fast( ...
    obs_id,yyyy_doy,obs_class_type,sensor_id)

% =========================================================================
%       SEARCH FILENAME OF CENTRAL SCAN I/F IMAGE CUBE FILE
% =========================================================================
dirname    = sprintf('%3s%08s',obs_class_type,obs_id);
subdir_trr = crism_get_subdir_OBS_crismlnx(yyyy_doy,dirname,'trr');
cs_counter = mro_crism_get_cs_counter_default(obs_class_type);

prop_ptrn = crism_create_propOBSbasename('obs_id',obs_id, ...
    'OBS_CLASS_TYPE', obs_class_type, 'OBS_COUNTER', cs_counter, ...
    'ACTIVITY_ID','IF','SENSOR_ID',sensor_id,'product_type','TRR');
basename_ptrn = crism_get_basenameOBS_fromProp(prop_ptrn);

[fnamelist_trr,dir_trr] = crism_get_filenames_in_subdir(subdir_trr,false);
idx_trrif_cs = find(~cellfun('isempty',regexpi(fnamelist_trr, ...
    [basename_ptrn,'.IMG$'],'once')));
if length(idx_trrif_cs)==1
    errcode = 0;
    basename_trrif_cs = fnamelist_trr{idx_trrif_cs};
    basename_trrif_cs = basename_trrif_cs(1:end-4);
elseif isempty(idx_trrif_cs)
    fprintf('%s:%s: Central scan I/F does not exist.\n',dirname,sensor_id);
    errcode = 2; basename_trrif_cs = []; basename_trrhkp_cs = [];
elseif length(idx_trrif_cs)>1
    fprintf('%s:%s: Multiple central scan I/F is found.\n',dirname,sensor_id);
    errcode = 2; basename_trrif_cs = []; basename_trrhkp_cs = [];
end

if errcode==0 && nargout > 3
    prop_trrif_cs = crism_getProp_basenameOBSERVATION(basename_trrif_cs);
    prop_ptrn_trrhkp = prop_trrif_cs;
    prop_ptrn_trrhkp.activity_id = 'RA';
    prop_ptrn_trrhkp.product_type = 'HKP';
    prop_ptrn_trrhkp.version = '(?<version>[0-9a-zA-Z]{1})';
    basename_ptrn = crism_get_basenameOBS_fromProp(prop_ptrn_trrhkp);
    idx_trrhkp_cs = find(~cellfun('isempty',regexpi(fnamelist_trr, ...
        [basename_ptrn,'.TAB$'],'once')));
    if length(idx_trrhkp_cs) == 1
        errcode = 0;
        basename_trrhkp_cs = fnamelist_trr{idx_trrhkp_cs};
    elseif isempty(idx_trrhkp_cs)
        fprintf('%s:%s: Central scan HKP TAB does not exist.\n',dirname,sensor_id);
        errcode = 1; basename_trrhkp_cs = [];
    elseif length(idx_trrhkp_cs)>1
        fprintf('%s:%s: Multiple central scan HKP TAB is found.\n',dirname,sensor_id);
        errcode = 2; basename_trrhkp_cs = [];
    end
end


end