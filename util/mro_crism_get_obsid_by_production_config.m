function [obs_id_list] = mro_crism_get_obsid_by_production_config(select_delivery_id)

if ismac
    dir_mtrdr_prod_config = '/Users/itohy1/src/crism-idl/mro_crism_trunk/mro_crism_systematic/mtrdr/production_config/';
elseif isunix
    dir_mtrdr_prod_config = '/project/crism/users/itohy1/src/idl/mro_crism_trunk/mro_crism_systematic/mtrdr/production_config/';
elseif ispc
    error('%s is not supported for Windows System yet.',mfilename);
else
    error('%s is not supported for the host system.',mfilename);
end

fname_grid = 'MRO_CRISM_PDS_delivery_*_validate_grid.txt';
validate_grid_csv_files = dir(joinPath(dir_mtrdr_prod_config,fname_grid));

if ischar(select_delivery_id)
    if strcmpi(select_delivery_id,'all')
    else
        error('Undefined delivery_id: %s', select_delivery_id);
    end
elseif isnumeric(select_delivery_id)
    grid_csv_name_ptrn = 'MRO_CRISM_PDS_delivery_(?<delivery_id>\d{3})_validate_grid.txt';
    mtch = regexpi({validate_grid_csv_files.name},grid_csv_name_ptrn,'names');
    mtch = [mtch{:}];
    delivery_id_list = cellfun(@(x)str2double(x), {mtch.delivery_id});
    [is_id_exist,select_indx] = ismember(select_delivery_id,delivery_id_list);
    validate_grid_csv_files = validate_grid_csv_files(select_indx);
end

%%
% N = 0; 
obs_id_list = [];
for i=1:length(validate_grid_csv_files)
    csv_info = validate_grid_csv_files(i);
    csvfpath = joinPath(csv_info.folder,csv_info.name);
    fid = fopen(csvfpath,'r');
    obs_ids = textscan(fid,'%s');%,'Delimiter','\n\r','multipledelimsasone',true,'collectoutput',true);
    fclose(fid);
    obs_ids = obs_ids{1};
    Ni = length(obs_ids);
    fprintf('i=%d, %s, Ni=%d\n',i, csv_info.name,Ni);
    % N = N + Ni;
    obs_id_list = [obs_id_list,obs_ids'];
end


end