function [ prop ] = create_propADRVSbasename( varargin )
% [ prop ] = create_propADRVSbasename( varargin )
%   return struct of ADR VS data property
% 
%   Output
%   prop: struct storing properties
%    'partition'             : (default) '(?<partition>[\d]{1})'
%    'sclk'                  : (default) '(?<sclk>[\d]{10})'
%    'obs_id_short'          : (default) '(?<obs_id_short>[0-9a-zA-Z]{5})'
%    'acro_calibration_type' : 'VS'
%    'binning'               : (default) '(?<binning>[0-3]{1})'
%    'wavelength_filter'     : (default) '(?<wavelength_filter>[0-3]{1})'
%    'sensor_id'             : (default) '(?<sensor_id>[sljSLJ]{1})'
%    'version'               : (default) '(?<version>[0-9]{1})'
%   Optional Parameters
%    'PARTITION', 'SCLK', 'Acro', 'FRAME_RATE', 'OBS_ID', 'BINNING',
%    'WAVELENGTH_FILTER', 'SENSOR_ID', 'Version'
% 
%  * Reference *
%   basenameADRVS: string, like
%     ADRPtttttttttt_nnnnn_VSbwn_v
%     P = partition of sclk time
%     tttttttttt = s/c start or mean time 
%     nnnnn = shortend observation id associated with this data
%     b = binning identifier, 0-3
%     w = wavelength filter, 0-3
%     n = sensor ID: S, L, or J
%     v = version

acro_calibration_type = 'VS';
partition             = '(?<partition>[\d]{1})';
sclk                  = '(?<sclk>[\d]{10})';
obs_id_short          = '(?<obs_id_short>[0-9a-zA-Z]{5})';
binning               = '(?<binning>[0-3]{1})';
wavelength_filter     = '(?<wavelength_filter>[0-3]{1})';
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
            case 'OBS_ID_SHORT'
                obs_id_short = varargin{i+1};
                if length(obs_id)>5
                    error('Specify with OBS_ID');
                end
            case 'BINNING'
                binning = varargin{i+1};
            case 'WAVELENGTH_FILTER'
                wavelength_filter = varargin{i+1};
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
prop.partition = partition;
prop.sclk = sclk;
prop.obs_id_short = obs_id_short;
prop.acro_calibration_type = acro_calibration_type;
prop.binning = binning;
prop.wavelength_filter = wavelength_filter;
prop.sensor_id = sensor_id;
prop.version = vr;

end