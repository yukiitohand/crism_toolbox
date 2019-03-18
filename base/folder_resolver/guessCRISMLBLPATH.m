function [lblPath] = guessCRISMLBLPATH(basename,dirPath,varargin)
% [lblPath] = guessCRISMLBLPATH(basename,dirPath,varargin)
% Input Parameters
%   basename: string, basename of the header file
%   dirPath: string, directory path in which the LBL file is stored.
% Output Parameters
%   lblPath: full file path to the lbl file
% Optional Parameters
%   'WARNING': whether or not to shown warning when the file is not exist
%              (default) false

iswarning = false;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'WARNING'
                iswarning = varargin{i+1};
        end
    end
end
if ismac || ispc
    lblPath = joinPath(dirPath,[basename '.lbl']);
    if ~exist(lblPath,'file') 
        if iswarning
            warning('LBL file cannot be found.');
        end
        lblPath = '';
    end
elseif isunix
    lblname = [basename '.lbl'];
    [lblname] = findfilei(lblname,dirPath);
    if isempty(lblname) 
        if iswarning
            warning('LBL file cannot be found');
        end
        lblPath = '';
    end
    if ~isempty(lblname)
        lblPath = joinPath(dirPath,lblname);
    end
end

end