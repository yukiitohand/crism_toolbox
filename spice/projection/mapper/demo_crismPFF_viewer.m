crism_init;
sensor_id  = 'L';
obs_id     = 'b6f1';
correction = true;
sensor_id_gcp_cor_param = 'L';

global crism_env_vars

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

save_dir  = joinPath(crism_env_vars.dir_PFFMSLDEM, fname_top);
if ~exist(save_dir,'dir')
    mkdir(save_dir);
end

%%
switch sensor_id
    case 'L'
        switch upper(obs_id)
            case 'B6F1'
                TRR3dataset = CRISMTRRdataset(crism_info.info.basenameIF,'');
                pdir_crism_img = '/Volumes/LaCie/data/crism/yuki/gale_rachel_ds';
                dir_crism_img  = joinPath(pdir_crism_img,TRR3dataset.trr3if.dirname);
                sabcond_data = SABCONDdataset(TRR3dataset.trrcif.basename,dir_crism_img,...
                    'suffix','atcr_sabcondv5_1_Lib1164_1_4_3_tb395_T05_take2');
                hsi_sab = sabcond_data.nr_ds;
                sabcond_data.nr_ds.set_rgb();
                crism_rgb = sabcond_data.nr_ds.RGB.CData_Scaled(:,:,3);
                b = sabcond_data.nr_ds.hdr.default_bands(3);

            case 'BABA'
                TRR3dataset = CRISMTRRdataset(crism_info.info.basenameIF,'');
                pdir_crism_img = '/Volumes/LaCie/data/crism/yuki/crism_challenge/';
                dir_crism_img  = joinPath(pdir_crism_img,TRR3dataset.trr3if.dirname);
                sabcond_data = SABCONDdataset(TRR3dataset.trr3if.basename,dir_crism_img,...
                    'suffix','atcr_sabcondv4_1_Lib11123_1_4_5_l1_gadmm_a_v2_ca_ice_b200');
                hsi_sab = sabcond_data.nr;
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

%%
basename_crism_rgb_proj = [ fname_top sprintf('_b%03d_uint8',b)];
crism_rgb_proj = ENVIRasterSingleLayerMSLDEMCProj(basename_crism_rgb_proj, ...
    '/Users/yukiitoh/src/matlab/toolbox/crism_toolbox/spice/projection/demo');

MSLDEMdata = MSLGaleMosaicRadius_v3('MSL_Gale_DEM_Mosaic_1m_v3_dave_ra', ...
    '/Users/yukiitoh/data/');
crismpff = CRISMPFFonMSLDEM(fname_top,save_dir,MSLDEMdata);

%%
% v = ENVIRasterMultview(crism_rgb,{sabcond_data.nr_ds});

crismdataMSLDEMdataProjObj = CRISMdataMSLDEMproj(hsi_sab,crismpff);
crismdataMSLDEMdataProjObj.ave_window = [3 3];

%%
crismpff_viewer = CRISMdataMSLDEMprojView(crismdataMSLDEMdataProjObj);

crismpff_viewer.ENVIRasterMultviewObj.obj_SpecView.XLimMargin = [];
crismpff_viewer.ENVIRasterMultviewObj.obj_SpecView.XLimMode = 'manual';
crismpff_viewer.ENVIRasterMultviewObj.obj_SpecView.XLimMan = [1.0 2.6];

crismpff_viewer.ISVobj_proj.add_layer(crism_rgb_proj.get_lon_ctrrange(), ...
    crism_rgb_proj.get_lat_ctrrange(),crism_rgb_proj.readimg('precision','raw'));
crismpff_viewer.ISVobj_proj.image.cmap = 'gray';

%%
msl_init;
[mstdataseq,~] = get_MASTCAMdata('SOL',475,...
    'CAM_CODE','M[RL]{1}','SEQ_ID',1888,...'COMMAND_NUM',0,...
    'CDPID_COUNTER','','UNIQUE_CDPID','',...
    'PRODUCT_TYPE','[CDEF]{1}','GOP','','DATA_PROC_CODE','(DRXX|DRCX)',...
    'VERSION','',...
    'SITE_ID',[],'DRIVE_ID',[],'POSE_ID',[],'RSM_MC',[],'dwld',0,...
    'ROVER_NAV_VERSION','localized_interp_corv3',...
    'ROVER_NAV_MSTCAM_CODE','MR','ROVER_NAV_LINEARIZATION',0);

MSLDEMdata = MSLGaleMosaicRadius_v3('MSL_Gale_DEM_Mosaic_1m_v3_dave_ra', ...
    '/Users/yukiitoh/data/');
mstdataseq(1).update_ROVER_NAV_DEM(MSLDEMdata);


MSTproj = MASTCAMCameraProjectionMSLDEM_v2( ...
    mstdataseq(1).L.DRXX,MSLDEMdata,'Version','v4');
% MSTprojRDRXX.loadCache();
MSTproj.proj_MSLDEM2mastcam('Cache_Ver','v4','Load_cache_ifexist',1, ...
    'force',0,'save_file',1, ...
    'VARARGIN_PROCESS',{'COORDINATE_SYSTEM','IAU_MARS_SPHERE'});
MSTproj.proj_mastcam2MSLDEM('Cache_Ver','v4','Load_cache_ifexist',1,...
    'force',0,'save_file',1, ...
    'VARARGIN_PROCESS',{'COORDINATE_SYSTEM','IAU_MARS_SPHERE'});
MSTproj.msldemc_imFOVmask_eval_13('Cache_Ver','v4','Load_cache_ifexist',1);

MSTproj.getUFOVwMSLDEM('Cache_Ver','v4','lcie',1, ...
    'BORDER_ASSESS_OPT','d','force',false,'COORDINATE_SYSTEM','IAU_MARS_SPHERE',...
    'K_L',30,'K_S',1,'PROC_MODE','L2PBK_LL0DYU_M3');


MSTproj.get_mapper('Cache_Ver','v4','lcie',1,'force',false,...
    'VARARGIN_PROCESS',{'COORDINATE_SYSTEM','IAU_MARS_SPHERE'});

mstdataseq.L.load_AXIX();
mstmsiLAXI1 = mstdataseq.L.MASTCAMMSIConstructor('AXI1');
%%
[crismPFFonMASTCAMObj] = crism_get_PFFonMASTCAM(crismpff,MSTproj,'cache_ver','v1','lcie',0);
crismdataMSLDEMdataProjObj.PFFonMASTCAM = crismPFFonMASTCAMObj;
crismpff_viewer.add_mastcam(MSTproj,{mstmsiLAXI1,'name','AXI1'});