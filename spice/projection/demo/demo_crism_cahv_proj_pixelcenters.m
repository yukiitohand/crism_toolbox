crism_init;
crism_info = CRISMObservation('b6f1','sensor_id','L');

DEdata = CRISMDDRdata(crism_info.info.basenameDDR,crism_info.info.dir_ddr);
DEdata.readimg();
TRRRAdata = CRISMdata(crism_info.info.basenameRA,crism_info.info.dir_trdr);
TRRRAdata.readHKT();[rownum] = TRRRAdata.read_ROWNUM_TABLE();

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
camera  = 'MRO_CRISM_IR'; %{'MRO_CTX'}
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
binx = TRRRAdata.lbl.PIXEL_AVERAGING_WIDTH;
fname_ik_krnl = SPICEMetaKrnlsObj.ik.fname_krnl;
[crism_camera_info] = crism_ik_kernel_load(fname_ik_krnl,TRRRAdata);
[cahv_mdl] = crism_get_cahv_mdl_adhoc(crism_camera_info);

[pmc_pxlctrs] = crism_get_pmc_pxlctrs(crism_camera_info,cahv_mdl, ...
    'PROJ_MODE', 'AngularX');

pmc_pxlctrs_imxy = cahv_mdl.get_xy_from_p_minus_c(pmc_pxlctrs);

% FOV borders
% if we take the border as more broader region considering PSF, set mrgn>0
mrgn = -0.2; % margin is the additional wing (with zero, 0.5 pixels from its centers are evaluated)
[pmc_fovbndvrtcs] = crism_get_pmc_fovbndvrtcs(crism_camera_info,cahv_mdl,...
    'Margin',mrgn,'PROJ_MODE_CTR','AngularX','PROJ_MODE_VRTCS','Planar');

[pmc_pxlvrtcsCell] = crism_get_pmc_pxlvrtcsCell(crism_camera_info, ...
    cahv_mdl,'MARGIN',mrgn,'PROJ_MODE_CTR','AngularX','PROJ_MODE_VRTCS','Planar');
% sgm_psf = 0.67;

%
% [pmc_pxlbrdrctrs] = crism_get_pmc_pxlbrdrctrs(crism_camera_info,cahv_mdl, ...
%     'Margin',mrgn,'PROJ_MODE_CTR','AngularX','PROJ_MODE_VRTCS','AngularX');
% pmc_pxlbrdctrs_imxy = cahv_mdl.get_xy_from_p_minus_c(pmc_pxlbrdrctrs);
% pmc_pxlbrdctrs_imx = pmc_pxlbrdctrs_imxy(1,:);

% thresh = 0.01;

%%
% radii = cspice_bodvrd( 'MARS', 'RADII', 3 );

L = size(sclk_str,1);
N = size(sclk_str,2);

% crism_FOVcell = cell(L,Ncrism);
crismPxlctrx = nan(L,Ncrism,N);
crismPxlctry = nan(L,Ncrism,N);
crismPxlctrz = nan(L,Ncrism,N);

vr = 0;
% fname_top = sprintf('%s_MSLGaleDEMproj_v%1d',crism_info.info.dirname,vr);
% save_dir  = joinPath('/Users/yukiitoh/src/matlab/crism_projection/', fname_top);
% if ~exist(save_dir,'dir')
%     mkdir(save_dir);
% end

%%
for l=1:L
    fprintf('Start processing for line=%d\n',l);
    tic;
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
        [pos_mro_wrt_mars,rotate] = spice_get_pos_rotmat( ...
            SC,method,target,fixref,abcorr,obsrvr,dref,bsight,sclkch);
        
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
            rotate, pmc_pxlvrtcsCell,radius_minij,radius_maxij,MSLDEMdata,msldemc_hdr);
        
        
        [lList_cofst_ap,lList_cols_ap] = crism_combine_FOVap_v2_mex( ...
            msldemcc_hdr,crismPxl_smplofst_ap, crismPxl_smpls_ap,  ...
            crismPxl_lineofst_ap, crismPxl_lines_ap);
        
        % m = crism_get_FOVap_mask_from_lList_crange_mex(msldemcc_hdr,lList_crange);
        

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
                pmc_pxlctrs_imxy,        ... 9
                0,                       ... 10
                mrgn                     ... 11
            );
        % toc;
        
        %% Get pixel footprint function PFF
        % tic;
        [pmc_pxlctrs_iaumars_etemit] = rotate * pmc_pxlctrs;
        [im_xiaumars,im_yiaumars,im_ziaumars,im_refx,im_refy,im_refs, ...
            im_range,im_nnx,im_nny] = ...
            cahvor_iaumars_proj_crism2MSLDEM_v6_mex(...
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
                640,                     ...11
                1,                       ...12
                cahv_mdl_iaumars_etemit, ...13
                pmc_pxlctrs_iaumars_etemit(1,:) ,...14
                pmc_pxlctrs_iaumars_etemit(2,:) ,...15
                pmc_pxlctrs_iaumars_etemit(3,:)  ...16
            );
        % toc;
        
        
        
        %% storing the result for combining FOV
        crismPxlctrx(l,:,n) = im_xiaumars;
        crismPxlctry(l,:,n) = im_yiaumars;
        crismPxlctrz(l,:,n) = im_ziaumars;
        
        
    end
    toc;
end

% Convert 
crismPxl_radius = sqrt(crismPxlctrx.^2 + crismPxlctry.^2 + crismPxlctrz.^2);
crismPxl_latd   = asind(crismPxlctrz./crismPxl_radius);
crismPxl_lond   = atan2d(crismPxlctry,crismPxlctrx);

%%
% save offsets and # of samples and lines
% Sample Line Matrix
% fname_meta = sprintf('%s_SLM.mat',fname_top);
% fpath = joinPath(save_dir,fname_meta);
% save(fpath,'crismPxl_lofst','crismPxl_sofst','crismPxl_smpls','crismPxl_lines');

