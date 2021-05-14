function [binx] = crism_get_binning(binning_id)
% [binx] = crism_get_binning(binning_id)
% 
if isnumeric(binning_id)
   binning_id = num2str(binning_id);
end
switch binning_id
    case '0'
        binx = 1;
    case '1'
        binx = 2;
    case '2'
        binx = 5;
    case '3'
        binx = 10;
    case '4'
        binx = 'none';
    otherwise
        error('Invalid binning_id %s.',binning_id);
end

end