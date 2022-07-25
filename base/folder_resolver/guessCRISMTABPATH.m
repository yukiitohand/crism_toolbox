function [tabPath] = guessCRISMTABPATH(basename,dirPath,varargin)
% [tabPath] = guessCRISMTABPATH(basename,dirPath,varargin)
% Input Parameters
%   basename: string, basename of the TAB file
%   dirPath: string, directory path in which the TAB file is stored.
% Output Parameters
%   lblPath: full file path to the table file
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

tabname = [basename '.tab'];
[tabname] = findfilei(tabname,dirPath);
if isempty(tabname) 
    if iswarning
        warning('TAB file cannot be found');
    end
    tabPath = '';
else
    if iscell(tabname)
        if all(strcmpi(tabname{1},tabname))
            tabname = tabname{1};
        else
            error('Ambiguity error. Multiple TAB files are detected.');
        end
    end
    tabPath = fullfile(dirPath,tabname);
end

% if ismac || ispc
%     tabPath = joinPath(dirPath,[basename '.tab']);
%     if ~exist(tabPath,'file') 
%         if iswarning
%             warning('TAB file cannot be found.');
%         end
%         tabPath = '';
%     end
% elseif isunix
%     tabname = [basename '.tab'];
%     [tabname] = findfilei(tabname,dirPath);
%     if isempty(tabname) 
%         if iswarning
%             warning('TAB file cannot be found');
%         end
%         tabPath = '';
%     else
%         if iscell(tabname)
%             if all(strcmpi(tabname{1},tabname))
%                 tabname = tabname{1};
%             else
%                 error('Ambiguity error. Multiple TAB files are detected.');
%             end
%         end
%         tabPath = joinPath(dirPath,tabname);
%     end
% end

end