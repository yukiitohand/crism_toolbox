function [basenameList,pdir] = crism_getCDRbasenames_v2(prop)
% [basenameList,pdir] = crism_getCDRbasenames_v2(prop)
%   Get the basename of the CDR/(acro) files.
%   Input Parameters
%     prop: property struct for the CDR file
%     basenameList: cell array, list of the basenames
%     pdir: directory of the specified CDR data (below PDS)

basenamePtr = crism_get_basenameCDR4_fromProp(prop);
[dir_info] = crism_search_observation_fromProp(prop);
pdir = dir_info.dirfullpath_local;

fnamelist = dir(pdir);
fnamelist = {fnamelist.name};

[basenameList] = extractMatchedBasename_v2(basenamePtr,fnamelist);


end
