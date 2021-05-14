function [frame_rate_id] = crism_get_frame_rate_id(frame_rateHz)
% [frame_rate_id] = crism_get_frame_rate_id(frame_rateHz)
% crism_get_frame_rate_id from given frame_rate

%   rate  rateHz[Hz]
%      0       1
%      1    3.75
%      2       5
%      3      15
%      4      30

switch frame_rateHz
    case 1
        frame_rate_id = 0;
    case 3.75
        frame_rate_id = 1;
    case 5
        frame_rate_id = 2;
    case 15
        frame_rate_id = 3;
    case 30
        frame_rate_id = 4;
    otherwise
        error('Invalid frame_rate %f.',frame_rateHz);
end

end