function [valid_lines_bool,errcode] = mro_crism_eval_frame_connectivity(obs_id,varargin)
is_debug = false;
yyyy_doy = []; obs_class_type = []; sensor_id = 'S';
% THreshold COEFficients multiplied to 
thcoef4fncfr_algtrkfrsprd_prc = 1.75;
% thcoef4fncfr_algtrkfrsprd_prc = 2.0;
% THreshold value to 
% thfpcfr_minnbfrdist = 300; % [meters]

use_local_radius = false;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'SENSOR_ID'
                sensor_id = varargin{i+1};
            case 'YYYY_DOY'
                yyyy_doy = varargin{i+1};
            case 'OBS_CLASS_TYPE'
                obs_class_type = varargin{i+1};
            case 'USE_LOCAL_RADIUS'
                use_local_radius = varargin{i+1};
            case 'DEBUG'
                is_debug = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

%%
% =========================================================================
%  PRE-PROCESSING SECTION
%  SEARCH FILENAME OF CENTRAL SCAN I/F IMAGE CUBE, HKP TABLE, and DDR DE
%  image cube. This is tailored for faster processing...
% =========================================================================
if isempty(yyyy_doy) || isempty(obs_class_type)
    [ yyyy_doy,obs_class_type ] = crism_searchOBSID2YYYY_DOY_v2(obs_id);
end
dirname = sprintf('%3s%08s',obs_class_type,obs_id);

[basename_trrif_cs,errcode,dir_trr,basename_trrhkp_cs] = ... 
    mro_crism_get_basename_trrif_cs_fast(obs_id,yyyy_doy,obs_class_type,sensor_id);
if errcode>0, valid_lines_bool = []; return; end

TRRIFdata = CRISMdata(basename_trrif_cs,dir_trr,'observation');
[errcode] = mro_crism_validate_image_sample_size(TRRIFdata);
if errcode>0, valid_lines_bool = []; return; end

[basename_ddrde_cs,errcode,dir_ddr] = mro_crism_get_basename_ddrde_cs_fast( ...
    obs_id,yyyy_doy,obs_class_type,sensor_id,TRRIFdata.prop.activity_macro_num);
if errcode>0, valid_lines_bool = []; return; end
DEdata = CRISMDDRdata(basename_ddrde_cs,dir_ddr);

if is_debug
    switch upper(sensor_id)
        case 'S'
            bref = 62;
        case 'L'
            bref = 350;
    end
    imb = TRRIFdata.lazyEnviReadb(bref);
    figure; imsc(hard_percentile_thresholding(imb,0.001));
    set(gca,'dataAspectRatio',[1 1 1]);
    title(sprintf('%s: Original image with disconnected frames', dirname));
end

%%
% =========================================================================
%                      OBTAIN DISCONNECTED FRAMES
% =========================================================================
hkp_fpath = fullfile(dir_trr,basename_trrhkp_cs);
%--------------------------------------------------------------------------
% Along Track Frame Spread
%  measure how smeared each frame is in the along track direction.
%  How many meters the surface intercept of the boresight moved between the
%  start and the stop of the exposure of each frame.
%--------------------------------------------------------------------------
[algtrkfrsprd,xyz_iaumars] = mro_crism_algtrkFrameSpread(DEdata,hkp_fpath);

if use_local_radius
    valid_lines_bool = algtrkfrsprd < 100;
    % rMars = 3396.19 * 10^3;
    switch upper(sensor_id)
        case 'S'
            s_ref = 326;
            % rounded the pixel indices at the boresight at band 39
            % (reference band in ik kernel)
        case 'L'
            s_ref = 334;
            % rounded the pixel indices at the boresight at band 240
            % (reference band in ik kernel)
        otherwise
            error('Undefined sensor_id %s',sensor_id);
    end
    binx = DEdata.lbl.PIXEL_AVERAGING_WIDTH;
    s_ref = round(s_ref/binx);
    valid_lines = find(valid_lines_bool);
    l_ref = valid_lines(round(length(valid_lines)/2));
    DEdata.readimg();
    pclat_slref = DEdata.ddr.Latitude.img(l_ref,s_ref);
    lon_slref   = DEdata.ddr.Longitude.img(l_ref,s_ref);
    [rMars_local] = mgsmola_get_radius(pclat_slref,lon_slref);
    [algtrkfrsprd,xyz_iaumars] = mro_crism_algtrkFrameSpread(DEdata, ...
        hkp_fpath,'radii',rMars_local);
