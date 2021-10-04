
%% Input parameters
crism_init;
sensor_id  = 'L';
obs_id     = 'b6f1';
correction = true;
sensor_id_gcp_cor_param = 'L';

%% Determine use the correction parameter or not
crism_info = CRISMObservation(obs_id,'sensor_id',sensor_id);
if correction
    vr = 1;
    
    fname_top = sprintf('%s_%s_MSLGaleDEMproj_cor_v%1d',crism_info.info.dirname,crism_info.info.sensor_id,vr);
    fname_top_v0 = sprintf('%s_%s_MSLGaleDEMproj_v0',crism_info.info.dirname,crism_info.info.sensor_id);
    
    crism_info_gcp_cor_param = CRISMObservation(obs_id,'sensor_id',sensor_id_gcp_cor_param);
    fname_top_gcp_cor_param = sprintf('%s_%s_MSLGaleDEMproj_cor_v%1d', ...
        crism_info_gcp_cor_param.info.dirname,crism_info.info.sensor_id,vr);
    fname_top_v0_gcp_cor_param = sprintf('%s_%s_MSLGaleDEMproj_v0', ...
        crism_info_gcp_cor_param.info.dirname,crism_info_gcp_cor_param.info.sensor_id);
    correction_param_fname = [fname_top_v0_gcp_cor_param '_gcp_correction_param.mat'];
    dirpath_correction_param = '/Users/yukiitoh/src/matlab/toolbox/crism_toolbox/spice/projection/demo';
    correction_param_fpath = joinPath(dirpath_correction_param,correction_param_fname);
    load(correction_param_fpath,'gcp_correction_param');
else
    vr = 0;
    fname_top = sprintf('%s_%s_MSLGaleDEMproj_v%1d',crism_info.info.dirname,crism_info.info.sensor_id,vr);
end

save_dir  = joinPath('/Volumes/LaCie5TB/data/crism2MSLDEMprojection/', fname_top);
if ~exist(save_dir,'dir')
    mkdir(save_dir);
end

%%
DEdata = CRISMDDRdata(crism_info.info.basenameDDR,crism_info.info.dir_ddr);
DEdata.readimg();
TRRRAdata = CRISMdata(crism_info.info.basenameRA,crism_info.info.dir_trdr);
TRRRAdata.readHKT();[rownum] = TRRRAdata.read_ROWNUM_TABLE();
binx = TRRRAdata.lbl.PIXEL_AVERAGING_WIDTH;

sclk_str = crism_get_sclkstr4spice(TRRRAdata.hkt,'linspace',7);

rMars_m = 3396190; % meters
mrgn_deg = 600 / (rMars_m*pi) * 180; % margin can be whatever.

lat_range = [ ...
    max(DEdata.ddr.Latitude.img,[],'all')+mrgn_deg, ...
    min(DEdata.ddr.Latitude.img,[],'all')-mrgn_deg];
lon_range = [ ...
    min(DEdata.ddr.Longitude.img,[],'all')-mrgn_deg, ...
    max(DEdata.ddr.Longitude.img,[],'all')+mrgn_deg];


%% load SPICE KERNELs
naif_archive_init;
SPICEMetaKrnlsObj = MRO_CRISM_SPICE_META_KERNEL(DEdata);
SPICEMetaKrnlsObj.set_defaut('dwld',0);
% SPICEMetaKrnlsObj.set_kernel_spk_sc_default('KERNEL_ORDER',{''});
SPICEMetaKrnlsObj.furnsh();

%% load radius data
% pds_geosciences_node_setup;
MSLDEMdata = MSLGaleMosaicRadius_v3('MSL_Gale_DEM_Mosaic_1m_v3_dave_ra', ...
    '/Users/yukiitoh/data/');

mslradius_offset     = MSLDEMdata.lbl.OBJECT_IMAGE.OFFSET;
msldem_latitude_rad  = deg2rad(MSLDEMdata.latitude());
msldem_longitude_rad = deg2rad(MSLDEMdata.longitude());

