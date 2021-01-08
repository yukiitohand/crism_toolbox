function [r_local,shapetype] = mars_get_local_radius(r,varargin)
% [r_local] = mars_get_local_radius(r,varargin)
%  Get local radius of Mars
%  INPUTS
%   r <meters>: radii of the body, can be scalar or a vector with two or 
%      three elements. Namely, the following three types of inputs are 
%      acceptable.
%      - radius
%      - [equatorial radius, polar radius],
%      - [r1, r2, r3]: Currently this mode is only supported if r1==r2.
%        (future potential implementation) r1 is the largest
%        equatorial radius, the second is the smallest equatorial radius, 
%        the third is the polar radius. This mode is not implemented yet.
%  OUTPUTS
%   r_local <meters>: local radius
%   shapetype : 'Sphere', 'Spheroid', 'Ellipsoid'
%  Optional Parameters
%   "ReferenceLatitude" <degrees>: planetocentric latitude at which local
%     radius is calculated.
%     (default) 0 degree
%   "ReferenceLongitude" <degrees>: longitude at which local radius is
%     calculated. This mode only exists for future extension with three
%     different radii.
%     (default) 0 degree
%  

latref = 0;
lonref = 0;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'REFERENCELATITUDE'
                latref = varargin{i+1};
            case 'REFERENCELONGITUDE'
                lonref = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end
if isscalar(r)
    r_local = r;
    shapetype = 'Sphere';
elseif (isvector(r) && length(r)==2)
    Re = r(1); Rp = r(2);
    a = Rp*cosd(latref); b = Re*sind(latref);
    r_local = Re*Rp / sqrt(a^2+b^2);
    if Re==Rp
        shapetype = 'Sphere';
    else
        shapetype = 'Ellipsoid';
    end
elseif ( isvector(r) && length(r)==3 )
    if r(1)==r(2)
        Re = r(1); Rp = r(3);
        a = Rp*cosd(latref); b = Re*sind(latref);
        r_local = Re*Rp / sqrt(a^2+b^2);
        if Re==Rp
            shapetype = 'Sphere';
        else
            shapetype = 'Ellipsoid';
        end
    else
        error(...
            ['radii input mode with three different radius components',...
             'is not yet implemented']);
    end
    
else
    error('Unrecognized r');
end