function [search_result] = crism_search_products_OBS(obs_id, product_type, varargin)

obs_class_type       = '';
obs_counter          = '(?<obs_counter>[0-9a-fA-F]{2})';
activity_id          = '(?<activity_id>[a-zA-Z]{2})';
activity_macro_num   = '(?<activity_macro_num>[0-9]{3})';
sensor_id            = '(?<sensor_id>[sljSLJ]{1})';
vr                   = '(?<version>[0-9a-zA-Z]{1})';
% yyyy_doy             = '(?<yyyy_doy>[0-9]{4}_[0-9]{3})';

ext   = '';
dwld  = 0;
overwrite  = false;
index_cache_update = false;
verbose = false;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'OBS_CLASS_TYPE'
                obs_class_type = varargin{i+1};
            case 'OBS_COUNTER'
                obs_counter = varargin{i+1};
            case 'ACTIVITY_ID'
                activity_id = varargin{i+1};
            case 'ACTIVITY_MACRO_NUM'
                activity_macro_num = varargin{i+1};
            case 'SENSOR_ID'
                sensor_id = varargin{i+1};
            % case 'YYYY_DOY'
            %     yyyy_doy = varargin{i+1};
            case 'VERSION'
                vr = varargin{i+1};
            case {'EXT','EXTENSION'}
                ext = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case 'INDEX_CACHE_UPDATE'
                index_cache_update = varargin{i+1};
            case 'VERBOSE'
                verbose = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});   
        end
    end
end

if isempty(obs_class_type)
    [ yyyy_doy,obs_class_type ] = crism_searchOBSID2YYYY_DOY_v2(obs_id);
end

prop_search = crism_create_propOBSbasename( ...
    'OBS_CLASS_TYPE', obs_class_type, 'OBS_ID',obs_id,'ACTIVITY_ID',activity_id, ...
    'ACTIVITY_MACRO_NUM',activity_macro_num, 'OBS_COUNTER',obs_counter, ...
    'SENSOR_ID',sensor_id,'product_type',product_type,'VERSION', vr);

[dir_info,basenames,fnamewext_local] = crism_search_observation_fromProp(...
    prop_search,'Dwld',dwld,'Match_Exact',true, ...
    'EXT', ext,'INDEX_CACHE_UPDATE',index_cache_update, ...
    'overwrite',overwrite,'CellOutput',true,'VERBOSE',verbose);

search_result = [];
search_result.dir_info = dir_info;
search_result.basenames = basenames;
search_result.fnamewext_local = fnamewext_local;

if ~isempty(basenames)
    % props = cellfun(@(x) crism_getProp_basenameOBSERVATION(x), basenames);
    props = crism_getProp_basenameOBSERVATION(basenames);
    props = [props{:}];
    [obscntrs_unq,~,ic_obscntrs] = unique({props.obs_counter});
    obscntrs_unq = sort(obscntrs_unq);
    sgmnt_info = [];
    for i_sgid=1:length(obscntrs_unq)
        obscntr_i = upper(obscntrs_unq{i_sgid});
        sgmnt_info(i_sgid).obs_counter = obscntr_i;
        idxBool_i = (ic_obscntrs==i_sgid);
        props_i = props(idxBool_i);
        basenames_i = basenames(idxBool_i);
        [sensids_unq,~,jc_sensid] = unique({props_i.sensor_id});
        sgmnt_info(i_sgid).sensor_id = sensids_unq;
        for j=1:length(sensids_unq)
            sensid_j = upper(sensids_unq{j});
        % search_result.(sensid_i) = [];
            sgmnt_info(i_sgid).(sensid_j) = [];
            idxBool_j = (jc_sensid==j);
            props_ij = props_i(idxBool_j);
            actids_ij = {props_ij.activity_id};
            actids_unq = unique(actids_ij);
            sgmnt_info(i_sgid).(sensid_j).activity_id = actids_unq;
            basenames_ij = basenames_i(idxBool_j);
            [pdtype_unq,~,kc_pdtype] = unique({props_ij.product_type});
            for k=1:length(pdtype_unq)
                pdtype_k = upper(pdtype_unq{k});
                if strcmp(pdtype_k,'HKP')   
                    basenames_ijk = basenames_ij(kc_pdtype==k);
                    sgmnt_info(i_sgid).(sensid_j).(pdtype_k) = basenames_ijk;
                else % case {'edr','trr','ter','mtr','ddr'}
                    idxBool_k  = (kc_pdtype==k);
                    props_ijk  = props_ij(idxBool_k);
                    actids_ijk = {props_ijk.activity_id};
                    actmns_ijk = [props_ijk.activity_macro_num];
                    sgmnt_info(i_sgid).activity_macro_num = unique(actmns_ijk);
                    [actids_k_unq,~,lc_actids_k] = unique(actids_ijk);
                    basenames_ijk = basenames_ij(idxBool_k);
                    for l=1:length(actids_k_unq)
                        sgmnt_info(i_sgid).(sensid_j).(actids_k_unq{l}) = basenames_ijk(lc_actids_k==l);
                    end
                end
            end
        end
        
    end
    search_result.sgmnt_info = sgmnt_info;
else
    search_result.sgmnt_info = [];
end


end