[msldemc_radius,xmsldemc,ymsldemc] = MSLDEMdata.get_subimage_wlatlon(lon_range,lat_range);
msldemc_hdr = [];
msldemc_hdr.samples = size(msldemc_radius,2);
msldemc_hdr.lines   = size(msldemc_radius,1);
msldemc_hdr.sample_offset = xmsldemc(1)-1   ;
msldemc_hdr.line_offset   = ymsldemc(1)-1   ;


% [msldemc_radius] = MSLDEMdata.readimg('precision','raw');

radius_max = double(max(msldemc_radius,[],'all','omitnan')) + mslradius_offset;
radius_min = double(min(msldemc_radius,[],'all','omitnan')) + mslradius_offset;

radius_max_l = double(max(msldemc_radius,[],2,'omitnan')) + mslradius_offset;
radius_min_l = double(min(msldemc_radius,[],2,'omitnan')) + mslradius_offset;
radius_max_c = double(max(msldemc_radius,[],1,'omitnan')) + mslradius_offset;
radius_min_c = double(min(msldemc_radius,[],1,'omitnan')) + mslradius_offset;

clear msldemc_radius xmsldemc ymsldemc;

%% SPICE SETUP
abcorr  =  'CN+S';
switch upper(crism_info.info.sensor_id)
    case 'L'
        camera  = 'MRO_CRISM_IR'; %{'MRO_CTX'}
    case 'S'
        camera  = 'MRO_CRISM_VNIR';
    otherwise
        error('Undefined SENSOR_ID %s',crism_info.sensor_id);
end
fixref  = 'IAU_MARS';
method  = 'Ellipsoid'; %'DSK/UNPRIORITIZED'; % or Ellipsoid
obsrvr  = 'MRO';
target  = 'Mars';
NCORNR  = 4;
SC      = -74999; % high precision sclkscet needs 999.
%
% Get the MRO CRISM IR camera ID code. Then look up the field of view (FOV)
% parameters.
%
[ camid, found ] = cspice_bodn2c( camera );
if ( ~found )
    error([ 'SPICE(NOTRANSLATION) ' ...
        'Could not find ID code for instrument %s.' ], ...
        camera);
end
%
% cspice_getfov will return the name of the camera-fixed frame in the 
% string 'dref', the camera boresight vector in the array 'bsight', and the
% FOV corner vectors in the array 'bounds'.
%
[shape, dref, bsight, cambounds] = cspice_getfov( camid, NCORNR);

%%
Ncrism = TRRRAdata.hdr.samples;
[Ncrism_full] = crism_get_nCol_full_resolution();
% binx = TRRRAdata.lbl.PIXEL_AVERAGING_WIDTH;
fname_ik_krnl = SPICEMetaKrnlsObj.ik.fname_krnl;
[crism_camera_info] = crism_ik_kernel_load(fname_ik_krnl,TRRRAdata);
[cahv_mdl] = crism_get_cahv_mdl_adhoc(crism_camera_info);

[pmc_pxlctrsfull] = crism_get_pmc_pxlctrs(crism_camera_info,cahv_mdl, ...
    'PROJ_MODE', 'AngularX');

[pmc_pxlctrs] = crism_get_pmc_pxlctrs(crism_camera_info,cahv_mdl, ...
    'PROJ_MODE', 'AngularX','binx',binx);

pmc_pxlctrsfull_imxy = cahv_mdl.get_xy_from_p_minus_c(pmc_pxlctrsfull);

% FOV borders
% if we take the border as more broader region considering PSF, set mrgn>0
mrgn = 1.5;
[pmc_fovbndvrtcs] = crism_get_pmc_fovbndvrtcs(crism_camera_info,cahv_mdl,...
    'Margin',mrgn,'PROJ_MODE_CTR','AngularX','PROJ_MODE_VRTCS','Planar');

[pmc_pxlvrtcsCell_full] = crism_get_pmc_pxlvrtcsCell(crism_camera_info, ...
    cahv_mdl,'MARGIN',mrgn,'PROJ_MODE_CTR','AngularX','PROJ_MODE_VRTCS','Planar');
sgm_psf = 0.53;

