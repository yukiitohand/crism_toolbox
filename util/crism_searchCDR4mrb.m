function [CDR4data] = crism_searchCDR4mrb(acro,sclk,varargin)
% [CDR4data] = crism_searchCDR4mrb(acro,sclk,varargin)
%   search most recent before CDR4 using sclk
%  INPUTS
%   acro:
%   sclk: 
%  OUTPUtS
%   CDR6data: CRISMdata obj
%  OPTIONAL parameters
%    'PARTITION', 'FRAME_RATE', 'BINNING', 'EXPOSURE',
%    'WAVELENGTH_FILTER', 'SIDE', 'SENSOR_ID', 'Version'
% 
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
frame_rate            = '(?<frame_rate>[0-4]{1})';
binning               = '(?<binning>[0-3]{1})';
exposure              = '(?<exposure>[0-9]{3})';
wavelength_filter     = '(?<wavelength_filter>[0-3]{1})';
side                  = '(?<side>[0-2]{1})';
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
            case 'FRAME_RATE'
                frame_rate = varargin{i+1};
            case 'BINNING'
                binning = varargin{i+1};
            case 'EXPOSURE'
                exposure = varargin{i+1};
            case 'WAVELENGTH_FILTER'
                wavelength_filter = varargin{i+1};
            case 'SIDE'
                side = varargin{i+1};
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

propCDR4ref = crism_create_propCDR4basename('acro',acro,'sclk',sclk,'version',vr,...
    'partition',partition','sensor_id',sensor_id,...
    'frame_rate',frame_rate,'binning',binning,'exposure',exposure,...
    'wavelength_filter',wavelength_filter,'side',side);
[basenameCDR4mrb] = crism_searchCDRmrb(propCDR4ref,'dwld',dwld,...
    'force',force,'out_file',outfile);
if ~isempty(basenameCDR4mrb)
    if ischar(basenameCDR4mrb)
        CDR4data = CRISMdata(basenameCDR4mrb,'');
    elseif iscell(basenameCDR4mrb)
        CDR4data = [];
        for i=1:length(basenameCDR4mrb)
            CDR4datai = CRISMdata(basenameCDR4mrb{i},'');
            CDR4data = [CDR4data CDR4datai];
        end
    end
end

end