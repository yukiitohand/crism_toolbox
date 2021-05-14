function [prop] = getProp_basenameOTT(basenameOTT)
% [prop] = getProp_basenameOTT(basenameOTT)
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
[ prop_ori ] = create_propOTTbasename();
[basenameptrn] = get_basenameOTT_fromProp(prop_ori);

prop = regexpi(basenameOTT,basenameptrn,'names');

end
