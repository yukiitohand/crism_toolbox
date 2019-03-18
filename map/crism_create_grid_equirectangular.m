function [latitude_MAP,longitude_MAP,latNS,lonEW] = crism_create_grid_equirectangular(latd0,range_latd,range_lond,varargin)

pixel_size = 18;
rMars = 3396190.0; 

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'PIXEL_SIZE'
                pixel_size = varargin{i+1};
            case 'RMARS'
                rMars = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

% radius of Mars in Meter.
[latitude_MAP,longitude_MAP,latNS,lonEW] = create_grid_equirectangular(rMars,latd0,range_latd,range_lond,pixel_size);


end