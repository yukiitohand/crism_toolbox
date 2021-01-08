function [latNS,lonEW] = create_grid_equirectangular(r,range_latd,...
    range_lond,pixel_size,varargin)
% [latNS,lonEW] = create_grid_equirectangular(r,range_latd,...
%     range_lond,pixel_size,varargin)
%   Create a grid for equirectangular projection
%  INPUTS
%   r <meters>: radii of the body, can be scalar or a vector with two or 
%      three elements. Namely, the following three types of inputs are 
%      acceptable.
%      - radius
%      - [equatorial radius, polar radius],
%      - [r1, r2, r3]: (future potential implementation) r1 is the largest
%        equatorial radius, the second is the smallest equatorial radius, 
%        the third is the polar radius. This mode is not implemented yet. 
%   range_latd <degrees>: 2-length vector, planetocentric latitude
%      [minimum latitude, maximum latitude]
%   range_lond <degrees>: 2-length vector
%      [westernmost longitude, easternmost latitude].
%   pixel_size <meters>: scalar, size of a pixel.
%  OUTPUTS
%   latNS <degrees>: vector
%     list of the planetocentric latitude of the center of image lines 
%     1:end. Usually maximum latitude comes first.
%   lonEW <degrees>: vector
%     list of the longitude of the center of image samples 1:end
%  Optional Parameters
%   "ProjectionAlignment" : {'Individual','CutOff@Center'}
%     option for how to define the pixel centers.
%     'Individual' : [range_lond(1),range_latd(1)] becomes the coordinate
%     of the center of the lower left corner pixel.
%     'CutOff@Center' : center of the longitude and center of the latitude
%     becomes the border of the pixels. It is recommended to provide two
%     other optional parameters, "CenterLongitude" and "CenterLatitude"
%     (default) 'CutOff@Center'
%   "StandardParallel" <degrees>: projection center planetocentric latitude
%     at which the true pixel_size is achieved. 
%     With the mode 'CutOff@Center', from this latitude pixels are gridded.
%     (default) 0 degree
%   "CenterLongitude" <degrees>: center of the longitude from which pixels 
%     are gridded. Only used with "ProjectionAlignment" = 'CutOff@Center'.
%     (default) 0 degree
%  

proj_alignment = 'CutOff@Center';
lond_ctr = 0;
standard_parallel = 0;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'PROJECTIONALIGNMENT'
                proj_alignment = varargin{i+1};
            case 'CENTERLONGITUDE'
                lond_ctr = varargin{i+1};
            case 'STANDARDPARALLEL'
                standard_parallel = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

% center latitude is same as the standard parallel.
latd_ctr = standard_parallel;
cos_stdprll = cosd(standard_parallel);
r_local = mars_get_local_radius(r,'ReferenceLatitude',latd_ctr,...
    'ReferenceLongitude',lond_ctr);
lat_dstep = pixel_size/(r_local*pi) * 180;
lon_dstep = lat_dstep / cos_stdprll;

switch upper(proj_alignment)
    case 'INDIVIDUAL'
        length_NS = abs(range_latd(2) - range_latd(1));
        length_EW = abs(range_lond(2) - range_lond(1));

        n_NS = ceil(abs(length_NS/lat_dstep));
        n_EW = ceil(abs(length_EW/lon_dstep));

        latNS = range_latd(1) + ((1:n_NS)' - 1) * lat_dstep;
        lonEW = range_lond(1) + ((1:n_EW) - 1) * lon_dstep;
        % flip lat_NS
        latNS = flip(latNS);
    case 'CUTOFF@CENTER'
        westernmost_sample = floor((range_lond(1)-lond_ctr) / lon_dstep);
        westernmost_pixel_ctr_lon = (westernmost_sample + 0.5) * lon_dstep + lond_ctr;
        easternmost_sample = ceil((range_lond(2)-lond_ctr) / lon_dstep);
        % easternmost_pixel_ctr_lon = (easternmost_sample - 0.5) * lon_dstep + lond_ctr;
        n_EW = easternmost_sample - westernmost_sample + 1;
        lonEW = westernmost_pixel_ctr_lon + ((1:n_EW) - 1) * lon_dstep;
        
        minlat_line = floor((range_latd(1)-latd_ctr) / lat_dstep);
        maxlat_line = ceil((range_latd(2)-latd_ctr) / lat_dstep);
        % minlat_pixel_ctr_lat = (minlat_line + 0.5) * lat_dstep + latd_ctr;
        maxlat_pixel_ctr_lat = (maxlat_line - 0.5) * lat_dstep + latd_ctr;
        n_NS = maxlat_line-minlat_line+1;
        latNS = maxlat_pixel_ctr_lat - ((1:n_NS)' - 1) * lat_dstep;
        
    otherwise
        error('Undefined PROJECTION_ALIGNMENT %s.',proj_alignment);
end



end