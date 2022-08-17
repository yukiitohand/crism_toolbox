function [nee] = get_CRISM_NorthEastElevation(crism_DDRdata,varargin)
% [nee] = get_CRISM_NorthEastElevation(crism_DDRdata,varargin)
%  Get North-East-Elevation from CRISM DDR data
%   INPUTS
%    crism_DDRdata: obj of CRISMDDRdata, DDRdata.
%   OUTPUTS
%    nee: [L_ddr x S_ddr x 3]
%    The first page is northing, the second page is easting, and the third
%    page is elevation
%   OPTIONAL parameters
%    'RE': meters ellipsoid radius (default) 3396190

Re = 3396190; % meters ellipsoid radius
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'RE'
                Re = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

if isempty(crism_DDRdata.ddr), crism_DDRdata.readimg(); end

ddr_latitude_pc = crism_DDRdata.ddr.Latitude.img;
ddr_longitude = crism_DDRdata.ddr.Longitude.img;
ddr_elevation = crism_DDRdata.ddr.Elevation.img;
% planetocentric coordinate to northing easting coordinates
ddr_northing = Re .* (pi/180) .* ddr_latitude_pc;
ddr_easting  = Re .* (pi/180) .* ddr_longitude;

nee = cat(3,ddr_northing,ddr_easting,ddr_elevation);

end
