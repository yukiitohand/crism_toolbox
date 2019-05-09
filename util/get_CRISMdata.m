function [crismdata_obj] = get_CRISMdata(basename,dirpath,varargin)
% [crismdata_obj] = get_CRISMdata(basename,dirpath)
% Usage 
% [crismdata_obj] = get_CRISMdata(basename,dirpath);
% [crismdata_obj] = get_CRISMdata(basename,dirpath,'IDX',idx);
% Load CRISMdata obj for given 'basename'.
% INPUTS
%  basename: basename of the CRISM data or cell array of basenames
%  dirpath : char, path to the datafie. If this is empty, dirpath is
%            guessed. You can input cell array of dirpath when basename is
%            a cell array
%  OUTPUTS
%  crismdata_obj: CRISMdata obj or an array of it, empty array if basename
%                 is empty.
%  OPTIONAL PARAMETERS
%   'IDX': index to be loaded in case basename is a cell array
%     (default) []
%   'OBS_COUNTER': future implementation

idx = [];
obs_counter = '';
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'IDX'
                idx = varargin{i+1};
            case 'OBS_COUNTER'
                obs_counter = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

if ~isempty(basename) 
    if ischar(basename) && (ischar(dirpath) || isempty(dirpath))
        crismdata_obj = CRISMdata(basename,dirpath);
    elseif iscell(basename)
        if isempty(idx)
            idx = 1:length(basename);
        end
        crismdata_obj = [];
        for i=idx
            if ischar(dirpath) || isempty(dirpath)
                crismdata_obji = CRISMdata(basename{i},dirpath);
            elseif iscell(dirpath)
                crismdata_obji = CRISMdata(basename{i},dirpath{i});
            else
                error('dirpath may be something wrong.');
            end
            crismdata_obj = [crismdata_obj crismdata_obji];
        end
    else
        error('basename is something wrong.');
    end
else
    crismdata_obj = [];
end

% check the observation counter is correct

end