end
% SEQuential FRame DISTance
seq_frdist = sqrt(sum((xyz_iaumars(1:end-1,:,2) - xyz_iaumars(2:end,:,2)).^2,2));
valid_lines_bool = algtrkfrsprd < 100;


if ~any(valid_lines_bool)
    fprintf('%s: no valid frame found.\n',dirname);
    errcode = 5;
else
    %----------------------------------------------------------------------
    % False and miss detections around edge frames are corrected
    %----------------------------------------------------------------------
    valid_lines = find(valid_lines_bool);

    % More restrictive threshold on minimal neighboring frame distance for
    % the evaluation of the connectivity around edge frames.
    num_vl = sum(valid_lines_bool);

    seq_frdist_con = seq_frdist(valid_lines(1):(valid_lines(end)-1));

    rMars_e = 3396190; rMars_p = 3376200;
    switch upper(sensor_id)
        case 'S'
            s_ref = 326;
            % rounded the pixel indices at the boresight at band 39
            % (reference band in ik kernel)
        case 'L'
            s_ref = 334; 
            % rounded the pixel indices at the boresight at band 240
            % (reference band in ik kernel)
        otherwise
            error('Undefined sensor_id %s',sensor_id);
    end
    binx = DEdata.lbl.PIXEL_AVERAGING_WIDTH;
    s_ref = round(s_ref/binx);
    valid_lines = find(valid_lines_bool);
    l_ref = valid_lines(round(length(valid_lines)/2));
    DEdata.readimg();
    pclat_slref = DEdata.ddr.Latitude.img(l_ref,s_ref);
    lon_slref   = DEdata.ddr.Longitude.img(l_ref,s_ref);
    pclats_srefDDR = DEdata.ddr.Latitude.img(:,s_ref);
    lons_srefDDR   = DEdata.ddr.Longitude.img(:,s_ref);
    % intercept of the boresight vector of each frame obtained from DDR DE data.
    [xpcDDR,ypcDDR,zpcDDR] = mars_latlon2xyzpc(pclats_srefDDR,lons_srefDDR,rMars_e,rMars_p);
    xyzpc_srefDDR = [xpcDDR,ypcDDR,zpcDDR];
    % SEQuential FRame DISTance
    seq_frdistDDR = sqrt(sum((xyzpc_srefDDR(1:end-1,:) - xyzpc_srefDDR(2:end,:)).^2,2));
    seq_frdistDDR_con = seq_frdistDDR(valid_lines(1):(valid_lines(end)-1));
    
    thcfr_algtrkfrsprd_tight = max(80,thcoef4fncfr_algtrkfrsprd_prc * prctile(algtrkfrsprd(valid_lines),100*(1-4/num_vl)));
    % thcfr_seqfrdist_tight = thcoef4fncfr_algtrkfrsprd_prc * prctile(seq_frdist_con(1:min(100,num_vl-1)),100*(1-4/min(100,num_vl-1)));
    thcfr_seqfrdistDDR_tight = min(200,max(80,thcoef4fncfr_algtrkfrsprd_prc * prctile(seq_frdistDDR_con,100*(1-4/(num_vl-1)))));
    if algtrkfrsprd(valid_lines(1)) > thcfr_algtrkfrsprd_tight ...
            ... || seq_frdist(valid_lines(1)) > thcfr_seqfrdist_tight ...
            || seq_frdistDDR(valid_lines(1)) > thcfr_seqfrdistDDR_tight
        fprintf('%s: line %d is disconnected.\n',dirname,valid_lines(1));
        valid_lines_bool(valid_lines(1)) = false;
        % if length(valid_lines)>1 && algtrkfrsprd(valid_lines(1)+1) > thcfr_algtrkfrsprd_tight
        %     fprintf('%s: second valid line may be disconnected.\n',dirname);
        % end
        i=1;
        while i<length(valid_lines) && algtrkfrsprd(valid_lines(1)+i) > thcfr_algtrkfrsprd_tight ...
                ... || seq_frdist(valid_lines(1)+i) > thcfr_seqfrdist_tight ...
                || seq_frdistDDR(valid_lines(1)+i) > thcfr_seqfrdistDDR_tight
            fprintf('%s: line %d is disconnected.\n',dirname,valid_lines(1)+i);
            valid_lines_bool(valid_lines(1)+i) = false;
            i = i+1;
        end
    end

    % thcfr_algtrkfrsprd_tight = thcoef4fncfr_algtrkfrsprd_prc * prctile(algtrkfrsprd(valid_lines),100*(1-4/num_vl));
    % thcfr_seqfrdist_tight = thcoef4fncfr_algtrkfrsprd_prc * prctile(seq_frdist_con(max(1,num_vl-100):num_vl-1),100*(1-4/min(100,num_vl-1)));
    % thcfr_seqfrdistDDR_tight = thcoef4fncfr_algtrkfrsprd_prc * prctile(seq_frdistDDR_con,100*(1-4/(num_vl-1)));
    if algtrkfrsprd(valid_lines(end)) > thcfr_algtrkfrsprd_tight ...
            ... || (valid_lines(end)>1 && seq_frdist(valid_lines(end)-1) > thcfr_seqfrdist_tight) ...
            || (valid_lines(end)>1 && seq_frdistDDR(valid_lines(end)-1) > thcfr_seqfrdistDDR_tight)
        fprintf('%s: line %d is disconnected.\n',dirname,valid_lines(end));
        valid_lines_bool(valid_lines(end)) = false;
        % if valid_lines(end)>1 && algtrkfrsprd(valid_lines(end)-1) > thcfr_algtrkfrsprd_tight
        %     fprintf('%s: second last valid line is disconnected.\n',dirname);
        % end
        i=1;
        while valid_lines(end)-i>valid_lines(1) && algtrkfrsprd(valid_lines(end)-i) > thcfr_algtrkfrsprd_tight ...
                ... || (valid_lines(end)>i+1 && seq_frdist(valid_lines(end)-i-1) > thcfr_seqfrdist_tight) ...
                || (valid_lines(end)>i+1 && seq_frdistDDR(valid_lines(end)-i-1) > thcfr_seqfrdistDDR_tight)
            fprintf('%s: line %d is disconnected.\n',dirname,valid_lines(end)-i);
            valid_lines_bool(valid_lines(end)-i) = false;
            i = i+1;
        end
    end
    %----------------------------------------------------------------------
    % Check also any obvious discontinuities with sequential frame distance
    %----------------------------------------------------------------------
    % valid_lines = find(valid_lines_bool); % num_vl = sum(valid_lines_bool);
    % seq_frdist_con = seq_frdist(valid_lines(1):(valid_lines(end)-1));
    
    % dcfr = seq_frdist_con > 200; %min(1.5 * prctile(seq_frdist_con,100*(1-4/num_vl)),300);
    % if any(dcfr)
    %     fprintf('%s: frames may have discontinuities.\n',dirname);
    %     errcode = 8;
    % end

    % dcfr_soft = seq_frdist_con > 2*prctile(seq_frdist_con,99);
    % if any(dcfr_soft)
    %     fprintf('%s: frames could have discontinuities.\n',dirname);
    %     errcode = 8;
    % end
    
    valid_lines = find(valid_lines_bool);
    seq_frdistDDR_con = seq_frdistDDR(valid_lines(1):(valid_lines(end)-1));
    if any(diff(valid_lines)>1)
        fprintf('%s: Disconnected frame(s) is detected in-between.\n',dirname);
        errcode = 6;
    end
    if length(valid_lines) < 20
        fprintf('%s: Too few connected frame(s) are detected.\n',dirname);
        errcode = 7;
    elseif length(valid_lines)<100
        fprintf('%s: Many disconnected frame(s) are detected.\n',dirname);
    end

    dcfrDDR = seq_frdistDDR_con > 200; %min(1.5 * prctile(seq_frdist_con,100*(1-4/num_vl)),300);
    if any(dcfrDDR)
        fprintf('%s: frames may have discontinuities with DDR.\n',dirname);
        errcode = 9;
    end

    dcfrDDR_soft = seq_frdistDDR_con > 2*prctile(seq_frdistDDR_con,99);
    if any(dcfrDDR_soft)
        fprintf('%s: frames could have discontinuities with DDR.\n',dirname);
        errcode = 9;
    end

    % if valid_lines(1)>1 && seq_frdistDDR(valid_lines(1)-1) < 1.25*prctile(seq_frdistDDR_con,100*(1-4/(num_vl-1)))
    %     fprintf('%s: first valid lines may be missed.\n',dirname);
    %     errcode = 10;
    % end

    % if valid_lines(end) < length(valid_lines_bool) && seq_frdistDDR(valid_lines(end)) < 1.25*prctile(seq_frdistDDR_con,100*(1-4/(num_vl-1)))
    %     fprintf('%s: last valid lines may be missed first.\n',dirname);
    %     errcode = 10;
    % end


