function [ prop ] = create_propCDR6basename( varargin )
% [ prop ] = create_propCDR6basename( varargin )
%   return struct of CDR6 property
% 
%   Output
%   prop: struct storing properties
%    'level'                 : (default) 6
%    'partition'             : (default) '(?<partition>[\d]{1})'
%    'sclk'                  : (default) '(?<sclk>[\d]{10})'
%    'acro_calibration_type' : (default) '(?<acro_calibration_type>[a-zA-Z]{2})'
%    'sensor_id'             : (default) '(?<sensor_id>[sljSLJ]{1})'
%    'version'               : (default) '(?<version>[0-9]{1})'
%   Optional Parameters
%    'PARTITION', 'SCLK', 'Acro', 'SENSOR_ID', 'Version'
% 
%  Input Parameters
%   basenameCDR6: string, like
%     CDR6_P_tttttttttt_pp_n_v
%     P = partition of sclk time
%     tttttttttt = s/c start or mean time 
%     pp = calib. type from SIS table 2-8
%     n = sensor ID: S, L, or J
%     v = version
%  Output Parameters
%   prop: struct storing properties
%    'partition'
%    'sclk'
%    'acro_calibration_type'
%    'sensor_id'
%    'version'

level                 = 6;
partition             = '(?<partition>[\d]{1})';
sclk                  = '(?<sclk>[\d]{10})';
acro_calibration_type = '(?<acro_calibration_type>[a-zA-Z]{2})';
% frame_rate            = '(?<frame_rate>[0-4]{1})';
% binning               = '(?<binning>[0-3]{1})';
% exposure              = '(?<exposure>[0-9]{3})';
% wavelength_filter     = '(?<wavelength_filter>[0-3]{1})';
% side                  = '(?<side>[0-2]{1})';
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
prop.sensor_id = sensor_id;
prop.version = vr;

end