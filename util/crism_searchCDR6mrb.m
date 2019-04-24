function [CDR6data] = crism_searchCDR6mrb(acro,sclk,varargin)
% [CDR6data] = crism_searchCDR6mrb(acro,sclk,varargin)
%   search most recent before CDR6 using sclk
%  INPUTS
%   acro:
%   sclk: 
%  OUTPUtS
%   CDR6data: CRISMdata obj
%  OPTIONAL parameters
%   'partition'
%   'sensor_id'
%   'version'
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false

partition = '(?<partition>[\d]{1})';
sensor_id = '(?<sensor_id>[sljSLJ]{1})';
vr = '(?<version>[0-9]{1})';
dwld = 0;
force = false;
outfile = '';
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'PARTITION'
                partition = varargin{i+1};
            case 'SENSOR_ID'
                sensor_id = varargin{i+1};
            case 'VERSION'
                vr = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case {'FORCE','FORCE_DWLD'}
                force = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            otherwise
                error('Undefined keyword %s',varargin{i});
        end
    end
end

propCDR6ref = create_propCDR6basename('acro',acro,'sclk',sclk,'version',vr,...
    'partition',partition','sensor_id',sensor_id);
[basenameCDR6mrb] = crism_searchCDRmrb(propCDR6ref,'dwld',dwld,...
    'force',force,'out_file',outfile);
if ~isempty(basenameCDR6mrb)
    if ischar(basenameCDR6mrb)
        CDR6data = CRISMdata(basenameCDR6mrb,'');
    elseif iscell(basenameCDR6mrb)
        CDR6data = [];
        for i=1:length(basenameCDR6mrb)
            CDR6datai = CRISMdata(basenameCDR6mrb{i},'');
            CDR6data = [CDR6data CDR6datai];
        end
    end
end

end