function [source_obs_basenames] = crism_read_SOURCE_OBS_basenames(lbl)    
% read names of SOURCE OBSERVATIONS using lbl file.
source_obs_basenames = [];
for i=1:length(lbl.SOURCE_PRODUCT_ID)
    name = lbl.SOURCE_PRODUCT_ID{i};
    propOBS = crism_getProp_basenameOBSERVATION(name);
    if ~isempty(propOBS)
        activityID = propOBS.activity_id;
        source_obs_basenames = addField(source_obs_basenames,activityID,name);
    end
end

end
