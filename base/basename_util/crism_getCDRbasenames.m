function [basenameList,pdir] = crism_getCDRbasenames(acro,varargin)
% [basenameList,pdir] = crism_getCDRbasenames(acro,varargin)
%   Get the basename of the CDR/(acro) files.
%   Input Parameters
%     acro: acronym for the CDR data, such as WA, SB etc.,...
%   Optional Input Parameters
%     'WV_BIN': pattern for regular expression, binning mode
%               (default) '0'
%     'SENSOR_ID': pattern for regular expression, sensor_id
%                  (default) 'L'
%     'LEVEL': pattern for regular expression, level of the product
%              (default) '3'
%   Output Parameters
%     basenameList: cell array, list of the basenames
%     pdir: directory of the specified CDR data (below PDS)
global localCRISM_PDSrootDir

binning = '0';
sensor_id = 'L';
level = '3';

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'BINNING'
                binning = varargin{i+1};
                if isnumeric(binning)
                    binning = num2str(binning);
                end
            case 'SENSOR_ID'
                sensor_id = varargin{i+1};
            case 'LEVEL'
                level = varargin{i+1};
                if isnumeric(level)
                    level = num2str(level);
                end
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

pdir = joinPath(localCRISM_PDSrootDir,'utopia.jhuapl.edu/flight/crism_pds_archive/edr/CDR/',acro);

if ~exist(pdir,'dir')
    error('Path\n%s\n does not exist. Maybe wrong acro=%s',pdir,acro);
end
%% get the file names
fileList = dir(pdir);
basenameList = {};
for i=1:length(fileList)
    file = fileList(i);
    if ~file.isdir
        [~,basename,ext] = fileparts(file.name);
        if ~any(cellfun(@(x) strcmpi(x,basename),basenameList))
            if ~isempty(regexpi(basename(20),binning,'ONCE')) % binning mode
                if ~isempty(regexpi(basename(26),sensor_id,'ONCE')) % sensor_id
                    if ~isempty(regexpi(basename(28),level,'ONCE')) % level
                        basenameList = [basenameList {basename}];
                    end
                end
            end
        end
    end
end

if isempty(basenameList)
    error('there is no data that match binning_mode=%s,sensor_id=%s,level:%s. Please check the folder %s',...
        binning,sensor_id,level,pdir);
end

end