%
% [pmc_pxlbrdrctrsfull] = crism_get_pmc_pxlbrdrctrs(crism_camera_info,cahv_mdl, ...
%     'Margin',mrgn,'PROJ_MODE_CTR','AngularX','PROJ_MODE_VRTCS','AngularX');
% pmc_pxlbrdctrsfull_imxy = cahv_mdl.get_xy_from_p_minus_c(pmc_pxlbrdrctrsfull);
% pmc_pxlbrdctrsfull_imx = pmc_pxlbrdctrsfull_imxy(1,:);

thresh = 0.01;

%%
% radii = cspice_bodvrd( 'MARS', 'RADII', 3 );

L = size(sclk_str,1);
N = size(sclk_str,2);

% crism_FOVcell = cell(L,Ncrism);
crismPxl_sofst = (-1)*ones(L,Ncrism,'int32');
crismPxl_lofst = (-1)*ones(L,Ncrism,'int32');
crismPxl_smpls = (-1)*ones(L,Ncrism,'int32');
crismPxl_lines = (-1)*ones(L,Ncrism,'int32');

%%
for l=1:L
    %%
    fprintf('Start processing for line=%d\n',l);
    tic;
    % binning will be applied when one exposure measurements are applied.
    crism_FOVcells_l   = cell(N,Ncrism_full);
    crismPxl_sofst_l = (-1)*ones(N,Ncrism_full,'int32');
    crismPxl_lofst_l = (-1)*ones(N,Ncrism_full,'int32');
    crismPxl_smpls_l = (-1)*ones(N,Ncrism_full,'int32');
    crismPxl_lines_l = (-1)*ones(N,Ncrism_full,'int32');
    
    for n=1:N
        % fprintf('j=%d\n',j);
        % tic;
        sclkch = sclk_str{l,n};
        
        %%
        % SPICE part of the processing
        % Get two values
        % 1 Position of MRO with respect to Mars
        % 2 Rotation matrix that converts the camera fixed coordinate to 
        %   the fixref (probably, IAU_MARS) coordinate
        [pos_mro_wrt_mars,rotate,etrec,etemit] = spice_get_pos_rotmat( ...
            SC,method,target,fixref,abcorr,obsrvr,dref,bsight,sclkch);
        
        if correction
            [rotate_fix] = crism_proj_get_gcpcor_rotmat(etrec,etemit,gcp_correction_param);
            rotate = rotate_fix * rotate;
        end
        
        %% Get rough imFOVmask 
        % for speeding up subsequent exact msldemc_imFOVmask detection
        %
        % find the smaller enclosing region of msldem_radius and
        % more restricted upper and lower limit of the radius.
        % tic;
        [~,radius_minij,radius_maxij] = ... 
            get_msldemcc_radminmax(rotate,pmc_fovbndvrtcs,pos_mro_wrt_mars, ...
            radius_min,radius_max,MSLDEMdata,msldemc_hdr, ...
            radius_min_l,radius_min_c,radius_max_l,radius_max_c);
        % toc;
        
        %
        % get the enclosing region for each pixel.
        % tic;
        % this is faster
        [msldemcc_hdr,crismPxl_smplofst_ap, crismPxl_smpls_ap,  ...
            crismPxl_lineofst_ap, crismPxl_lines_ap] ...
            = crism_get_pxlslranges_wRadiusMaxMin_v3(pos_mro_wrt_mars,...
            rotate, pmc_pxlvrtcsCell_full,radius_minij,radius_maxij,MSLDEMdata,msldemc_hdr);
        
        
        [lList_cofst_ap,lList_cols_ap] = crism_combine_FOVap_v2_mex( ...
            msldemcc_hdr,crismPxl_smplofst_ap, crismPxl_smpls_ap,  ...
            crismPxl_lineofst_ap, crismPxl_lines_ap);
        
        % msldemc_imFOVmask_ap = crism_get_FOVap_mask_from_lList_crange_mex(msldemcc_hdr,lList_cofst_ap,lList_cols_ap);

        %%
        % The IFOV pixel vector in the camera coordinate are rotated into the
        % IAU_MARS reference frame.
        %
        [cahv_mdl_iaumars_etemit] = transform_CAHVOR_MODEL(cahv_mdl,rotate, ...
            'Translation_vector',pos_mro_wrt_mars,'Translation_Order','after');
        
        %% Get exact msldemc_imFOVmask
        % tic;
        [msldemc_imFOVmask, ...
            lList_lofst,lList_lines,lList_cofst,lList_cols] = ...
            crism_gale_get_msldemFOV_scf2_L2_mex(...
                MSLDEMdata.imgpath,      ... 0
                MSLDEMdata.hdr,          ... 1
                mslradius_offset,        ... 2
                msldemcc_hdr,            ... 3
                msldem_latitude_rad,     ... 4
                msldem_longitude_rad,    ... 5
                lList_cofst_ap,          ... 6
                lList_cols_ap,           ... 7
                cahv_mdl_iaumars_etemit, ... 8
                pmc_pxlctrsfull_imxy,    ... 9
                sgm_psf,                 ... 10
                mrgn                     ... 11
            );
        % toc;
        
        %% Find out invisible pixels (takes time, turned off by default)
        if 0
            tic; [ msldemc_imUFOVmask_ctr] =  ...
                    iaumars_get_msldemtUFOVmask_ctr_L2PBK_LL0_M3_4crism_mex(...
                    MSLDEMdata.imgpath,      ... 0
                    MSLDEMdata.hdr,          ... 1
                    MSLDEMdata.OFFSET,       ... 2
                    msldemcc_hdr,            ... 3
                    msldem_latitude_rad,     ... 4
                    msldem_longitude_rad,    ... 5
                    msldemc_imFOVmask,       ... 6
                    lList_lofst,             ... 7
                    lList_lines,             ... 8
                    lList_cofst,             ... 9
                    lList_cols,              ... 10
                    640,                     ... 11 S_im
                    1,                       ... 12 L_im
                    cahv_mdl_iaumars_etemit, ... 13 
                    50,                      ... 14 K_L
                    50,                      ... 15 K_S
                    1                        ... 16 dyu
                    ); 
            toc;
        end
        %% Get pixel footprint function PFF
        % tic;
        [crism_FOVcell_ln,crismPxl_sofst_ln,crismPxl_smpls_ln, ...
            crismPxl_lofst_ln,crismPxl_lines_ln] = ...
            crism_gale_get_msldemFOVcell_PFF_L2fa2_mex(...
                MSLDEMdata.imgpath,      ... 0
                MSLDEMdata.hdr,          ... 1
                mslradius_offset,        ... 2 
                msldemcc_hdr,            ... 3
                msldem_latitude_rad,     ... 4
                msldem_longitude_rad,    ... 5
                msldemc_imFOVmask,       ... 6
                lList_lofst,             ... 7
                lList_lines,             ... 8
                lList_cofst,             ... 9
                lList_cols,              ...10
                cahv_mdl_iaumars_etemit, ...11
                pmc_pxlctrsfull_imxy,    ...12
                sgm_psf,                 ...13
                mrgn,                    ...14
                thresh                   ...15
            );
        % toc;
        
        
        
        %% storing the result for combining FOV

        crism_FOVcells_l(n,:) = crism_FOVcell_ln;
        
        % Pixel ranges are stacked.
        % index values are based on the original DEM image
        crismPxl_sofst_l(n,:) = crismPxl_sofst_ln+msldemcc_hdr.sample_offset;
        crismPxl_lofst_l(n,:) = crismPxl_lofst_ln+msldemcc_hdr.line_offset;
        crismPxl_smpls_l(n,:) = crismPxl_smpls_ln;
        crismPxl_lines_l(n,:) = crismPxl_lines_ln;
        
        
        
    end
    % toc;
    %
    % combine FOV cells for the division of the FOV cells
    % tic;
    [crism_FOVcell_lcomb,crismPxl_sofst_lcomb,crismPxl_smpls_lcomb, ...
        crismPxl_lofst_lcomb, crismPxl_lines_lcomb] ...
        = crism_combine_FOVcell_PSF_1expo_v3_mex( ...
            crism_FOVcells_l, ... 0
            crismPxl_sofst_l, ... 1
            crismPxl_smpls_l, ... 2
            crismPxl_lofst_l, ... 3
            crismPxl_lines_l  ... 4
        );
    
    % Bin FOV cells
    [crism_FOVcell_lcombbin, ...
        crismPxl_sofst_lcombbin, crismPxl_smpls_lcombbin, ...
        crismPxl_lofst_lcombbin, crismPxl_lines_lcombbin] ...
        = crism_bin_FOVcell_PFF_1line( ...
            binx                 , ...
            crism_FOVcell_lcomb  , ...
            crismPxl_sofst_lcomb , ...
            crismPxl_smpls_lcomb , ...
            crismPxl_lofst_lcomb , ...
            crismPxl_lines_lcomb   ...
        );
    
    
