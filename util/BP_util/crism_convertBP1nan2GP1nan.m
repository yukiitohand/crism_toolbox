function [GP1nan] = crism_convertBP1nan2GP1nan(BP1nan)
% [GP1nan] = crism_convertBP1nan2GP1nan(BP1nan)
%  Convert BP1nan to GP1nan
%  INPUT
%   BP1nan: any array of BP (1-nan formulation)
%       BPs are filled with 1s and non-BPs are with NaNs
%  OUTPUT
%   GP1nan: flipped version of BP1nan
%       NaNs in the BP1nan is replaced with 1s and 1s in the BP1nan is
%       replaced with NaNs.

GP1nan = nan(size(BP1nan));
GP1nan(isnan(BP1nan)) = 1;

end