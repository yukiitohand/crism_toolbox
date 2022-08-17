function [meaning] = crism_DM_ind2meaning(dm_id)

switch dm_id
    case 0
        meaning = 'no data';
    case 1
        meaning = 'scene';
    case 2
        meaning = 'dark';
    case 3
        meaning = 'dark/scatter transition';
    case 4
        meaning = 'scattered light';
    case 5
        meaning = 'scatter/scene transition';
    case 6
        meaning = 'scene/dark transition';
    case 7
        meaning = 'row 0';
    otherwise 
        error('detector mack id %d is not defined',dm_id);
end