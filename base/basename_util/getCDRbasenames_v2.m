function [basenameList,pdir] = getCDRbasenames_v2(prop)
% [] = getCDR4basenames(varargin)
%   Get the basename of the CDR/(acro) files.
%   Input Parameters
%     prop: property struct for the CDR file
%     basenameList: cell array, list of the basenames
%     pdir: directory of the specified CDR data (below PDS)

basenameWAPtr = get_basenameCDR4_fromProp(prop);
pdir = get_dirpath_cdr_fromProp(prop);

fnamelist = dir(pdir);
fnamelist = {fnamelist.name};

[basenameList] = extractMatchedBasename_v2(basenameWAPtr,fnamelist);


end
