function [GP1nan] = convertBP1nan2GP1nan(BP)

GP1nan = nan(size(BP));
GP1nan(isnan(BP)) = 1;

end