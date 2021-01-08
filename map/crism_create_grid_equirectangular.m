function [latNS,lonEW] = crism_create_grid_equirectangular(range_latd,...
    range_lond,varargin)
% [latNS,lonEW] = crism_create_grid_equirectangular(range_latd,...
%     range_lond,varargin)
%   Create a grid
%  INPUTS
%   range_latd <degrees>: 2-length vector, 
%      [minimum latitude, maximum latitude]
%   range_lond <degrees>: 2-length vector, 
%      [westernmost longitude, easternmost latitude], unit - degree
%  OUTPUTS
%   latNS <degrees>: vector
%     list of the latitude of the center of image lines 1:end. Usually
%     maximum latitude comes first.
%   lonEW <degrees>: vector
%     list of the longitude of the center of image samples 1:end
%  Optional Parameters
%   "RMars" <meters>: radii of Mars, can be scalar or a vector with two or 
%      three elements. Namely, the following three types of inputs are 
%      acceptable.
%      - radius
%      - [equatorial radius, polar radius],
%      - [r1, r2, r3]: (future potential implementation) r1 is the largest
%        equatorial radius, the second is the smallest equatorial radius, 
%        the third is the polar radius. This mode is not implemented yet. 
%      (default) 3396190.0
%   "Pixel_Size" <meters>: scalar, size of a pixel, unit - meter
%      (default) 18.0
%   "ProjectionAlignment" : {'Individual','CutOff@Center'}
%     option for how to define the pixel centers.
%     'Individual' : [range_lond(1),range_latd(1)] becomes the coordinate
%     of the center of the lower left corner pixel.
%     'CutOff@Center' : center of the longitude and center of the latitude
%     becomes the border of the pixels. It is recommended to provide two
%     other optional parameters, "CenterLongitude" and "CenterLatitude"
%     (default) 'Individual'
%   "StandardParallel" <degrees>: projection center latitude at which the 
%     true pixel_size is achieved. With the mode 'CutOff@Center', from this
%     latitude pixels are gridded.
%     (default) 0 degree
%   "CenterLongitude" <degrees>: center of the longitude from which pixels 
%     are gridded. Only used with "ProjectionAlignment" = 'CutOff@Center'.
%     (default) 0 degree
%  

pixel_size = 18.0; % <meters>
% radius of Mars in Meter.
rMars = 3396190.0; % <meters>

proj_alignment    = 'Individual';
center_longitude  = 0;
standard_parallel = 0;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'PIXEL_SIZE'
                pixel_size = varargin{i+1};
            case 'RMARS'
                rMars = varargin{i+1};
            case 'PROJECTIONALIGNMENT'
                proj_alignment = varargin{i+1};
            case 'CENTERLONGITUDE'
                center_longitude = varargin{i+1};
            case 'STANDARDPARALLEL'
                standard_parallel = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end


[latNS,lonEW] = create_grid_equirectangular(...
    rMars,range_latd,range_lond,pixel_size,...
    'ProjectionAlignment',proj_alignment,...
    'StandardParallel',standard_parallel,...
    'CenterLongitude',center_longitude);


end