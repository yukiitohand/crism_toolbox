function [GLTdata] = crism_create_glt_equirectangular_v2(DEdata,RAdata,varargin)
% [GLTdata] = crism_create_glt_equirectangular_v2(DEdata,RAdata,varargin)
%  INPUTS
%   DEdata: CRISMDDRdata obj, CRISM DDR data
%   RAdata: CRISMdata obj, CRISM RA data
%  OUTPUTS
%   GLTdata: HSI obj, GLT data
%  OPTIONAL Parameters
%   "GCS": string, {'Mars_Sphere','MARS_2000_IAU_IAG_CUSTOM_SPHERE'}
%      geographic coordinate system. 'Mars_Sphere' refers to the sphere 
%      with radius 3396190.0 meters. 'MARS_2000_IAU_IAG_CUSTOM_SPHERE'
%      refers to the sphere with a custom radius obtained at the local
%      radius on the ellipsoid shape whose equatorial radius is 3396190.0
%      meters and polar radius is 3376200.0 meters.
%      (default) 'MARS_Sphere'
%   "Range_Latd" <degrees>: 2-length vector, planetocentric latitude.
%      [minimum latitude, maximum latitude]. If this is empty, the
%      range_latd is automatically obtained.
%      (default) []
%   "Range_Lond" <degrees>: <degrees>: 2-length vector, longitude
%      [westernmost longitude, easternmost latitude]. If this is empty, the
%      range_latd is automatically obtained.
%      (default) []   
%   "Pixel_Size" <meters>: scalar, size of a pixel.
%      (default) []
%   "ProjectionAlignment" : {'Individual','CutOff'}
%     option for how to define the pixel centers.
%     'Individual' : [range_lond(1),range_latd(1)] becomes the coordinate
%     of the center of the lower left corner pixel.
%     'CutOff' : CutOffLongitude and CutOffLatitude becomes the border of 
%     the pixels. 
%     (default) 'CutOff'
%   "StandardParallel" <degrees>: projection center planetocentric latitude
%     at which the true pixel_size is achieved. 
%     (default) 0 degree
%   "CenterLongitude" <degrees>: center of the longitude from which pixels 
%     are gridded. Only used with "ProjectionAlignment" = 'CutOff@Center'.
%     (default) 0 degree
%   "CenterLatitude" <degrees>: 
%     center of the latitude at which local radius is calculated.
%     (default) same as "standard_parallel"
%   "CutOffLongitude" <degrees>: 
%     only used with the mode 'CutOff'. Pixel grid is created so that this 
%     longitude becomes a pixel border.
%     (default) 0 degree
%   "CutOffLatitude" <degrees>: 
%     only used with the mode 'CutOff'. Pixel grid is created so that this 
%     laitude becomes a pixel border.
%     (default) 0 degree
%   "LatitudeOfOrigin" <degrees>: Planetocentric Latitude at which northing
%     is zero. It is not recommended to change this parameters.
%     (default) 0 degree
%   "LongitudeOfOrigin" <degrees>: Longitude at which easting is zero. 
%     (default) 0 degree
%   "PROC_MODE": string, processing mode. 
%     {'V2','VERSION2','DSTTHRESH','V3','VERSION3','REGIONMASK'}
%     {'V2','VERSION2','DSTTHRESH'}: Only distance based assessment on
%     whether or not pixel should be filled is performed. It tends to be
%     smear at edge pixels. Deprecated mode.
%     {'V3','VERSION3','REGIONMASK'}: Image region is assessed as a polygon
%     and pixels inside the polygon are filled. Smear problem is resolved.
%     (default) 'V3'
%   "DST_LMT_PARAM": scalar. Coefficient with respect to resolution of DDR
%     If the distance to input DDR pixels is closer than the value, pixel 
%     is  assigned with the input CRISM pixel. 
%     (default) 2
%   "GLT_VERSION": version number
%     (default) 4
%   "SAVE_FILE": boolean, save the file or not
%     (default) true
%   "SUFFIX": string,
%     (default) ''
%   "FORCE": boolean, force processing or not
%     (default) false
%   "SKIP_IFEXIST": boolean, whether or not to skip processing if the file
%   exist or not.
%     (default) false
%   'SAVE_PDIR': any string
%       root directory path where the processed data are stored. The
%       processed image will be saved at <SAVE_PDIR>/CCCNNNNNNNN, where CCC
%       the class type of the obervation and NNNNNNNN is the observation id.
%       It doesn't matter if trailing slash is there or not. If this is
%       empty, then stored part of localCRISMrootDir.
%       (default) []
%   'SAVE_DIR_YYYY_DOY': boolean
%       Only effective if "save_pdir" is entered. Otherwise, always true.
%       if true, processed images are saved at 
%           <SAVE_PDIR>/YYYY_DOY/CCCNNNNNNNN,
%       otherwise, 
%           <SAVE_PDIR>/CCCNNNNNNNN.
%       (default) false
%     

