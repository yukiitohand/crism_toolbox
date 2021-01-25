function [latNS,lonEW,lat_dstep,lon_dstep] = crism_create_grid_equirectangular(...
    range_latd,range_lond,varargin)
% [latNS,lonEW,lat_dstep,lon_dstep] = crism_create_grid_equirectangular(...
%     range_latd,range_lond,varargin)
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
%   lat_dstep <degrees>: 
%     step size of the latitude
%   lon_dstep <degrees>:
%     step size of the longitude
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
%   "ProjectionAlignment" : {'Individual','CutOff'}
%     option for how to define the pixel centers.
%     'Individual' : [range_lond(1),range_latd(1)] becomes the coordinate
%                    of the center of the lower left corner pixel.
%     'CutOff' : "CutOffLatitude" and "CutOffLongitude" becomes the border 
%                of the pixels. It is recommended to provide two other 
%                optional parameters, 
%                      "CutOffLatitude" and "CutOffLongitude"
%     (default) 'CutOff'
%   "StandardParallel" <degrees>: 
%     projection center planetocentric latitude  at which the true 
%     pixel_size is achieved. 
%     (default) 0 degree
%   "CenterLongitude" <degrees>: 
%     center of the longitude at which local radius is calculated. 
%     Currently, no effect.
%     (default) 0 degree
%   "CenterLatitude" <degrees>: 
%     center of the latitude at which local radius is calculated.
%     (default) same as "standard_parallel"
%   "CutOffLatitude" <degrees>: 
%     only used with the mode 'CutOff'. Pixel grid is created so that this 
%     laitude becomes a pixel border.
%     (default) 0 degree
%   "CutOffLongitude" <degrees>: 
%     only used with the mode 'CutOff'. Pixel grid is created so that this 
%     longitude becomes a pixel border.
%     (default) 0 degree
%  


pixel_size = 18.0; % <meters>
% radius of Mars in Meter.
rMars = 3396190.0; % <meters>

proj_alignment    = 'CutOff';
center_longitude  = 0;
center_latitude   = [];
standard_parallel = 0;
lond_cutoff = 0;
latd_cutoff = 0;
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
            case 'CENTERLATITUDE'
                center_latitude = varargin{i+1};
            case 'CUTOFFLONGITUDE'
                lond_cutoff = varargin{i+1};
            case 'CUTOFFLATITUDE'
                latd_cutoff = varargin{i+1};
            case 'STANDARDPARALLEL'
                standard_parallel = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end


[latNS,lonEW,lat_dstep,lon_dstep] = create_grid_equirectangular(...
    rMars,range_latd,range_lond,pixel_size,...
    'ProjectionAlignment',proj_alignment,...
    'StandardParallel',standard_parallel,...
    'CenterLongitude',center_longitude,...
    'CenterLatitude',center_latitude,...
    'CutOffLongitude',lond_cutoff,...
    'CutOffLatitude',latd_cutoff);


end