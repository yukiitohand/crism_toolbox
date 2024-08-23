function [prop] = crism_getProp_spice_ck_sc_basename_nonarchvr(basename_a_ck)
% [prop] = crism_getProp_spice_ck_crism_arch_basename_nonarchvr(basename_a_ck)
% Interpret the following type of filename:
%   mro_sc_2011-04-06.bc
% INPUTS
%  basename_a_ck: basename like 'mro_sc_2011-04-06.bc'
% OUTPUTS
%  prop: property struct with a field: time
%


% bname_ptrn = '^mro_sc_(psp|cru)_(?<yymmdd_strt>\d{6})()_(?<yymmdd_end>\d{6})';
bname_ptrn = '^mro_sc_(?<time>\d{4}-\d{2}-\d{2}).*';

prop = regexpi(basename_a_ck,bname_ptrn,'names','once');
if length(prop) == 1
    prop.time = datetime(prop.time,'InputFormat','uuuu-MM-dd');
elseif length(prop)>1
    for i=1:length(prop)
        if ~isempty(prop{i})
            prop{i}.time = datetime(prop{i}.time,'InputFormat','uuuu-MM-dd');
        end
    end
end


end