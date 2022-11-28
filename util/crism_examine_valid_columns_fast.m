function [valid_samples_bool] = crism_examine_valid_columns_fast(binning_id,sensor_id)
% [valid_samples] = crism_examine_valid_columns_fast(binnin_id)
% examine valid samples from Detector mask
% Input parameters
%    binnin_id: 0-4
%    sensor_id: 'S' or 'L'
% Output parameters
%    valid_columns: boolean, ith element is true if the columns is scene
%                   pixel.

% examine valid columns from the detector mask

switch upper(sensor_id)
    case 'L'
        switch binning_id
            case 0
                valid_samples_bool = false(1,640);
                valid_samples_bool(30:633) = true;
            case 1
                valid_samples_bool = false(1,320);
                valid_samples_bool(16:316) = true;
            case 2
                valid_samples_bool = false(1,128);
                valid_samples_bool(7:126) = true;
            case 3
                valid_samples_bool = false(1,64);
                valid_samples_bool(4:63) = true;
            otherwise
                error('Binning ID %d is out of range (should be 0-3).',binning_id);
        end
    case 'S'
        switch binning_id
            case 0
                valid_samples_bool = false(1,640);
                valid_samples_bool(26:626) = true;
            case 1
                valid_samples_bool = false(1,320);
                valid_samples_bool(14:313) = true;
            case 2
                valid_samples_bool = false(1,128);
                valid_samples_bool(7:125) = true;
            case 3
                valid_samples_bool = false(1,64);
                valid_samples_bool(4:62) = true;
            otherwise
                error('Binning ID %d is out of range (should be 0-3).',binning_id);
        end
    otherwise
        error('Sensor_id %s is undefined (must be S or L)', sensor_id);
end
% vs_idx = find(valid_samples);

end