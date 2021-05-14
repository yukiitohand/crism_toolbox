function [ prop ] = create_propCDR4basename( varargin )
% [ prop ] = create_propCDR4basename( varargin )
%   return struct of CDR4 property
% 
%   Output
%   prop: struct storing properties
%    'level'                 : (default) 4
%    'partition'             : (default) '(?<partition>[\d]{1})'
%    'sclk'                  : (default) '(?<sclk>[\d]{10})'
%    'acro_calibration_type' : (default) '(?<acro_calibration_type>[a-zA-Z]{2})'
%    'frame_rate'            : (default) '(?<frame_rate>[0-4]{1})'
%    'binning'               : (default) '(?<binning>[0-3]{1})'
%    'exposure'              : (default) '(?<exposure>[0-9]{3})'
%    'wavelength_filter'     : (default) '(?<wavelength_filter>[0-3]{1})'
%    'side'                  : (default) '(?<side>[0-2]{1})'
%    'sensor_id'             : (default) '(?<sensor_id>[sljSLJ]{1})'
%    'version'               : (default) '(?<version>[0-9]{1})'
%   Optional Parameters
%    'PARTITION', 'SCLK', 'Acro', 'FRAME_RATE', 'BINNING', 'EXPOSURE',
%    'WAVELENGTH_FILTER', 'SIDE', 'SENSOR_ID', 'Version'
% 
%  * Reference *
%   basenameCDR4: string, like
%     CDR4Ptttttttttt_pprbeeewsn_v
%     P = partition of sclk time
%     tttttttttt = s/c start or mean time 
%     pp = calib. type from SIS table 2-8
%     r = frame rate identifier, 0-4
%     b = binning identifier, 0-3
%     eee = exposure time parameter, 0-480 
%     w = wavelength filter, 0-3
%     s = side: 1 or 2, or 0 if N/A
%     n = sensor ID: S, L, or J
%     v = version

level                 = 4;
partition             = '(?<partition>[\d]{1})';
sclk                  = '(?<sclk>[\d]{10})';
acro_calibration_type = '(?<acro_calibration_type>[a-zA-Z]{2})';
frame_rate            = '(?<frame_rate>[0-4]{1})';
binning               = '(?<binning>[0-3]{1})';
exposure              = '(?<exposure>[0-9]{3})';
wavelength_filter     = '(?<wavelength_filter>[0-3]{1})';
side                  = '(?<side>[0-2]{1})';
sensor_id             = '(?<sensor_id>[sljSLJ]{1})';
vr                    = '(?<version>[0-9]{1})';

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'PARTITION'
                partition = varargin{i+1};
            case 'SCLK'
                sclk = varargin{i+1};
            case 'ACRO'
                acro_calibration_type = varargin{i+1};
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
            case 'SENSOR_ID'
                sensor_id = varargin{i+1};
            case 'VERSION'
                vr = varargin{i+1};
             otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);   
        end
    end
end

prop = [];
prop.level = level;
prop.partition = partition;
prop.sclk = sclk;
prop.acro_calibration_type = acro_calibration_type;
prop.frame_rate = frame_rate;
prop.binning = binning;
prop.exposure = exposure;
prop.wavelength_filter = wavelength_filter;
prop.side = side;
prop.sensor_id = sensor_id;
prop.version = vr;

end

