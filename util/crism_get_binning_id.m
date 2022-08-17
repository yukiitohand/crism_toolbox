function [binning_id] = crism_get_binning_id(binx)
% [binning_id] = crism_get_binning_id(binx)
% 

switch binx
    case 1
        binning_id = 0;
    case 2
        binning_id = 1;
    case 5
        binning_id = 2;
    case 10
        binning_id = 3;
    otherwise
        error('Invalid binx %d.',binx);
end

end