%     crism_FOVcell(i,:) = crism_FOVcell_l_cmb;
    crismPxl_sofst(l,:)= crismPxl_sofst_lcombbin;
    crismPxl_smpls(l,:)= crismPxl_smpls_lcombbin;
    crismPxl_lofst(l,:)= crismPxl_lofst_lcombbin;
    crismPxl_lines(l,:)= crismPxl_lines_lcombbin;
    crism_FOVcell_lcomb = crism_FOVcell_lcombbin;
    
    % toc;
    %
    % saving the each pixel footprint
    fprintf('Now saving ...');
    bname = sprintf('%s_l%03d',fname_top,l);
    fpath = joinPath(save_dir,[bname '.mat']);
    for s=1:Ncrism
        crism_FOVcell_lcomb{s} = single(crism_FOVcell_lcomb{s});
    end
    % tic;
    save(fpath,'crism_FOVcell_lcomb','-nocompression');
    % toc;
    
%     for s=1:640
%         bname = sprintf('%s_l%03ds%03d',fname_top,l-1,s-1);
%         img = single(crism_FOVcell_lcomb{s});
%         hdr_ls = [];
%         dt = datetime('now','TimeZone','local','Format','eee MMM dd hh:mm:ss yyyy');
%         hdr_ls.description = sprintf('{CRISM PFF [%s] header editted timestamp}',dt);
%         hdr_ls.samples = crismPxl_smpls_lcomb(s);
%         hdr_ls.lines   = crismPxl_lines_lcomb(s);
%         hdr_ls.bands   = 1;
%         hdr_ls.header_offset = 0;
%         hdr_ls.file_type = 'ENVI Standard';
%         hdr_ls.data_type = 4; % 4 for float
%         hdr_ls.interleave = 'bsq';
%         hdr_ls.sensor_type = 'Unknown';
%         hdr_ls.byte_order = 0;
%         
%         fpath = joinPath(save_dir,bname);
%         envihdrwritex(hdr_ls,[fpath '.hdr'],'OPT_CMOUT',false);
%         envidatawrite(img,[fpath '.img'],hdr_ls);
%         
%     end
    fprintf('Done.\n');
    toc;
