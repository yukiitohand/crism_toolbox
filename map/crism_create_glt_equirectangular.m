function [] = crism_create_glt_equirectangular(DEdata,RAdata,varargin)

% North East Syrtis
% range_lond = [76 78];
rMars = 3396190.0;
pixel_size = 19;
range_latd = [17.5 18.02];
range_lond = [76.8 77.3];
% range_latd = [16.3 18.2];
latd0 = 17.7;
lond0 = mean(range_lond);
glt_ver = 3;
suffix = '';
force = 0;
dst_lmt_param = 2;
skip_ifexist = false;


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
            case 'GLT_VERSION'
                glt_ver = varargin{i+1};
            case 'DST_LMT_PARAM'
                dst_lmt_param = varargin{i+1};
            case 'SUFFIX'
                suffix = varargin{i+1};
                if ~isempty(suffix) && ~strcmpi(suffix(1),'_')
                    suffix = ['_' suffix];
                end
            case 'FORCE'
                force = varargin{i+1};
            case 'SKIP_IFEXIST'
                skip_ifexist = varargin{i+1};
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
propGLT = crism_getProp_basenameOBSERVATION(DEdata.basename);
propGLT.product_type = 'GLT';
propGLT.version = glt_ver;
basenameGLT = crism_get_basenameOBS_fromProp(propGLT);
basenameGLT = [basenameGLT suffix];
dir_glt_info = crism_get_dirpath_observation(basenameGLT);
dir_glt = dir_glt_info.dirfullpath_local;
fpath_GLT_img = joinPath(dir_glt,[basenameGLT '.IMG']);
fpath_GLT_hdr = joinPath(dir_glt,[basenameGLT '.HDR']);

propGRD = propGLT;
propGRD.product_type = 'GRD';
basenameGRD = crism_get_basenameOBS_fromProp(propGRD);
basenameGRD = [basenameGRD suffix];
fpath_GRD_mat = joinPath(dir_glt,[basenameGRD '.mat']);

outputs_fpath = {fpath_GLT_img,fpath_GLT_hdr,fpath_GRD_mat};

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

if ~exist(dir_glt,'dir'), mkdir(dir_glt); end


%%
if isempty(DEdata.img), DEdata.readimg(); end
inlatMap = DEdata.ddr.Latitude.img;
inlonMap = DEdata.ddr.Longitude.img;

% examine valid lines
[valid_lines,valid_samples] = crism_examine_valid_LinesColumns(RAdata);

% create GRID IMAGE
[latMap,lonMap,latNS,lonEW]...
    = crism_create_grid_equirectangular(latd0,range_latd,range_lond,...
                                        'PIXEL_SIZE',pixel_size,'RMARS',rMars);
% create GLT image
[x_glt,y_glt] = create_glt_equirectangular(inlatMap,inlonMap,latNS,lonEW,latd0,...
    'Dst_Lmt_Param',dst_lmt_param,'Valid_Lines',valid_lines,'Valid_Samples',valid_samples);
% replace NaNs with zeros
isnan_x_glt = isnan(x_glt);
isnan_y_glt = isnan(y_glt);

% arrange the matrix
x_glt(isnan_x_glt) = 0;
y_glt(isnan_y_glt) = 0;
img_glt = cat(3,x_glt,y_glt);
img_glt = int16(img_glt);

%% create Header for GLT
easting = rMars * pi * ((lonEW(1)-lond0)/180);
northing = rMars * pi * ((latNS(1)-latd0)/180);
hdr_glt = [];
dt = datetime('now','TimeZone','local','Format','eee MMM dd hh:mm:ss yyyy');
hdr_glt.description = sprintf('{Georeferencing Lookup Table Result. [%s]}',dt);
hdr_glt.samples = length(lonEW);
hdr_glt.lines = length(latNS);
hdr_glt.bands = 2;
hdr_glt.header_offset = 0;
hdr_glt.file_type = 'ENVI Standard';
hdr_glt.data_type = 2;
hdr_glt.interleave = 'bil';
hdr_glt.sensor_type = 'Unknown';
hdr_glt.byte_order = 0;
hdr_glt.map_info = [];
hdr_glt.map_info.projection = 'Mars Sphere-Based Equirectangular';
% [1,1] is considered as the center of the most upper left pixel by the 
% class SphereEquiRectangularProj, while in ENVI, [1.5 1.5] is considered 
% as the center of the most upper left pixel. [1 1] is the upper left
% vertex of the upper left most pixel.
hdr_glt.map_info.image_coords = [1.5 1.5];
hdr_glt.map_info.mapx = easting;
hdr_glt.map_info.mapy = northing;
hdr_glt.map_info.dx = pixel_size;
hdr_glt.map_info.dy = pixel_size;
hdr_glt.map_info.datum = 'D_Unknown';
hdr_glt.map_info.units = 'Meters';
hdr_glt.projection_info = sprintf('{17, %f, %9.6f, %9.6f, 0.0, 0.0, D_Unknown, Mars Sphere-Based Equirectangular, units=Meters}',rMars,latd0,lond0);
hdr_glt.coordinate_system_string = sprintf('{PROJCS["Equidistant_Cylindrical",GEOGCS["GCS_Unknown",DATUM["D_Unknown",SPHEROID["S_Unknown",%.1f,0.0]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Equidistant_Cylindrical"],PARAMETER["False_Easting",0.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",%f],PARAMETER["Standard_Parallel_1",%f],UNIT["Meter",1.0]]}',...
    rMars,lond0,latd0);
hdr_glt.wavelength_units = 'Unknown';
hdr_glt.band_names = {'GLT Sample Lookup', 'GLT Line Lookup'};

%% save
fprintf('Saving %s ...\n',fpath_GLT_hdr);
envihdrwritex(hdr_glt,fpath_GLT_hdr,'OPT_CMOUT',false);
fprintf('Done\n');
fprintf('Saving %s ...\n',fpath_GLT_img);
envidatawrite(img_glt,fpath_GLT_img,hdr_glt);
fprintf('Done\n');

fprintf('Saving %s ...\n',fpath_GRD_mat);
save(fpath_GRD_mat,'latMap','lonMap','range_latd','range_lond','latd0','pixel_size');

end