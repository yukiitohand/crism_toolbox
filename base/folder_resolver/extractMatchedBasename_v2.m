function [basename] = extractMatchedBasename_v2(basenamePtr,fnamelist,varargin)
% [basename] = extractMatchedBasename_v2(basenamePtr,fnamelist,varargin)
%   match the pattern to filenames in fnamelist
%
%  INPUTS
%    basenamePtr: pattern input for regexpi
%    fnamelist  : cell array of filenames (with or without extensions)
%  OUTPUTS
%    basename: string or cell array of matched basenames
%  Optional Parameters
%      'MATCH_EXACT'    : binary, if basename match should be exact match
%                         or not.
%                         (default) false

is_exact = false;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'EXACT'
                is_exact = varargin{i+1};
            otherwise
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end


if isempty(fnamelist)
    basename = '';
else
    if is_exact
        basenamePtr = ['^' basenamePtr '[[.][a-zA-Z]]*$'];
    end
    matching = cellfun(@(x) ~isempty(regexpi(x,basenamePtr,'ONCE')),fnamelist);
    if sum(matching)>0
        match_fnames = fnamelist(matching);
        basenameList = cell(1,length(match_fnames));
        for i=1:length(match_fnames)
            [~,basename,ext] = fileparts(match_fnames{i});
            basenameList{i} = basename;            
        end
        basename = unique(basenameList);
        if length(basename)==1
            basename = basename{1};
        end
    else
        basename = '';
    end
end
end