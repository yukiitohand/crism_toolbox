function [errcode] = mro_crism_validate_image_sample_size(TRRIFdata)
% [errcode] = mro_crism_validate_image_sample_size(TRRIFdata)
%   Check if the image has the right sample size

errcode = 0;
switch upper(TRRIFdata.prop.obs_class_type)
    case {'FRT','FRS','ATO','ATU'}
        if TRRIFdata.hdr.samples ~= 640
            fprintf(['%3s%08s:%s: OBS_COUNTER=%s is not a central scan. ' ...
                     'Not a standard segment structure. \n'], ...
                     TRRIFdata.prop.obs_class_type,TRRIFdata.prop.obs_id, ...
                     TRRIFdata.prop.sensor_id,TRRIFdata.prop.obs_counter);
            errcode = 1;
        end
    case {'HRL','HRS'}
        if TRRIFdata.hdr.samples ~=320
            fprintf(['%3s%08s:%s: OBS_COUNTER=%s is not a central scan. ' ...
                     'Not a standard segment structure. \n'], ...
                     TRRIFdata.prop.obs_class_type,TRRIFdata.prop.obs_id, ...
                     TRRIFdata.prop.sensor_id,TRRIFdata.prop.obs_counter);
            errcode = 1;
        end
    otherwise
        error('%3s%08s:%s: Unsupported class type',TRRIFdata.prop.obs_class_type, ...
            TRRIFdata.prop.obs_id,TRRIFdata.prop.sensor_id);
end

end