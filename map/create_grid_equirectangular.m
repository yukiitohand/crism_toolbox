function [latitude_MAP,longitude_MAP,lat_NS,lon_EW] = create_grid_equirectangular(r,latd0,range_latd,range_lond,pixel_size)

coslatd0 = cosd(latd0);

lat_dstep = pixel_size/(r*pi) * 180;
lon_dstep = lat_dstep / coslatd0;

length_NS = abs(range_latd(2) - range_latd(1));
length_EW = abs(range_lond(2) - range_lond(1));

n_NS = ceil(abs(length_NS/lat_dstep));
n_EW = ceil(abs(length_EW/lon_dstep));

lat_NS = range_latd(1) + ((1:n_NS)' - 1) * lat_dstep;
lon_EW = range_lond(1) + ((1:n_EW) - 1) * lon_dstep;

% flip lat_NS
lat_NS = flip(lat_NS);

latitude_MAP = repmat(lat_NS,[1,n_EW]);
longitude_MAP = repmat(lon_EW,[n_NS,1]);

end