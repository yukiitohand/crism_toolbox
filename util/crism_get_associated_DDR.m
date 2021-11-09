function [DEdata] = crism_get_associated_DDR(crismdata_obj,varargin)
% [DEdata] = crism_get_associated_DDR(crismdata_obj,varargin)
%   DDR image will be downloaded if it does not exist.
%  INPUTS
%    crismdata_obj: CRISMdata to which associated DDR are searched
%  OUTPUTS
%    DEdata: CRISMDDRdata class obj
%  Optional Parameters
%      'Version'     : Version of the DDR data.
%                  (default) 1
%

force_dwld = 1;
outfile    = '';
ext_ddr    = '';
dwld_index_cache_update = false;
dwld_overwrite          = false;
verbose = false;

vr = 1;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'VERSION'
                vr = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end
obs_classType = crismdata_obj.prop.obs_class_type;
obs_id        = crismdata_obj.prop.obs_id;
obs_counter   = crismdata_obj.prop.obs_counter;
sensor_id     = crismdata_obj.prop.sensor_id;

search_product_DDR = @(y_oc,w_dwld) crism_search_observation_fromProp(...
    crism_create_propOBSbasename('OBS_CLASS_TYPE',obs_classType,...
        'OBS_ID',obs_id,'ACTIVITY_ID','DE', 'OBS_COUNTER',y_oc,...
        'SENSOR_ID',sensor_id,'product_type','DDR','VERSION',vr),...
    'Dwld',w_dwld,'Match_Exact',true,'Force',force_dwld, ...
    'OUT_FILE',outfile,'Ext',ext_ddr,'INDEX_CACHE_UPDATE',dwld_index_cache_update, ...
    'overwrite',dwld_overwrite,'VERBOSE',verbose);

[dir_info,basenameDDR,fnameDDRwext_local] = search_product_DDR(obs_counter,1);

if isempty(basenameDDR)
    error('Cannot find the associated DDR.');
elseif ischar(basenameDDR)
    DEdata = CRISMDDRdata(basenameDDR,'');
    % Download the DDR image if missing.
    if ~any(cellfun(@(x) strcmpi([basenameDDR '.LBL'],x) ,fnameDDRwext_local)) ...
            || ~any(cellfun(@(x) strcmpi([basenameDDR '.IMG'],x) ,fnameDDRwext_local))
        DEdata.download(2);
    end
elseif iscell(basenameDDR)
    error('Multiple DDR files: \n %s\n are found.', join(crism_obs_interest.info.basenameDDR, '\n'));
else
    error('Cannot find the associated DDR.');
end



end

    