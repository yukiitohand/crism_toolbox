function [basenameOTT] = crism_get_basenameOTT_fromProp(prop)
% [basenameOTT] = crism_get_basenameOTT_fromProp(prop)
%  Input Parameters
%   prop: struct storing properties
%    'yyyy', 'mm', 'dd'       
%  Output Parameters
%   basename: string, like
%     OBS_ID_yyyy_mm_dd
%     yyyy = year
%     mm   = month
%     dd   = day

yyyy = prop.yyyy;
mm = prop.mm;
dd = prop.dd;


if isnumeric(yyyy)
    yyyy = sprintf('%04d',yyyy);
end

if isnumeric(mm)
    mm = sprintf('%02d',mm);
end

if isnumeric(dd)
    dd = sprintf('%02d',dd);
end 

basenameOTT = sprintf('OBS_ID_%s_%s_%s',yyyy,mm,dd);

end