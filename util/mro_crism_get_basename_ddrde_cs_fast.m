function [basename_ddrde_cs,errcode,dir_ddr] = mro_crism_get_basename_ddrde_cs_fast( ...
    obs_id,yyyy_doy,obs_class_type,sensor_id,activity_macro_num)

dirname    = sprintf('%3s%08s',obs_class_type,obs_id);
subdir_ddr = crism_get_subdir_OBS_crismlnx(yyyy_doy,dirname,'ddr');
cs_counter = mro_crism_get_cs_counter_default(obs_class_type);

prop_ptrn_de = crism_create_propOBSbasename('obs_id',obs_id, ...
    'OBS_CLASS_TYPE', obs_class_type, 'OBS_COUNTER', cs_counter, ...
    'ACTIVITY_ID','DE','ACTIVITY_MACRO_NUM',activity_macro_num,...
    'SENSOR_ID',sensor_id,'product_type','DDR');
basename_ptrn_de = crism_get_basenameOBS_fromProp(prop_ptrn_de);

[fnamelist_ddr,dir_ddr] = crism_get_filenames_in_subdir(subdir_ddr,false);
idx_de_cs = find(~cellfun('isempty',regexpi(fnamelist_ddr,[basename_ptrn_de,'.IMG$'],'once')));
if length(idx_de_cs) == 1
    errcode = 0;
    basename_ddrde_cs = fnamelist_ddr{idx_de_cs};
    basename_ddrde_cs = basename_ddrde_cs(1:end-4);
elseif isempty(idx_de_cs)
    fprintf('%s:%s: Central scan DDR DE does not exist.\n',dirname,sensor_id);
    errcode = 1;
    basename_ddrde_cs = [];
elseif length(idx_de_cs)>1
    fprintf('%s:%s: Multiple central scan DDR DE is found.\n',dirname,sensor_id);
    % Probably, there is a version difference
    propDE = crism_getProp_basenameOBSERVATION(fnamelist_ddr(idx_de_cs));
    propDE = [propDE{:}];
    [vr_max,vr_max_i] = max([propDE.version]);
    if vr_max==1
        if sum([propDE.version] == 1) == 1
            errcode = 0;
            idx_de_cs = idx_de_cs(vr_max_i);
            basename_ddrde_cs = fnamelist_ddr{idx_de_cs};
            basename_ddrde_cs = basename_ddrde_cs(1:end-4);
        else
            fprintf('%s:%s: Cannot find a right DDR DE.\n',dirname,sensor_id);
            errcode = 4;
            basename_ddrde_cs = [];
        end
    else
        if sum([propDE.version] == 1) == 1
            fprintf('%s:%s: Most highest version of central scan DDR DE data detected is %d, but v1 is used.\n', ...
                dirname, sensor_id, vr_max);
            errcode = 0;
            idx_de_cs = idx_de_cs(vr_max_i);
            basename_ddrde_cs = fnamelist_ddr{idx_de_cs};
            basename_ddrde_cs = basename_ddrde_cs(1:end-4);
        else
            fprintf('%s:%s: Most highest version of central scan DDR DE data detected is %d. Cannot find a right DDR DE\n', ...
                dirname, sensor_id, vr_max);
            errcode = 5;
            basename_ddrde_cs = [];
        end
    end
    
end

end