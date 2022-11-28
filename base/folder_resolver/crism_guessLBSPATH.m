function [lbsPath] = crism_guessLBSPATH(basename,dirPath,varargin)
% [lbsPath] = crism_guessLBSPATH(basename,dirPath,varargin)
% Input Parameters
%   basename: string, basename of the header file
%   dirPath: string, directory path in which the header file is stored. if
%            empty, then './' will be set.
% Output Parameters
%   lbsPath: full file path to the header file
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

if isempty(dirPath)
    dirPath = './';
end

lbsname = [basename '.lbs'];
[lbsname] = findfilei(lbsname,dirPath);
if isempty(lbsname)
    lbsname = [basename '.img.lbs'];
    [lbsname] = findfilei(lbsname,dirPath);
end

if isempty(lbsname) 
    if iswarning
        warning('Header file cannot be found');
    end
    lbsPath = '';
else
    if iscell(lbsname)
        if all(strcmpi(lbsname{1},lbsname))
            lbsname = lbsname{1};
        else
            error('Ambiguity error. Multiple HDR files are detected.');
        end
    end
    lbsPath = fullfile(dirPath,lbsname);
end

% if ismac || ispc
%     hdrPath = joinPath(dirPath,[basename '.hdr']);
%     if ~exist(hdrPath,'file')
%         hdrPath = joinPath(dirPath,[basename '.img.hdr']);
%         if ~exist(hdrPath,'file') 
%             if iswarning
%                 warning('Header file cannot be found.');
%             end
%             hdrPath = '';
%         end
%     end
% elseif isunix
%     hdrname = [basename '.hdr'];
%     [hdrname] = findfilei(hdrname,dirPath);
%     if isempty(hdrname)
%         hdrname = [basename '.img.hdr'];
%         [hdrname] = findfilei(hdrname,dirPath);
%     end
%     
%     if isempty(hdrname) 
%         if iswarning
%             warning('Header file cannot be found');
%         end
%         hdrPath = '';
%     else
%         if iscell(hdrname)
%             if all(strcmpi(hdrname{1},hdrname))
%                 hdrname = hdrname{1};
%             else
%                 error('Ambiguity error. Multiple HDR files are detected.');
%             end
%         end
%         hdrPath = joinPath(dirPath,hdrname);
%     end
% end

end