end



if is_debug
    fig_debug1 = figure; set_figsize(fig_debug1,1700,900);



    ax_algtrckpxlsmear = subplot(2,3,2,'Parent',fig_debug1);
    plot(ax_algtrckpxlsmear,algtrkfrsprd,'.'); hold(ax_algtrckpxlsmear,'on');
    plot(ax_algtrckpxlsmear,algtrkfrsprd.*convertBoolTo1nan(~valid_lines_bool),'rO');
    title(ax_algtrckpxlsmear,sprintf('%s:\nAlong Track Pixel Smearing\non the Mars surface.',dirname));

    ax_seqdist = subplot(2,3,5,'Parent',fig_debug1);
    plot(ax_seqdist,seq_frdist,'.'); hold(ax_seqdist,'on');
    title(ax_seqdist,sprintf('%s:\nFrame-Frame distance\non the Mars surface Yuki.',dirname));

    ax_seqdistDDR = subplot(2,3,4,'Parent',fig_debug1);
    plot(ax_seqdistDDR,seq_frdistDDR,'.'); hold(ax_seqdistDDR,'on');
    title(ax_seqdistDDR,sprintf('%s:\nFrame-Frame distance\non the Mars surface DDR.',dirname));
    
    figure; imsc(imb(valid_lines_bool,:)); set(gca,'dataAspectRatio',[1 1 1]);
    title(sprintf('%s: Disconnected frame removed', dirname));

    
    % Projection of the XYZ coordinate to the local tangential coordinate system
    [east,north,zenith] = mars_xyzpc2enzltan(xpcDDR,ypcDDR,zpcDDR, ...
        pclat_slref,lon_slref,rMars_e,rMars_p);
    [east2,north2,zenith2] = mars_xyzpc2enzltan(xyz_iaumars(:,1,2),xyz_iaumars(:,2,2),xyz_iaumars(:,3,2), ...
        pclat_slref,lon_slref,rMars_e,rMars_p);

    ax_tr_traj = subplot(2,3,3,'Parent',fig_debug1);
    pos = ax_tr_traj.Position; pos(2) = pos(2)-0.5; pos(4) = pos(4)+0.5;
    ax_tr_traj.Position = pos;

    p_ctr_traj = plot(ax_tr_traj,east,north,'.-','Color',[0,0.447,0.741]);
    p_ctr_traj.DataTipTemplate.DataTipRows(end+1) = [dataTipTextRow('INDEX',1:size(east,1))];
    hold(ax_tr_traj,'on');
    p_ctr_traj1 = plot(ax_tr_traj,east.*convertBoolTo1nan(~valid_lines_bool), ...
       north.*convertBoolTo1nan(~valid_lines_bool),'O-','Color',[0,0.447,0.741]);
    p_ctr_traj1.DataTipTemplate.DataTipRows(end+1) = [dataTipTextRow('INDEX',1:size(east,1))];
    
    % figure; ax_tr_traj = subplot(1,1,1,'Parente',gcf);
    p_ctr_traj = plot(ax_tr_traj,east2,north2,'.-','Color',[0.85,0.325,0.098]);
    p_ctr_traj.DataTipTemplate.DataTipRows(end+1) = [dataTipTextRow('INDEX',1:size(east2,1))];
    hold(ax_tr_traj,'on');
    p_ctr_traj1 = plot(ax_tr_traj,east2.*convertBoolTo1nan(~valid_lines_bool), ...
       north2.*convertBoolTo1nan(~valid_lines_bool),'O-','Color',[0.85,0.325,0.098]);
    p_ctr_traj1.DataTipTemplate.DataTipRows(end+1) = [dataTipTextRow('INDEX',1:size(east2,1))];

    set(ax_tr_traj,'PlotBoxAspectRatioMode','manual');
    set(ax_tr_traj,'PlotBoxAspectRatio',[1 3 1]);
    set(ax_tr_traj,'DataAspectRatio',[1 1 1]);
    xlabel(ax_tr_traj,'East'); ylabel(ax_tr_traj,'North');
    title(ax_tr_traj,sprintf('%s: frame center trajectory\nin local tangential projected space', dirname));

