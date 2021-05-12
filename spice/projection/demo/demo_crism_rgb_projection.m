% demo_crism_rgb_projection
vr = 0;
fname_top = sprintf('%s_MSLGaleDEMproj_v%1d',crism_info.info.dirname,vr);
save_dir  = joinPath('/Users/yukiitoh/src/matlab/crism_projection/', fname_top);
fname_meta = sprintf('%s_SLM.mat',fname_top);
fpath = joinPath(save_dir,fname_meta);
load(fpath,'crismPxl_lofst','crismPxl_sofst','crismPxl_smpls','crismPxl_lines');


line_offset = 0; Nlines = 450;
[msldemc_hdr,msldemc_imFOVres,msldemc_imFOVsmpl,msldemc_imFOVline] ...
    = crism_combine_FOVcell_PSF_multiPxl_v2( ...
    fname_top, save_dir, line_offset, Nlines, ...
    crismPxl_sofst, crismPxl_smpls, crismPxl_lofst,crismPxl_lines);
%%
obs_id = 'B6F1';
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3datasetB6F1 = CRISMTRRdataset(crism_obs.info.basenameIF,'');
TRR3datasetB6F1.trr3if.set_rgb();
crism_rgb_proj = img_proj_w_gltxy(TRR3datasetB6F1.trr3if.RGB.CData_Scaled, ...
    double(msldemc_imFOVsmpl),double(msldemc_imFOVline));
crism_rgb_proj = uint8(crism_rgb_proj);


%% Load MSLDEMdata
MSLDEMdata = MSLGaleMosaicRadius_v3('MSL_Gale_DEM_Mosaic_1m_v3_dave_ra', ...
    '/Users/yukiitoh/data/');
msldemc_latitude  = MSLDEMdata.latitude( ...
    double([msldemc_hdr.line_offset+1,msldemc_hdr.line_offset+msldemc_hdr.lines]));
msldemc_longitude = MSLDEMdata.longitude( ...
    double([msldemc_hdr.sample_offset+1,msldemc_hdr.sample_offset+msldemc_hdr.samples]));

%% Load MSLOrthodata
crism_init;
crism_info = CRISMObservation('b6f1','sensor_id','L');
DEdata = CRISMDDRdata(crism_info.info.basenameDDR,crism_info.info.dir_ddr);
DEdata.readimg();
rMars_m = 3396190; % meters
mrgn_deg = 600 / (rMars_m*pi) * 180;
lat_range = [max(DEdata.ddr.Latitude.img,[],'all')+mrgn_deg, min(DEdata.ddr.Latitude.img,[],'all')-mrgn_deg];
lon_range = [min(DEdata.ddr.Longitude.img,[],'all')-mrgn_deg,max(DEdata.ddr.Longitude.img,[],'all')+mrgn_deg];

MSLOrthodata = MSLGaleOrthoMosaic_v3('MSL_Gale_Orthophoto_Mosaic_25cm_v3_ave10','/Volumes/LaCie/data');
[mslortho_img,mslortho_x,mslortho_y] = MSLOrthodata.get_subimage_wlatlon(lon_range,lat_range,'precision','uint8');
mslorthoc_latitude   = MSLOrthodata.latitude(mslortho_y);
mslorthoc_longitude  = MSLOrthodata.longitude(mslortho_x);

%% DDR projection
load b6f1_L_msldem_projection_v3_cor.mat lon_map_new lat_map_new



%Load reference SOC products and its derived products.
crism_obs = CRISMObservation(obs_id,'sensor_id','L');
TRR3datasetB6F1 = CRISMTRRdataset(crism_obs.info.basenameIF,'');
[valid_lines,valid_samples] = crism_examine_valid_LinesColumns(TRR3datasetB6F1.trr3ra);
DEdataB6F1 = CRISMDDRdata(crism_obs.info.basenameDDR,'');
DEdataB6F1.readimg();
% [polygon_lon,polygon_lat] = crism_ddr_get_surrounding_polygon(...
%     DEdataB6F1,valid_lines,valid_samples);
DEdataB6F1.ddr.Latitude.img = lat_map_new;
DEdataB6F1.ddr.Longitude.img = lon_map_new;
TRR3datasetB6F1.trr3if.load_basenamesCDR(); 
GLTdataB6F1 = crism_create_glt_equirectangular_v2(...
    DEdataB6F1,TRR3datasetB6F1.trr3ra,...
    'RANGE_LATD',[],'RANGE_LOND',[],'Dst_Lmt_Param',3,'Pixel_Size',18,...
    'GLT_VERSION',4,'suffix','gale_B6F1_18m','force',0,'skip_ifexist',0,...
    'save_file',0);
TRR3datasetB6F1.trr3if.readCDR('WA');
hsidata_projB6F1 = CRISMdataEquirectProjRot0_wGLT(TRR3datasetB6F1.trr3if,GLTdataB6F1);
hsidata_projB6F1.set_rgb();


%%
isv_image = ImageStackView({},'Ydir','normal','XY_COORDINATE_SYSTEM','LATLON');
isv_image.add_layer(mslorthoc_longitude,mslorthoc_latitude,mslortho_img,'name','msldem ortho');
isv_image.add_layer(hsidata_projB6F1.longitude([1 hsidata_projB6F1.hdr.samples]),...
    hsidata_projB6F1.latitude([1 hsidata_projB6F1.hdr.lines]),...
    hsidata_projB6F1.RGB.CData_Scaled,'name','ddr new');

isv_image.add_layer(msldemc_longitude,msldemc_latitude,crism_rgb_proj,'name','crism_rgb');
isv_image.Update_ImageAxes_LimHomeAuto();
isv_image.Update_ImageAxes_LimHome();
isv_image.Update_axim_aspectR();
isv_image.Restore_ImageAxes2LimHome();




