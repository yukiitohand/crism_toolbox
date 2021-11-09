function [img_corr_patched,out] = crism_vscor_patch_vs_artifact(waimg,img_corr,vsart)
% [img_corr_patched,out] = crism_vscor_patch_vs_artifact_v2(waimg,img_corr,vsart)
%  Perform artifact correction of the volcano scan correction for CRISM 
%  image. This is translated from idl code:
%      CAT_ENVI/save_add/CAT_programs/Supplementals/patch_vs_artifact.pro
% Tile mode is not supported. This version is closer to the original
% implementation.
% 
% INPUTS
%   waimg: [1 x S x B] wavelength frame associated to img/transmission 
%     Unit [nm]
%   img: [L x S x B] CRISM I/F image to be corrected
%   vsart: [1 x S x B] image frame of artifact correction.
% OUTPUTS
%   img_corr_patched: [L x S x B] patched corrected CRISM I/F image cube
%   out: struct, storing ancillary information of the correction
%     scl        : [L x S] scaling factor of vsart used for the correction
%     merit      : [L x S] merit function value after patching
%     status     : [L x S] status parameter for the correction of each
%      spectrum
%          0: no error
%         -1: not processed
%         -2: merit is inf or -inf
%         -3: zero_derivative
%         -4: reach max iteration
%
% 
% (c) 2021 Yuki Itoh

% merit function parameters:
MERIT_SMW = 3; % Size of the SMooth Window
% if rem(MERIT_SMW, 2)==0, MERIT_SMW=MERIT_SMW+1; end

MAXITER = 10;
status = 0;
zero_deriv_count = 0;
max_iter_count = 0;

[L,S,B] = size(img_corr);

[interp_wave]  = crism_adrvs_artifact_interp_wave();
[interp_bands] = crism_lookupwv(interp_wave,waimg);
interp_bands   = sort(interp_bands,1);

%% Estimation of average continua
% For hyperspectral data, meidian over +/-2 contiguaous bands
% to estimate continuum level at the two ends.
b1 = interp_bands-2;
b2 = interp_bands+2;

md = nan(L,S,2);
for j=1:2
    b1t2_j = nan(5,S);
    for c = 1:S
        b1t2_j(:,c) = b1(j,c):b2(j,c);
    end
    % Mark invalid bands as NaNs.
    b1t2_j(b1t2_j<1) = nan; b1t2_j(b1t2_j>B) = nan;

    % For multispetral, avoid points inside CO2 2-micron region:
    % Mark the bands inside (1930,2115) as NaNs.
    wa_b1t2_j = nan(5,S);
    for n=1:5
        wa_b1t2_j(n,:) = hsi_slice_bandBycolumn(waimg,b1t2_j(n,:));
    end
    is_invalid = and( wa_b1t2_j>1930 , wa_b1t2_j<2115 );
    b1t2_j(is_invalid) = nan;

    img_corr_b1t2_j = nan(L,S,5);
    for n=1:5
        img_corr_b1t2_j(:,:,n) = hsi_slice_bandBycolumn(img_corr,b1t2_j(n,:));
    end
    md(:,:,j) = median(img_corr_b1t2_j,3,'omitnan');
end

avg_cont = mean(md,3,'omitnan');

% for c = 1:S
%     for j=1:2
%         wacb1b2 = squeeze( waimg(1,c,b1(j,c):b2(j,c)) );
%         is_valid = find( or( wacb1b2 < 1930 , wacb1b2 > 2115 ) );
%         if length(is_valid)>1
%             b1(j,c) = b1(j,c) + is_valid(1);
%             b2(j,c) = b1(j,c) + is_valid(end);
%         end
%     end
% end