global crism_env_vars

geo_coord_systm = 'MARS_Sphere'; % {'MARS_Sphere','MARS_2000_IAU_IAG_CUSTOM_SPHERE'}
% rMars = 3396190.0;
pixel_size = [];
range_latd = [];
range_lond = [];
proj_alignment    = 'CutOff';
standard_parallel = 0;
center_longitude  = 0;
center_latitude   = [];
cutoff_longitude  = 0;
cutoff_latitude   = 0;
latitude_of_origin  = 0;
longitude_of_origin = 0;

PROC_MODE = 'V3';
glt_ver = 4;
suffix = '';
force = 0;
dst_lmt_param = 2;
save_file = 0;
skip_ifexist = false;

save_pdir = -1;
save_dir_yyyy_doy = false;

verbose = true;


if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'GCS'
                geo_coord_systm = varargin{i+1};
            case 'RANGE_LATD'
                range_latd = varargin{i+1};
            case 'RANGE_LOND'
                range_lond = varargin{i+1};
            case 'PIXEL_SIZE'
                pixel_size = varargin{i+1};
            case 'PROJECTIONALIGNMENT'
                proj_alignment = varargin{i+1};
            case 'STANDARDPARALLEL'
                standard_parallel = varargin{i+1};
            case 'CENTERLONGITUDE'
                center_longitude = varargin{i+1};
            case 'CENTERLATITUDE'
                center_latitude = varargin{i+1};
            case 'CUTOFFLONGITUDE'
                cutoff_longitude = varargin{i+1};
            case 'CUTOFFLATITUDE'
                cutoff_latitude = varargin{i+1};
            case 'LATITUDEOFORIGIN'
                latitude_of_origin = varargin{i+1};
            case 'LONGITUDEOFORIGIN'
                longitude_of_origin = varargin{i+1};
            case 'PROC_MODE'
                PROC_MODE = varargin{i+1};
            case 'GLT_VERSION'
                glt_ver = varargin{i+1};
            case 'DST_LMT_PARAM'
                dst_lmt_param = varargin{i+1};
            case 'SAVE_FILE'
                save_file = varargin{i+1};
            case 'SUFFIX'
                suffix = varargin{i+1};
                if ~isempty(suffix) && ~strcmpi(suffix(1),'_')
                    suffix = ['_' suffix];
                end
            case 'FORCE'
                force = varargin{i+1};
            case 'SKIP_IFEXIST'
                skip_ifexist = varargin{i+1};
            case 'SAVE_PDIR'
                save_pdir = varargin{i+1};
            case 'SAVE_DIR_YYYY_DOY'
                save_dir_yyyy_doy = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

if force && skip_ifexist
    error('You are forcing or skipping? Not sure what you want');
end

if isempty(pixel_size)
    pixel_size = 18*DEdata.lbl.PIXEL_AVERAGING_WIDTH;
end

if isempty(center_latitude)
    center_latitude = standard_parallel;
end

% examine valid lines
[valid_lines,valid_samples] = crism_examine_valid_LinesColumns(RAdata);

% get the minimum enclosing lat and lon region
if isempty(DEdata.ddr), DEdata.readimg(); end

