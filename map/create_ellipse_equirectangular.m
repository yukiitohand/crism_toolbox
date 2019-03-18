function [] = create_ellipse_equirectangular(xy_center_deg,ellipse_axis_meter,varargin)

% North East Syrtis
% range_lond = [76 78];
rMars = 3396190.0;
pixel_size = 19;
range_latd = [17.5 18.02];
range_lond = [76.8 77.3];
% range_latd = [16.3 18.2];
latd0 = 17.7;
lond0 = mean(range_lond);
force = 0;
dst_lmt_param = 2;
skip_ifexist = false;
out_dirpath = './';
out_basename = 'tmp';
color = [255 0 0];


if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'RANGE_LATD'
                range_latd = varargin{i+1};
            case 'RANGE_LOND'
                range_lond = varargin{i+1};
            case 'LATD0'
                latd0 = varargin{i+1};
            case 'LOND0'
                lond0 = varargin{i+1};
            case 'PIXEL_SIZE'
                pixel_size = varargin{i+1};
            case 'RMARS'
                rMars = varargin{i+1};
            case 'DST_LMT_PARAM'
                dst_lmt_param = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'OUT_BASENAME'
                out_basename = varargin{i+1};
            case 'OUT_DIRPATH'
                out_dirpath = varargin{i+1};
            case 'SKIP_IFEXIST'
                skip_ifexist = varargin{i+1};
            case 'COLOR'
                color = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

if force && skip_ifexist
    error('You are forcing or skipping? Not sure what you want');
end

% obs_id = '1821c';
% crism_obs = CRISMObservationFRT(obs_id,'SENSOR_ID','L');
% crism_obs.load_ddr(crism_obs.info.basenameDDR,crism_obs.info.dir_ddr,'ddr');

%% filename
fpath_img = joinPath(out_dirpath,[out_basename '.IMG']);
fpath_hdr = joinPath(out_dirpath,[out_basename '.HDR']);
fpath_grid_mat = joinPath(out_dirpath,[out_basename '_grid.mat']);

outputs_fpath = {fpath_img,fpath_hdr,fpath_grid_mat};

% examine if all the output files exist.
exist_flg = all(cellfun(@(x) exist(x,'file'),outputs_fpath));

if exist_flg
    if skip_ifexist
        return;
    elseif ~force
        flg = 1;
        while flg
            prompt = sprintf('There exists processed images. Do you want to continue to process and overwrite?(y/n)');
            ow = input(prompt,'s');
            if any(strcmpi(ow,{'y','n'}))
                flg=0;
            else
                fprintf('Input %s is not valid.\n',ow);
            end
        end
        if strcmpi(ow,'n')
            fprintf('Process aborted...\n');
            return;
        elseif strcmpi(ow,'y')
            fprintf('processing continues and will overwrite...\n');
        end
    end
end

if ~exist(out_dirpath,'dir'), mkdir(out_dirpath); end


%%
% create GRID IMAGE
[latMap,lonMap,latNS,lonEW]...
    = crism_create_grid_equirectangular(latd0,range_latd,range_lond,...
                                        'PIXEL_SIZE',pixel_size,'RMARS',rMars);
%
coslatd0 = cosd(latd0);
lat_axis = ellipse_axis_meter(2)/(rMars*pi) * 180;
lon_axis = ellipse_axis_meter(1)/(rMars*pi) * 180/coslatd0;
thetas = 0:0.01:2*pi;

x_lon = lon_axis/2*cos(thetas)+xy_center_deg(1);
y_lat = lat_axis/2*sin(thetas)+xy_center_deg(2); 

% create GLT image
[x_glt,y_glt] = create_glt_equirectangular(y_lat,x_lon,latNS,lonEW,latd0,...
    'Dst_Lmt_Param',dst_lmt_param);
% replace NaNs with zeros
isnan_x_glt = isnan(x_glt);
isnan_y_glt = isnan(y_glt);

% arrange the matrix
x_glt(isnan_x_glt) = 0;
y_glt(isnan_y_glt) = 0;
img_glt = cat(3,x_glt,y_glt);
img_glt = int16(img_glt);

img_ellipse_bool = sum(img_glt,3)>0;

img_ellipse_R = uint8(img_ellipse_bool)*color(1);
img_ellipse_G = uint8(img_ellipse_bool)*color(2);
img_ellipse_B = uint8(img_ellipse_bool)*color(3);
img_ellipse = cat(3,img_ellipse_R,img_ellipse_G,img_ellipse_B);


%% create Header for GLT
easting = rMars * pi * ((lonEW(1)-lond0)/180);
northing = rMars * pi * ((latNS(1)-latd0)/180);
hdr_ellipse = [];
dt = datetime('now','TimeZone','local','Format','eee MMM dd hh:mm:ss yyyy');
hdr_ellipse.description = sprintf('{Georeferencing Lookup Table Result. [%s]}',dt);
hdr_ellipse.samples = length(lonEW);
hdr_ellipse.lines = length(latNS);
hdr_ellipse.bands = 3;
hdr_ellipse.header_offset = 0;
hdr_ellipse.file_type = 'ENVI Standard';
hdr_ellipse.data_type = 1;
hdr_ellipse.interleave = 'bil';
hdr_ellipse.sensor_type = 'Unknown';
hdr_ellipse.byte_order = 0;
hdr_ellipse.map_info = [];
hdr_ellipse.map_info.projection = 'Mars Sphere-Based Equirectangular';
hdr_ellipse.map_info.image_coords = [1 1];
hdr_ellipse.map_info.mapx = easting;
hdr_ellipse.map_info.mapy = northing;
hdr_ellipse.map_info.dx = pixel_size;
hdr_ellipse.map_info.dy = pixel_size;
hdr_ellipse.map_info.datum = 'D_Unknown';
hdr_ellipse.map_info.units = 'Meters';
hdr_ellipse.projection_info = sprintf('{17, %f, %9.6f, %9.6f, 0.0, 0.0, D_Unknown, Mars Sphere-Based Equirectangular, units=Meters}',rMars,latd0,lond0);
hdr_ellipse.coordinate_system_string = sprintf('{PROJCS["Equidistant_Cylindrical",GEOGCS["GCS_Unknown",DATUM["D_Unknown",SPHEROID["S_Unknown",%.1f,0.0]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Equidistant_Cylindrical"],PARAMETER["False_Easting",0.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",%f],PARAMETER["Standard_Parallel_1",%f],UNIT["Meter",1.0]]}',...
    rMars,lond0,latd0);
hdr_ellipse.wavelength_units = 'Unknown';
hdr_ellipse.band_names = {'GLT Sample Lookup', 'GLT Line Lookup'};

%% save
fprintf('Saving %s ...\n',fpath_hdr);
envihdrwritex(hdr_ellipse,fpath_hdr,'OPT_CMOUT',false);
fprintf('Done\n');
fprintf('Saving %s ...\n',fpath_img);
envidatawrite(img_ellipse,fpath_img,hdr_ellipse);
fprintf('Done\n');

fprintf('Saving %s ...\n',fpath_grid_mat);
save(fpath_grid_mat,'latMap','lonMap','range_latd','range_lond','latd0','pixel_size');
fprintf('Done\n');

end