%%
% group the columns
% Svalid = all(~isnan(interp_bands),1);
% interp_bands_unique = unique(interp_bands(:,Svalid)','rows')';
% Ngrp = size(interp_bands_unique,2);
% Sgrp = cell(1,Ngrp);
% for n=1:Ngrp
%     ibands_n = interp_bands_unique(:,n);
%     Sgrp{n} = find(all(interp_bands==ibands_n,1));
% end
% 
% %
% for n=1:Ngrp
%     s = Sgrp{n};
%     ibands_n = interp_bands_unique(:,n);
%     img_corrx_n = img_corr(:,s,ibands_n(1):ibands_n(2));
%     artx        = vsart(:,s,ibands_n(1):ibands_n(2));
%     avg_cont_n  = avg_cont(:,s);
%     [Ln,Sn,Bn] = size(img_corrx_n);
%     merit = 1.0e23*ones(Ln,Sn);
%     dscl = 1.0e23*ones(Ln,Sn);
%     scl_fac = 1.0*ones(Ln,Sn);
%     niter = 0*ones(Ln,Sn);
%     
%     flg_mat = true(Ln,Sn);
%     
%     idxvalid_patchx = and(~isnan(img_corrx_n),~isnan(artx));
%     idx_toonoisy    = sum(idxvalid_patchx,3)<8;
%     % merit(idx_toonoisy)   = inf;
%     flg_mat(idx_toonoisy) = false;
%     scl_fac(idx_toonoisy) = 0.0;
%     
%     
%     while any(flg_mat,'all')
%         
%         patchx = img_corrx_n + avg_cont_n .* scl_fac .* artx;
%         meritx = evaluate_catvs_patch_3d(patchx, artx, MERIT_SMW);
%         merit(flg_mat) = meritx(flg_mat);
%         
%         delta = max((abs(scl_fac)*1.0e-3), 0.0003);
%         
%         scl_fac2 = scl_fac + delta;
%         patch2 = img_corrx_n + (avg_cont_n .* scl_fac2).* artx;
%         merit2 = evaluate_catvs_patch_3d(patch2, artx, MERIT_SMW);
%         % merit2(flg_mat) = meritx2;
%         
%         dmds = (merit2-merit) ./ delta;
%         % dm/ds: = (merit(scl+dscl)-merit(scl)) / dscl;
%         
%         dscl = -merit ./ dmds;
%         scl_fac_upd = scl_fac+dscl;
%         scl_fac(flg_mat) = scl_fac_upd(flg_mat);
%         
%         scl_fac_eq_0 = or(isinf(merit), isinf(merit2));
%         dmds_toosmall = abs(dmds) < 1e-23;
%         scl_fac_eq_0 = or(scl_fac_eq_0, dmds_toosmall);
%         
%         niter = niter+1;
%         if niter > MAXITER
%             reach_maxiter = flg_mat;
%             scl_fac_eq_0 = or(scl_fac_eq_0, reach_maxiter);
%             flg_mat(:,:)=0;
%         end
%         
%         flg_mat(scl_fac_eq_0) = 0;
%         scl_fac(scl_fac_eq_0) = 0.0;
%         flg_mat(or(abs(merit) < 1.0e-6, abs(dscl) < 1.0e-4)) = 0;
%         
%     end
%     
% end
% 
% img_corr_patched = img_corr;
% 
% out = [];
% % out.scl   = outscl;
% % out.merit = outeval;
% % out.status = status;
% % out.zero_deriv_count = zero_deriv_count;
% % out.max_iter_count = max_iter_count;

%%
img_corr_patched = img_corr;
outscl  = zeros(L,S);
outeval = nan(L,S);
Svalid = find(all(~isnan(interp_bands),1));
for c=Svalid 
    img_corr_cx = squeeze(img_corr(:,c,interp_bands(1,c):interp_bands(2,c)));
    artx = squeeze(vsart(1,c,interp_bands(1,c):interp_bands(2,c)))';
    if sum(~isnan(artx)) >= 8
        for l=1:L
            csx = img_corr_cx(l,:);
            avg_cont_c = avg_cont(l,c);
            merit = 1.0e23;
            dscl = 1.0e23;
            scl_fac = 1.0;
            niter = 0;
            while (abs(merit) > 1.0e-6) && (abs(dscl) > 1.0e-4)
                % Use a newtons method-like approach. Evaluate derivative:
                patchx = csx + avg_cont_c * scl_fac * artx;
                % Evaluate derivative
                merit = evaluate_catvs_patch(patchx, artx, MERIT_SMW);
                delta = max((abs(scl_fac)*1.0e-3), 0.0003);
                scl_fac2 = scl_fac + delta;
                patch2 = csx + (avg_cont_c*scl_fac2)*artx;
                merit2 = evaluate_catvs_patch(patch2, artx, MERIT_SMW);
                dmds = (merit2-merit) / delta; % dm/ds: = (merit(scl+dscl)-merit(scl)) / dscl;

                % Problem checks...
                if isinf(merit) || isinf(merit2)
                    status = 1; scl_fac = 0.0;
                    break;
                end
                if abs(dmds) < 1e-23
                    zero_deriv_count = zero_deriv_count+1;
                    status = 1; scl_fac = 0.0;
                    break;
                end

                dscl = -merit/dmds;
                scl_fac = scl_fac+dscl;
                niter = niter + 1;
                if niter > MAXITER
                    max_iter_count = max_iter_count+1;
                    status = 1; scl_fac = 0.0;
                    break;
                end

            end
            outscl(l,c)  = scl_fac;
            outeval(l,c) = merit;
            
        end

        % patched spectrum:
        img_corr_patched(:,c,interp_bands(1,c):interp_bands(2,c)) =  ...
            img_corr_patched(:,c,interp_bands(1,c):interp_bands(2,c)) ...
            + avg_cont(:,c) .* outscl(:,c) .* vsart(1,c,interp_bands(1,c):interp_bands(2,c));
    end
end

out = [];
out.scl   = outscl;
out.merit = outeval;
out.status = status;
out.zero_deriv_count = zero_deriv_count;
out.max_iter_count = max_iter_count;


end

function [merit] = evaluate_catvs_patch(patch,art,smw)
% if rem(MERIT_SMW, 2)==0, MERIT_SMW=MERIT_SMW+1; end
N_DROP = 3;
wng = (smw-1)/2;
% Filter patch and artifact:
k = ~isnan(patch);
n = sum(k);
if n < 8
    merit = inf;
else

    fpatch = patch(k);
    fart = art(k);


    % Merit is correlation between bands 3 inside art_ntrp
    % fart_smooth = conv(fart,ones(1,smw)/smw,'same');
    % fart_smooth(1:wng) = fart(1:wng); fart_smooth(n-wng+1:n) = fart(n-wng+1:n);
    h = ones(1,smw)/smw;
    fart_smooth = fart;
    fart_smooth((wng+1):(n-wng)) = conv(fart,h,'valid');
    dart = fart - fart_smooth;
    % fpatch_smooth = conv(fpatch,ones(1,smw)/smw,'same');
    % fpatch_smooth(1:wng) = fpatch(1:wng); fpatch_smooth(n-wng+1:n) = fpatch(n-wng+1:n);
    fpatch_smooth = fpatch;
    fpatch_smooth((wng+1):(n-wng)) = conv(fpatch,h,'valid');
    dp = fpatch - fpatch_smooth;


    corr = dp(3:n-4) .* dart(3:n-4);
    corr = sort(corr);

    % Skip extreme pts on each end to avoid spurious points. 
    % Limit number points dropped so at least 5 remain...
    nc = length(corr);
    ndrp = max(min(N_DROP,floor((nc-5)/2)),0);

    merit = sum(corr((1+ndrp):(nc-ndrp)));
end

end


% function [merit] = evaluate_catvs_patch_3d(patch,art,smw)
% % 3 dimensional version
% % if rem(MERIT_SMW, 2)==0, MERIT_SMW=MERIT_SMW+1; end
% N_DROP = 3;
% wng = (smw-1)/2;
% 
% N = size(patch,3);
% 
% % Merit is correlation between bands 3 inside art_ntrp
% % fart_smooth = conv(fart,ones(1,smw)/smw,'same');
% % fart_smooth(1:wng) = fart(1:wng); fart_smooth(n-wng+1:n) = fart(n-wng+1:n);
% h = ones(1,1,smw)/smw;
% art_smooth = art;
% art_smooth(:,:,(wng+1):(N-wng)) = convn(art,h,'valid');
% dart = art - art_smooth;
% % fpatch_smooth = conv(fpatch,ones(1,smw)/smw,'same');
% % fpatch_smooth(1:wng) = fpatch(1:wng); fpatch_smooth(n-wng+1:n) = fpatch(n-wng+1:n);
% patch_smooth = patch;
% patch_smooth(:,:,(wng+1):(N-wng)) = convn(patch,h,'valid');
% dp = patch - patch_smooth;
% 
% 
% corr = dp(:,:,3:N-4) .* dart(:,:,3:N-4);
% corr = sort(corr,3);
% 
% % Skip extreme pts on each end to avoid spurious points. 
% % Limit number points dropped so at least 5 remain...
% nc = size(corr,3);
% ndrp = max(min(N_DROP,floor((nc-5)/2)),0);
% 
% merit = sum(corr(:,:,(1+ndrp):(nc-ndrp)),3);
% end