end

%% SAVE files
% save offsets and # of samples and lines
% Sample Line Matrix
fname_meta = sprintf('%s_SLM.mat',fname_top);
fpath = joinPath(save_dir,fname_meta);
save(fpath,'crismPxl_lofst','crismPxl_sofst','crismPxl_smpls','crismPxl_lines');

%% POST PROCESSING
% load(fpath,'crismPxl_lofst','crismPxl_sofst','crismPxl_smpls','crismPxl_lines');

crismpff = CRISMPFFonMSLDEM(fname_top,save_dir,MSLDEMdata);

%==========================================================================
% Process projection results
%==========================================================================
line_offset = 0; Nlines = TRRRAdata.hdr.lines;
[msldemc_hdr,msldemc_imFOVres,msldemc_imFOVsmpl,msldemc_imFOVline] ...
    = crism_combine_FOVcell_PSF_multiPxl_v2(  ...
    fname_top, save_dir, line_offset, Nlines, ...
    crismPxl_sofst, crismPxl_smpls, crismPxl_lofst,crismPxl_lines);

%%
%==========================================================================
% save glt data
%==========================================================================
hdr_crism_glt = mslgaleMosaicCrop_get_envihdr(MSLDEMdata,msldemc_hdr, ...
    'data_type',2,'bands',2,'band_names',{'glt_x','glt_y'},'data_ignore_value',-1);