end


end

% if is_debug
%     [valid_lines_bool,scan_motor_diff,m,options_dcfr] = ...
%         crism_estimate_disconframe_mask_w_scanmotordiff(hkp_fpath, ...
%         'debug',true,'TOL_PRESCREEN',0.01,'TOL_ABS',300,'TOL_RATIO',0.3);
% else
%     [valid_lines_bool] = crism_estimate_disconframe_mask_w_scanmotordiff(hkp_fpath, ...
%         'debug',false,'TOL_PRESCREEN',0.01,'TOL_ABS',300,'TOL_RATIO',0.3);
% end
% 
% if is_debug
%     % store the original connected frame detection based on Scan Motor
%     % Difference.
%     valid_lines_bool_smd = valid_lines_bool;
%     fig_debug1 = figure; set_figsize(fig_debug1,1700,900);
%     ax_smd_fit = subplot(2,3,1,'Parent',fig_debug1);
%     plot(ax_smd_fit, scan_motor_diff,'.'); hold on; plot(m);
%     plot(ax_smd_fit,scan_motor_diff.*convertBoolTo1nan(~valid_lines_bool),'rO');
%     title(ax_smd_fit,sprintf('%s: Fit \non Scan Motor Difference', dirname));
%     r = abs(scan_motor_diff - m);
%     rdivm = r ./ m;
%     ax_residual_abs = subplot(2,3,4,'Parent',fig_debug1);
%     plot(ax_residual_abs,r,'.'); hold on;
%     plot(ax_residual_abs, r.*convertBoolTo1nan(~valid_lines_bool),'rO');
%     title(ax_residual_abs,sprintf('%s: Absolute residual of fit\nto Scan Motor Difference', dirname));
%     ax_residual_ratio = subplot(2,3,5,'Parent',fig_debug1);
%     plot(ax_residual_ratio,rdivm,'.'); hold on;
%     plot(ax_residual_ratio,rdivm.*convertBoolTo1nan(~valid_lines_bool),'rO');
%     title(ax_residual_ratio,sprintf('%s: Ratio residual of fit\nto Scan Motor Difference', dirname));
%     % show I/F image
% end

