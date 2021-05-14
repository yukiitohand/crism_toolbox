function [prop]= create_propOTTbasename(varargin)

% [ prop ] = create_propOTTbasename( varargin )
%   return struct of the basename of OTT data
%  Output
%   prop: struct storing properties

%    'yyyy'             : (default) '(?<yyyy_doy>[\d]{4})'
%    'mm'               : (default) '(?<mm>[\d]{2})'
%    'dd'               : (default) '00'
%
%   Optional Parameters
%    'OBS_CLASS_TYPE', 'OBS_ID', 'OBS_COUNTER', 'ACTIVITY_ID', 'ACTIVITY_MACRO_NUM', 'PRODUCT_TYPE',
%    'SENSOR_ID', 'VERSION'
% 
%  * Reference *
%   basename: string, like
%     OBS_ID_yyyy_mm_dd
%     yyyy = year
%     mm   = month
%     dd   = day

yyyy             = '(?<yyyy>[\d]{4})';
mm               = '(?<mm>[\d]{2})';
dd               = '00';

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'YYYY'
                yyyy = varargin{i+1};
            case 'MM'
                mm = varargin{i+1};
            case 'DD'
                dd = varargin{i+1};
             otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);   
        end
    end
end

if isnumeric(yyyy)
    yyyy = sprintf('%4d',yyyy);
end
if isnumeric(mm)
    mm = sprintf('%02d',mm);
end
if isnumeric(dd)
    dd = sprintf('%02d',dd);
end

prop = [];
prop.yyyy = yyyy;
prop.mm = mm;
prop.dd = dd;

end