gltim = cat(3,msldemc_imFOVsmpl,msldemc_imFOVline);
basename_crism_glt = [ fname_top '_GLT'];
envihdrwritex(hdr_crism_glt,[basename_crism_glt '.hdr'],'OPT_CMOUT',false);
envidatawrite(gltim,[basename_crism_glt '.img'],hdr_crism_glt);

%%
%==========================================================================
% CRISM projection using the GLT
%==========================================================================

GLTdata = ENVIRasterMultBandMSLDEMCProj(basename_crism_glt,'./');

switch sensor_id
    case 'L'
        switch upper(obs_id)
            case 'B6F1'
                TRR3dataset = CRISMTRRdataset(crism_info.info.basenameIF,'');
                pdir_crism_img = '/Volumes/LaCie/data/crism/yuki/gale_rachel_ds';
                dir_crism_img  = joinPath(pdir_crism_img,TRR3dataset.trr3if.dirname);
                sabcond_data = SABCONDdataset(TRR3dataset.trrcif.basename,dir_crism_img,...
                    'suffix','atcr_sabcondv5_1_Lib1164_1_4_3_tb395_T05_take2');
                sabcond_data.nr_ds.set_rgb();
                crism_rgb = sabcond_data.nr_ds.RGB.CData_Scaled(:,:,3);
                b = sabcond_data.nr_ds.hdr.default_bands(3);

            case 'BABA'
                TRR3dataset = CRISMTRRdataset(crism_info.info.basenameIF,'');
                pdir_crism_img = '/Volumes/LaCie/data/crism/yuki/crism_challenge/';
                dir_crism_img  = joinPath(pdir_crism_img,TRR3dataset.trr3if.dirname);
                sabcond_data = SABCONDdataset(TRR3dataset.trr3if.basename,dir_crism_img,...
                    'suffix','atcr_sabcondv4_1_Lib11123_1_4_5_l1_gadmm_a_v2_ca_ice_b200');

                sabcond_data.nr.set_rgb();
                crism_rgb = sabcond_data.nr.RGB.CData_Scaled(:,:,3);
                b = sabcond_data.nr.hdr.default_bands(3);

            otherwise
                error('Undefined OBSERVATION ID');
        end
        
    case 'S'
        TRR3dataset = CRISMTRRdataset(crism_info.info.basenameIF,'');
        TRR3dataset.trr3if.set_rgb();
        crism_rgb = TRR3dataset.trr3if.RGB.CData_Scaled(:,:,3);
        
    otherwise
        error('Undefined SENSOR_ID %s',sensor_id);
        
end

crism_rgb_proj = img_proj_w_gltxy(crism_rgb, ...
    double(msldemc_imFOVsmpl),double(msldemc_imFOVline));
crism_rgb_proj = uint8(crism_rgb_proj);

% Save the projected image
hdr_crism_proj = mslgaleMosaicCrop_get_envihdr(MSLDEMdata,GLTdata.chdr, ...
    'data_type',1,'bands',1,'data_ignore_value',0);

% hdr_crism_proj = hdr_crism_glt;
% hdr_crism_proj.samples = size(crism_rgb_proj,2);
% hdr_crism_proj.lines   = size(crism_rgb_proj,1);
% hdr_crism_proj.bands   = 1;
% hdr_crism_proj.data_type = 1;
% hdr_crism_proj = rmfield(hdr_crism_proj,'data_ignore_value');
% hdr_crism_proj = rmfield(hdr_crism_proj,'band_names');

basename_crism_rgb_proj = [ fname_top sprintf('_b%03d_uint8',b)];
envihdrwritex(hdr_crism_proj,[basename_crism_rgb_proj '.hdr'],'OPT_CMOUT',false);
envidatawrite(crism_rgb_proj,[basename_crism_rgb_proj '.img'],hdr_crism_proj);

%%
crism_rgb_proj = ENVIRasterSingleLayerMSLDEMCProj(basename_crism_rgb_proj,'./');




