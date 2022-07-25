function [obs_counter_ptrn_struct] = crism_get_obs_counter_ptrn_struct(obs_class_type)

obs_counter_ptrn_struct = [];
switch obs_class_type
    case {'FRT','HRL','HRS'}
        obs_counter_ptrn_struct.central_scan    = '07';
        obs_counter_ptrn_struct.central_scan_df = '0[68]{1}';
        obs_counter_ptrn_struct.epf             = '0[1-59A-D]{1}';
        obs_counter_ptrn_struct.epfdf           = '0[0E]{1}';
        
    case {'FRS','ATO'}
        obs_counter_ptrn_struct.central_scan    = '01';
        obs_counter_ptrn_struct.central_scan_df = '0[03]{1}';
        obs_counter_ptrn_struct.un              = '0[24]{1}';

    case 'FFC'
        obs_counter_ptrn_struct.central_scan    = '0[13]{1}';
        obs_counter_ptrn_struct.central_scan_df = '0[024]{1}';
        % this could be switched.
        
    case {'MSP','HSP'}
        obs_counter_ptrn_struct.central_scan    = '01';
        obs_counter_ptrn_struct.central_scan_df = '0[02]{1}';
        
    case 'CAL'
        obs_counter_ptrn_struct.bi = '[0-9a-fA-F]{2}';

    case 'ICL'
        obs_counter_ptrn_struct.sp = '[0-9a-fA-F]{2}';
        obs_counter_ptrn_struct.df = '[0-9a-fA-F]{2}';

    otherwise
        error('OBS_TYPE %s is not supported yet.',obs_class_type);

end

end