range_latd_isempty = isempty(range_latd);
if range_latd_isempty
    rMars_tmp = 3396190.0;
    mrgn_deflt = 18*DEdata.lbl.PIXEL_AVERAGING_WIDTH / (rMars_tmp*pi) * 180;
    if verLessThan('matlab','9.4')
        range_latd = [...
            min(min(DEdata.ddr.Latitude.img(valid_lines,valid_samples),[],1,'omitnan'),[],2,'omitnan') - mrgn_deflt*10, ...
            max(max(DEdata.ddr.Latitude.img(valid_lines,valid_samples),[],1,'omitnan'),[],2,'omitnan') + mrgn_deflt*10];
    else
    range_latd = [...
        min(DEdata.ddr.Latitude.img(valid_lines,valid_samples),[],'all','omitnan') - mrgn_deflt*10, ...
        max(DEdata.ddr.Latitude.img(valid_lines,valid_samples),[],'all','omitnan') + mrgn_deflt*10];
    end
end

range_lond_isempty = isempty(range_lond);
if range_lond_isempty
    rMars_tmp = 3396190.0;
    latmean = mean(mean(DEdata.ddr.Latitude.img(valid_lines,valid_samples),1,'omitnan'),2,'omitnan');
    mrgn_deflt = 18*DEdata.lbl.PIXEL_AVERAGING_WIDTH / (rMars_tmp*pi*cosd(latmean)) * 180;
    if verLessThan('matlab','9.4')
        range_lond = [...
            min(min(DEdata.ddr.Longitude.img(valid_lines,valid_samples),[],1,'omitnan'),[],2,'omitnan') - mrgn_deflt*10,...
            max(max(DEdata.ddr.Longitude.img(valid_lines,valid_samples),[],1,'omitnan'),[],2,'omitnan') + mrgn_deflt*10];
    else
    range_lond = [...
        min(DEdata.ddr.Longitude.img(valid_lines,valid_samples),[],'all') - mrgn_deflt*10,...
        max(DEdata.ddr.Longitude.img(valid_lines,valid_samples),[],'all') + mrgn_deflt*10];
    end
end

switch upper(geo_coord_systm)
    case 'MARS_SPHERE'
        rMars = 3396190.0;
    case 'MARS_2000_IAU_IAG_CUSTOM_SPHERE'
        rMars = [3396190.0 3376200.0];
    otherwise
        error('Undefined geographic coordinate system %s.',geo_coord_systm);
end

%% Output directory and filename management

if save_file
    propGLT = crism_getProp_basenameOBSERVATION(DEdata.basename);
    propGLT.product_type = 'GLT';
    propGLT.version = glt_ver;
    basenameGLT = crism_get_basenameOBS_fromProp(propGLT);
    basenameGLT = [basenameGLT suffix];
    if save_pdir==-1 % meaning not specified,
        dir_glt_info = crism_get_dirpath_observation(basenameGLT);
        save_dir = dir_glt_info.dirfullpath_local;
        url_local_root = crism_env_vars.url_local_root;
        subdir_local_split = split(fullfile(url_local_root,dir_glt_info.subdir_local),filesep);
        cur_dir = crism_env_vars.localCRISM_PDSrootDir;
        if exist(cur_dir,'dir')
            for i=1:length(subdir_local_split)
                cur_dir = fullfile(cur_dir,subdir_local_split{i});
                if ~exist(cur_dir,'dir')
                    [status] = mkdir(save_dir); 
                    if status
                        if verbose, fprintf('"%s" is created.\n',cur_dir); end
                        chmod777(cur_dir,verbose);
                    else
                        error('Failed to create %s',cur_dir);
                    end
                end
            end
        else
            error('localCRISM_PDSrootDir %s does not exist.',cur_dir);
        end
    else
        yyyy_doy = RAdata.yyyy_doy; dirname = RAdata.dirname;
        if save_dir_yyyy_doy
            dirpath_yyyy_doy = fullfile(save_pdir,yyyy_doy);
            if ~exist(dirpath_yyyy_doy,'dir')
                status = mkdir(dirpath_yyyy_doy);
                if status
                    if verbose, fprintf('"%s" is created.\n',dirpath_yyyy_doy); end
                    chmod777(dirpath_yyyy_doy,verbose);
                else
                    error('Failed to create %s',dirpath_yyyy_doy);
                end
            end
            save_dir = fullfile(dirpath_yyyy_doy,dirname);
            if ~exist(save_dir,'dir')
                status = mkdir(save_dir);
                if status
                    if verbose, fprintf('"%s" is created.\n',save_dir); end
                    chmod777(save_dir,verbose);
                else
                    error('Failed to create %s',save_dir);
                end
            end
        else
            save_dir = fullfile(save_pdir,dirname);
            if ~exist(save_dir,'dir')
                status = mkdir(save_dir);
                if status
                    if verbose, fprintf('"%s" is created.\n',save_dir); end
                    chmod777(save_dir,verbose);
                else
                    error('Failed to create %s',save_dir);
                end
            end
        end
    end


    fpath_GLT_img = fullfile(save_dir,[basenameGLT '.IMG']);
    fpath_GLT_hdr = fullfile(save_dir,[basenameGLT '.HDR']);
    propGRD = propGLT;
    propGRD.product_type = 'GRD';
    basenameGRD = crism_get_basenameOBS_fromProp(propGRD);
    basenameGRD = [basenameGRD suffix];
    fpath_GRD_mat = fullfile(save_dir,[basenameGRD '.mat']);

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
                GLTdata = ENVIRasterMultBandEquirectProjRot0(basenameGLT,save_dir);
                return;
            elseif strcmpi(ow,'y')
                fprintf('processing continues and will overwrite...\n');
            end
        end
    end

