function [rateHz] = crism_get_frame_rate(rate)
% [rateHz] = crism_get_frame_rate(rate)
%  get rate [Hz] from the index of each rate
%  Input Parameters
%    rate: integer, 0-4
%  Output Parameters
%    rateHz: frequency [Hz]
%  Detail
%   rate  rateHz[Hz]
%      0       1
%      1    3.75
%      2       5
%      3      15
%      4      30
rateHz = nan(size(rate));
rateHz(rate==0) = 1;
rateHz(rate==1) = 3.75;
rateHz(rate==2) = 5;
rateHz(rate==3) = 15;
rateHz(rate==4) = 30;
% switch int32(rate)
%     case 0
%         rateHz = 1;
%     case 1
%         rateHz = 3.75;
%     case 2
%         rateHz = 5;
%     case 3
%         rateHz = 15;
%     case 4
%         rateHz = 30;
%     otherwise
%         error('Undefined rate: %d.',rate);
% end

end

