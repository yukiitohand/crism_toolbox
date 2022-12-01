function [errcode] = mro_crism_validate_image_sample_size(TRRIFdata)
% [errcode] = mro_crism_validate_image_sample_size(TRRIFdata)
%   Check if the image has the right sample size

errcode = 0;
switch upper(TRRIFdata.prop.obs_class_type)
    case {'FRT','FRS','ATO','ATU'}
        if TRRIFdata.hdr.samples ~= 640
            fprintf(['%s: OBS_COUNTER=%s is not a central scan. ' ...
                     'Not a standard segment structure. \n'], ...
                     TRRIFdata.dirname,TRRIFdata.prop.obs_counter);
            errcode = 1;
        end
    case {'HRL','HRS'}
        if TRRIFdata.hdr.samples ~=320
            fprintf(['%s: OBS_COUNTER=%s is not a central scan. ' ...
                     'Not a standard segment structure. \n'], ...
                     TRRIFdata.dirname,TRRIFdata.prop.obs_counter);
            errcode = 1;
        end
    otherwise
        error('Unsupported class type %s',obs_class_type);
end

end