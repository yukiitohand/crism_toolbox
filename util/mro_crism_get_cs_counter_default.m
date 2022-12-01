function [cs_counter] = mro_crism_get_cs_counter_default(obs_class_type)
% [cs_counter] = mro_crism_get_cs_counter_default(obs_class_type)
%   Get the observation counter of the central scan given an observation 
%   class type in the default setting.
%  INPUTS:
%    obs_class_type: 3-length character either of
%       {'FRT','HRL','HRS','FRS','ATO','ATU'}
%  OUTPUTS
%    cs_counter: character
%
switch upper(obs_class_type)
    case {'FRT','HRL','HRS'}
        cs_counter = '07';
    case {'FRS','ATO','ATU'}
        cs_counter = '01';
    otherwise
        error('Unsupported class type %s',obs_class_type);
end

end