
function [prop] = crism_getProp_spice_ck_crism_arch_basename(basename_a_ck)
% [prop] = crism_getProp_spice_ck_crism_arch_basename(basename_a_ck)
% Interpret the following type of filename:
%   mro_crm_psp_070512_070531.bc 
% INPUTS
%  basename_a_ck: basename like 'mro_crm_psp_070512_070531.bc'
% OUTPUTS
%  prop: property struct with two fields yymmdd_strt and yymmdd_end
%


bname_ptrn = 'mro_crm_(psp|cru)_(?<yymmdd_strt>\d{6})()_(?<yymmdd_end>\d{6})';

mtch = regexpi(basename_a_ck,bname_ptrn,'names');
prop = [];
if ~isempty(mtch)
    yymmdd_strt = sscanf(mtch.yymmdd_strt,'%02d%02d%02d');
    yy = 2000 + yymmdd_strt(1);
    dt_strt = datetime(yy,yymmdd_strt(2),yymmdd_strt(3));
    yymmdd_end = sscanf(mtch.yymmdd_end,'%02d%02d%02d');
    yy = 2000 + yymmdd_end(1);
    dt_end = datetime(yy,yymmdd_end(2),yymmdd_end(3));
    prop.start_time = dt_strt;
    prop.end_time   = dt_end;
end

end