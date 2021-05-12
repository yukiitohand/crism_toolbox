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
mrgn = 1.5;
[pmc_fovbndvrtcs] = crism_get_pmc_fovbndvrtcs(crism_camera_info,cahv_mdl,...
    'Margin',mrgn,'PROJ_MODE_CTR','AngularX','PROJ_MODE_VRTCS','Planar');

[pmc_pxlvrtcsCell] = crism_get_pmc_pxlvrtcsCell(crism_camera_info, ...
    cahv_mdl,'MARGIN',mrgn,'PROJ_MODE_CTR','AngularX','PROJ_MODE_VRTCS','Planar');
sgm_psf = 0.67;

%
[pmc_pxlbrdrctrs] = crism_get_pmc_pxlbrdrctrs(crism_camera_info,cahv_mdl, ...
    'Margin',mrgn,'PROJ_MODE_CTR','AngularX','PROJ_MODE_VRTCS','AngularX');
pmc_pxlbrdctrs_imxy = cahv_mdl.get_xy_from_p_minus_c(pmc_pxlbrdrctrs);
pmc_pxlbrdctrs_imx = pmc_pxlbrdctrs_imxy(1,:);

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

vr = 0;
fname_top = sprintf('%s_MSLGaleDEMproj_v%1d',crism_info.info.dirname,vr);
save_dir  = joinPath('/Users/yukiitoh/src/matlab/crism_projection/', fname_top);
if ~exist(save_dir,'dir')
    mkdir(save_dir);
end

%%
for l=1:L
    fprintf('Start processing for line=%d\n',l);
    tic;
    crism_FOVcells_l   = cell(N,Ncrism);
    crismPxl_sofst_l = (-1)*ones(N,Ncrism,'int32');
    crismPxl_lofst_l = (-1)*ones(N,Ncrism,'int32');
    crismPxl_smpls_l = (-1)*ones(N,Ncrism,'int32');
    crismPxl_lines_l = (-1)*ones(N,Ncrism,'int32');
    
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
                pmc_pxlctrs_imxy,        ...12
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
    %%
    [crism_FOVcell_lcomb,crismPxl_sofst_lcomb,crismPxl_smpls_lcomb, ...
        crismPxl_lofst_lcomb, crismPxl_lines_lcomb] ...
        = crism_combine_FOVcell_PSF_1expo_v3_mex( ...
            crism_FOVcells_l, ... 0
            crismPxl_sofst_l, ... 1
            crismPxl_smpls_l, ... 2
            crismPxl_lofst_l, ... 3
            crismPxl_lines_l  ... 4
        );
    
%     crism_FOVcell(i,:) = crism_FOVcell_l_cmb;
    crismPxl_sofst(l,:)= crismPxl_sofst_lcomb;
    crismPxl_smpls(l,:)= crismPxl_smpls_lcomb;
    crismPxl_lofst(l,:)= crismPxl_lofst_lcomb;
    crismPxl_lines(l,:)= crismPxl_lines_lcomb;
    
    
    toc;
    %%
    % saving the each pixel footprint
    fprintf('Now saving ...');
    bname = sprintf('%s_l%03d',fname_top,l-1);
    fpath = joinPath(save_dir,[bname '.mat']);
    for s=1:640
        crism_FOVcell_lcomb{s} = single(crism_FOVcell_lcomb{s});
    end
    save(fpath,'crism_FOVcell_lcomb');
    
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
    
end

%%
% save offsets and # of samples and lines
% Sample Line Matrix
fname_meta = sprintf('%s_SLM.mat',fname_top);
fpath = joinPath(save_dir,fname_meta);
save(fpath,'crismPxl_lofst','crismPxl_sofst','crismPxl_smpls','crismPxl_lines');