% %----------------------------------------------------------------------
% % Obvious false and miss detections of connected frames are corrected
% % based on the minimal neighboring frame distance
% %----------------------------------------------------------------------
% % MINnimal NeighBoring FRame DISTance
% minnbfrdist = min([seq_frdist; nan],[nan; seq_frdist],'omitnan');
% minnbfrdist_XXprc = prctile(minnbfrdist(valid_lines_bool),99);
% % Obvious false negative of connected frames
% %  If a connected frame has the minimal neighboring frame distance less
% %  than its XX percentile of thminnbfrdist (default: 95 percentile)
% thfncfr_minnbfrdist = minnbfrdist_XXprc;
% fn_cfr_bool = and(~valid_lines_bool, minnbfrdist<thfncfr_minnbfrdist);
% valid_lines_bool(fn_cfr_bool) = true;
% 
% % Obvious false positive of connected frames
% %  If a connected frame has the minimal neighboring frame distance 
% %  greater than thfpcfr_minnbfrdist (default: 300 [m])
% fp_cfr_bool = and(valid_lines_bool, minnbfrdist>thfpcfr_minnbfrdist);
% valid_lines_bool(fp_cfr_bool) = false;
% 
% % Smeared frames are detected by the Along Track Frame Spread
% fp_cfr_bool = and(valid_lines_bool, algtrkfrsprd>150);

% valid_lines_bool = and(valid_lines_bool, minnbfrdist < 300);