end

%% Main Routine
% if isempty(DEdata.img), DEdata.readimg(); end
inlatMap = DEdata.ddr.Latitude.img;
inlonMap = DEdata.ddr.Longitude.img;

% create GRID IMAGE
[latNS,lonEW,lat_dstep,lon_dstep]= crism_create_grid_equirectangular(...
    range_latd,range_lond,'PIXEL_SIZE',pixel_size,'RMARS',rMars,...
    'ProjectionAlignment',proj_alignment,...
    'StandardParallel',standard_parallel,...
    'CenterLongitude',center_longitude,'CenterLatitude',center_latitude,...
    'CutOffLongitude',cutoff_longitude,'CutOffLatitude',cutoff_latitude);
%
switch upper(PROC_MODE)
    case {'V2','VERSION2','DSTTHRESH'}
        % create GLT image
        [x_glt,y_glt] = create_glt_equirectangular(inlatMap,inlonMap,...
            latNS,lonEW,standard_parallel,'Dst_Lmt_Param',dst_lmt_param,...
            'Valid_Lines',valid_lines,'Valid_Samples',valid_samples);
    case {'V3','VERSION3','REGIONMASK'}
        % evaluate the border of the image region.
        [plgn_lonx,plgn_latx] = crism_ddr_get_surrounding_polygon(...
            DEdata,valid_lines,valid_samples);
        % based on the border of the image, evaluate pixels within the
        % image.
        [inImage] = gltEquiRectangular_getImageRegion(latNS,lonEW,...
            plgn_lonx,plgn_latx);
        % Fill GLTs only inside the mask
        [x_glt,y_glt] = create_glt_equirectangular_wRegionMask(...
            inlatMap,inlonMap,latNS,lonEW,standard_parallel,inImage,...
            'Dst_Lmt_Param',dst_lmt_param,'Valid_Lines',valid_lines,...
            'Valid_Samples',valid_samples);
    otherwise
        error('Undefined PROC_MODE %s.',PROC_MODE);
end
        
% replace NaNs with zeros
isnan_x_glt = isnan(x_glt);
isnan_y_glt = isnan(y_glt);
% arrange the matrix
x_glt(isnan_x_glt) = 0;
y_glt(isnan_y_glt) = 0;

