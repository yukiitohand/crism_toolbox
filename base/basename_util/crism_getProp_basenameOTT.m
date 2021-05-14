function [prop] = crism_getProp_basenameOTT(basenameOTT)
% [prop] = crism_getProp_basenameOTT(basenameOTT)
%   Get properties from the basename of OTT file
%  Input Parameters
%   basename: string, like
%     OBS_ID_yyyy_mm_dd
%     yyyy = year
%     mm   = month
%     dd   = day
%  Output Parameters
%   prop: struct storing properties
%     'yyyy' : year
%     'mm'   : month
%     'dd'   : day
[ prop_ori ]   = crism_create_propOTTbasename();
[basenameptrn] = crism_get_basenameOTT_fromProp(prop_ori);

prop = regexpi(basenameOTT,basenameptrn,'names');

end
