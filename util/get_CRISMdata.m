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
%   'VERSION' : version of the data to be returned
%     (default) []
%   'IS_DDR' : If it is ddr, return CRISMDDRdata obj
%     (default) 0

idx = [];
obs_counter = '';
vr = [];
is_ddr = 0;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'IDX'
                idx = varargin{i+1};
            case 'OBS_COUNTER'
                obs_counter = varargin{i+1};
            case 'VERSION'
                vr = varargin{i+1};
            case 'IS_DDR'
                is_ddr = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

if is_ddr
    class_crismdata = @CRISMDDRdata;
else
    class_crismdata = @CRISMdata;
end

if ~isempty(basename) 
    if ischar(basename) && (ischar(dirpath) || isempty(dirpath))
        crismdata_obj = class_crismdata(basename,dirpath);
    elseif iscell(basename)
        if isempty(idx)
            idx = 1:length(basename);
        end
        crismdata_obj = [];
        for i=idx
            if ischar(dirpath) || isempty(dirpath)
                crismdata_obji = class_crismdata(basename{i},dirpath);
            elseif iscell(dirpath)
                crismdata_obji = class_crismdata(basename{i},dirpath{i});
            else
                error('dirpath may be something wrong.');
            end
            if isempty(vr)
                crismdata_obj = [crismdata_obj crismdata_obji];
            else
                if crismdata_obji.prop.version==vr
                    crismdata_obj = [crismdata_obj crismdata_obji];
                end
            end
        end
    else
        error('basename is something wrong.');
    end
else
    crismdata_obj = [];
end

% check the observation counter is correct

end

