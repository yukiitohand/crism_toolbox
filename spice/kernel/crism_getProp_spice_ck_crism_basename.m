function [prop] = crism_getProp_spice_ck_crism_basename(basename_ck)
% [prop] = crism_getProp_spice_ck_crism_basename(basename_ck)
% Interpret the following type of filename:
%   spck_2008_184_r_1.bc
% INPUTS
%  basename_ck: basename like 'spck_2008_184_r_1.bc'
% OUTPUTS
%  prop: property struct with two fields yyyy and doy
%


bname_ptrn = 'spck_(?<yyyy>\d{4})_(?<doy>\d{3})_r_1\.bc';

prop = regexpi(basename_ck,bname_ptrn,'names');

if ~isempty(prop)
    prop.yyyy = str2double(prop.yyyy);
    prop.doy  = str2double(prop.doy);
end

end