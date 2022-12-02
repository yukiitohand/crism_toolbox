
function [prop] = crism_getProp_spice_ck_sc_basename(basename_a_ck)
% [prop] = crism_getProp_spice_ck_crism_arch_basename(basename_a_ck)
% Interpret the following type of filename:
%   mro_sc_psp_070512_070531.bc 
% INPUTS
%  basename_a_ck: basename like 'mro_sc_psp_070512_070531.bc'
% OUTPUTS
%  prop: property struct with two fields yymmdd_strt and yymmdd_end
%


% bname_ptrn = '^mro_sc_(psp|cru)_(?<yymmdd_strt>\d{6})()_(?<yymmdd_end>\d{6})';
bname_ptrn = '^mro_sc_(psp|cru)_(?<start_time>\d{6})()_(?<end_time>\d{6})';

prop = regexpi(basename_a_ck,bname_ptrn,'names','once');
if length(prop) == 1
    yymmdd_strt = sscanf(prop.start_time,'%02d%02d%02d');
    yy = 2000 + yymmdd_strt(1);
    dt_strt = datetime(yy,yymmdd_strt(2),yymmdd_strt(3));
    yymmdd_end = sscanf(prop.end_time,'%02d%02d%02d');
    yy = 2000 + yymmdd_end(1);
    dt_end = datetime(yy,yymmdd_end(2),yymmdd_end(3));
    prop.start_time = dt_strt;
    prop.end_time   = dt_end;
elseif length(prop)>1
    for i=1:length(prop)
        if ~isempty(prop{i})
            yymmdd_strt = sscanf(prop{i}.start_time,'%02d%02d%02d');
            yy = 2000 + yymmdd_strt(1);
            dt_strt = datetime(yy,yymmdd_strt(2),yymmdd_strt(3));
            yymmdd_end = sscanf(prop{i}.end_time,'%02d%02d%02d');
            yy = 2000 + yymmdd_end(1);
            dt_end = datetime(yy,yymmdd_end(2),yymmdd_end(3));
            prop{i}.start_time = dt_strt;
            prop{i}.end_time   = dt_end;
        end
    end
end


end