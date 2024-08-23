function [s_ref] = crism_get_boresight_sample_indx(sensor_id,binx)

switch upper(sensor_id)
    case 'S'
        s_ref = 326;
        % rounded the pixel indices at the boresight at band 39
        % (reference band in ik kernel)
    case 'L'
        s_ref = 334; 
        % rounded the pixel indices at the boresight at band 240
        % (reference band in ik kernel)
    otherwise
        error('Undefined sensor_id %s',sensor_id);
end

s_ref = round(s_ref/binx);

end