% Trim margins if range_latd and range_lond were not specified at the
% beginning.
if range_latd_isempty
    x_glt_gt0 = x_glt > 0;
    lines_vld = any(x_glt_gt0',1);
    x_glt = x_glt(lines_vld,:);
    y_glt = y_glt(lines_vld,:);
    latNS = latNS(lines_vld);
end
if range_lond_isempty
    x_glt_gt0 = x_glt > 0;
    samples_vld = any(x_glt_gt0,1);
    x_glt = x_glt(:,samples_vld);
    y_glt = y_glt(:,samples_vld);
    lonEW = lonEW(samples_vld);
end

img_glt = cat(3,x_glt,y_glt);
if verLessThan('matlab','9.4')
    if max(max(max(img_glt,[],1),[],2),[],3) < intmax('int16')
        img_glt   = int16(img_glt);
        data_type = 2;
    elseif max(max(max(img_glt,[],1),[],2),[],3) < intmax('int32')
        img_glt   = int32(img_glt);
        data_type = 3;
    elseif max(max(max(img_glt,[],1),[],2),[],3) < intmax('int64')
        img_glt   = int64(img_glt);
        data_type = 14;
    else
        error('The input image may be too big.');
    end
else
    if max(img_glt,[],'all') < intmax('int16')
        img_glt   = int16(img_glt);
        data_type = 2;
    elseif  max(img_glt,[],'all') < intmax('int32')
        img_glt   = int32(img_glt);
        data_type = 3;
    elseif  max(img_glt,[],'all') < intmax('int64')
        img_glt   = int64(img_glt);
        data_type = 14;
    else
        error('The input image may be too big.');
    end
end

%% create Header for GLT
[r_local,shapetype] = mars_get_local_radius(rMars,...
    'ReferenceLatitude',standard_parallel,...
    'ReferenceLongitude',center_longitude);
easting  = r_local * pi * ((lonEW(1)-longitude_of_origin)/180).*cosd(standard_parallel);
northing = r_local * pi * ((latNS(1)-latitude_of_origin)/180);

% ----- Information for the projection ------------------------------------
switch upper(geo_coord_systm)
    case 'MARS_SPHERE'
        projcs_name = sprintf(...
            'Mars Sphere-Based Equirectangular lat%05.2fN',...
            standard_parallel);
        spheroid_name = 'Mars_Sphere';
        spheroid_major_axis = rMars;
        datum_name = ['D_' spheroid_name];
        geogcs_name = ['GCS_' spheroid_name];
    case 'MARS_2000_IAU_IAG_CUSTOM_SPHERE'
        projcs_name = sprintf(...
            'MRO Mars Equirectangular [IAU 2000] [%5.2fN; %5.2fE]',...
            standard_parallel,center_longitude);
        spheroid_name = sprintf(...
            'Mars_2000_IAU_IAG_custom_sphere_lat%02d',standard_parallel);
        spheroid_major_axis = r_local;
        datum_name = ['D_' spheroid_name];
        geogcs_name = ['GCS_' spheroid_name];
    otherwise
        error('Undefined geographic coordinate system %s.',...
            geo_coord_systm);
end

map_info = [];
map_info.projection = projcs_name;
% [1,1] is considered as the center of the most upper left pixel by the 
% class SphereEquiRectangularProj, while in ENVI, [1.5 1.5] is considered 
% as the center of the most upper left pixel. [1 1] is the upper left
% vertex of the upper left most pixel.
map_info.image_coords = [1.5 1.5];
map_info.mapx = easting;
map_info.mapy = northing;
map_info.dx = pixel_size;
map_info.dy = pixel_size;
map_info.datum = datum_name;
map_info.units = 'Meters';

% 0.0 0.0 are false_easting and false_northing
hdr_proj_info = sprintf('{17, %.15f, %.6f, %.6f, 0.0, 0.0, %s, %s, units=Meters}',...
    spheroid_major_axis,standard_parallel,center_longitude, datum_name, projcs_name);

cood_systm_str = sprintf([...
    '{PROJCS["%s",GEOGCS["%s",DATUM["%s",SPHEROID["%s",%.15f,0.0]],'           ,...
        'PRIMEM["Reference_Meridian",0.0],UNIT["Degree",0.0174532925199433]],'   ,...
        'PROJECTION["Equidistant_Cylindrical"],PARAMETER["False_Easting",0.0],'  ,...
        'PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",%.15f],' ,...
        'PARAMETER["Standard_Parallel_1",%.15f],',...
        'UNIT["Meter",1.0]]}'],...
        projcs_name,geogcs_name,datum_name,spheroid_name,spheroid_major_axis,...
        longitude_of_origin,standard_parallel);


% ----- Create Header  ----------------------------------------------------
hdr_glt = [];
dt = datetime('now','TimeZone','local','Format','eee MMM dd hh:mm:ss yyyy');
hdr_glt.description = sprintf('{Georeferencing Lookup Table Result. [%s]}',dt);
hdr_glt.samples = length(lonEW);
hdr_glt.lines = length(latNS);
hdr_glt.bands = 2;
hdr_glt.header_offset = 0;
hdr_glt.file_type = 'ENVI Standard';
hdr_glt.data_type = data_type;
hdr_glt.interleave = 'bil';
hdr_glt.sensor_type = 'Unknown';
hdr_glt.byte_order = 0;
hdr_glt.map_info = map_info;
hdr_glt.projection_info = hdr_proj_info;
hdr_glt.coordinate_system_string = cood_systm_str;
% hdr_glt.projection_info = sprintf('{17, %f, %9.6f, %9.6f, 0.0, 0.0, D_Unknown, Mars Sphere-Based Equirectangular, units=Meters}',rMars,standard_parallel,center_longitude);
% hdr_glt.coordinate_system_string = sprintf('{PROJCS["Equidistant_Cylindrical",GEOGCS["GCS_Unknown",DATUM["D_Unknown",SPHEROID["S_Unknown",%.1f,0.0]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Equidistant_Cylindrical"],PARAMETER["False_Easting",0.0],PARAMETER["False_Northing",0.0],PARAMETER["Central_Meridian",%f],PARAMETER["Standard_Parallel_1",%f],UNIT["Meter",1.0]]}',...
%     rMars,center_longitude,standard_parallel);
hdr_glt.wavelength_units = 'Unknown';
hdr_glt.band_names = {'GLT Sample Lookup', 'GLT Line Lookup'};

%% create proj_info
proj_info = SphereEquiRectangularProj('name',projcs_name,...
    'Radius',spheroid_major_axis,...
    'STANDARD_PARALLEL',standard_parallel,...
    'CenterLongitude',center_longitude,...
    'CenterLatitude',center_latitude,...
    'Latitude_of_origin',latitude_of_origin,...
    'Longitude_of_origin',longitude_of_origin);
proj_info.rdlat = 1./lat_dstep;
proj_info.rdlon = 1./lon_dstep;
proj_info.map_scale_x = pixel_size;
proj_info.map_scale_y = pixel_size;
proj_info.set_lat1(latNS(1));
proj_info.set_lon1(lonEW(1));
proj_info.longitude_range = [lonEW(1)-0.5*lon_dstep lonEW(end)+0.5*lon_dstep];
proj_info.latitude_range  = [latNS(1)+0.5*lat_dstep latNS(end)-0.5*lat_dstep];

%% save
if save_file
    fprintf('Saving %s ...\n',fpath_GLT_hdr);
    envihdrwritex(hdr_glt,fpath_GLT_hdr,'OPT_CMOUT',false);
    fprintf('Done\n');
    fprintf('Saving %s ...\n',fpath_GLT_img);
    envidatawrite(img_glt,fpath_GLT_img,hdr_glt);
    fprintf('Done\n');

    fprintf('Saving %s ...\n',fpath_GRD_mat);
    save(fpath_GRD_mat,'latNS','lonEW','range_latd','range_lond',...
        'standard_parallel','pixel_size');
end


% hdr_glt.northing = reshape(r_local * pi * ((latNS-latitude_of_origin)/180),1,[]);
% hdr_glt.easting  = reshape(r_local * pi * ((lonEW-longitude_of_origin)/180),1,[]);
GLTdata = ENVIRasterMultBandEquirectProjRot0('','');
GLTdata.hdr = hdr_glt;
GLTdata.img = img_glt;
GLTdata.proj_info = proj_info;

if save_file
    GLTdata.basename = basenameGLT;
    GLTdata.dirpath  = save_dir;
    GLTdata.imgpath  = fpath_GLT_img;
    GLTdata.hdrpath  = fpath_GLT_hdr;
end