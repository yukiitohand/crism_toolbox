function [img_corr_patched,out] = crism_vscor_patch_vs_artifact_v3(waimg,img_corr,vsart)
% [img_corr_patched,out] = crism_vscor_patch_vs_artifact_v3(waimg,img_corr,vsart)
%  Perform artifact correction of the volcano scan correction for CRISM 
%  image. This is translated from idl code:
%      CAT_ENVI/save_add/CAT_programs/Supplementals/patch_vs_artifact.pro
% Tile mode is not supported.
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
% (c) 2021 Yuki Itoh


% merit function parameters:
MERIT_SMW = 3; % Size of the SMooth Window
if rem(MERIT_SMW, 2)==0, MERIT_SMW=MERIT_SMW+1; end

% MAXITER = 10;
% zero_deriv_count = 0;
% max_iter_count = 0;

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

%%
% filter is defined before the iteration to avoid repetition.

% status = zeros(L,S);

wng = (MERIT_SMW-1)/2;

interp_bands(isnan(interp_bands)) = -1;
interp_bands = int32(interp_bands);

[img_corr_patched,scale_factor,outeval,status] = ...
    crism_vscor_patch_vs_artifact_v2_internal_mex(img_corr,interp_bands,vsart,avg_cont,wng);

% h   = ones(MERIT_SMW,1)/MERIT_SMW;
% 
% img_corr_patched = img_corr;
% outscl  = zeros(L,S);
% outeval = nan(L,S);
% Svalid  = all(~isnan(interp_bands),1);
% status(:,~Svalid) = -1; % mark non-processed pixels
% Svalid = find(Svalid);
% Bx = interp_bands(2,:) - interp_bands(1,:)+1;
% for c=Svalid
%     ib1 = interp_bands(1,c); ib2 = interp_bands(2,c);
%     img_corr_cx = reshape(img_corr(:,c,ib1:ib2), [L,Bx(c)])';
%     artx        = reshape(vsart(1,c,ib1:ib2), [Bx(c) 1]);
%     
%     % it is likely that valid bands can be evaluated beforehand instead of
%     % doing it in the computation of the merit. Bands valid in the image 
%     % data and artifacts are also valid for patch. 
%     bdxes_valid_cx = and(~isnan(artx),~isnan(img_corr_cx));
%     ncx = sum(bdxes_valid_cx,1);
%     % pre-evaluate the valid lines
%     lines_valid = and(sum(bdxes_valid_cx,1)>8,~isnan(avg_cont(:,c)'));
%     status(~lines_valid,c) = -1; % mark non-processed pixels
%     lines_valid = find(lines_valid);
%     for l=lines_valid
%         bdxes_valid_csx = bdxes_valid_cx(:,l);
%         csx    = img_corr_cx(bdxes_valid_csx,l);
%         artcsx = artx(bdxes_valid_csx);
%         avg_cont_c = avg_cont(l,c);
%         
%         % precompute dart instead of doing so in the merit function
%         artcsx_smooth = artcsx;
%         artcsx_smooth((wng+1):(ncx(l)-wng)) = conv(artcsx,h,'valid');
%         dart = artcsx - artcsx_smooth;
%         
%         merit = 1.0e23;
%         dscl = 1.0e23;
%         scl_fac = 1.0;
%         niter = 0;
%         while (abs(merit) > 1.0e-6) && (abs(dscl) > 1.0e-4)
%             % Use a newtons method-like approach. Evaluate derivative:
%             patchx = csx + avg_cont_c * scl_fac * artcsx;
%             % Evaluate derivative
%             merit = evaluate_catvs_patch_2(patchx, dart, h, wng);
%             delta = max((abs(scl_fac)*1.0e-3), 0.0003);
%             scl_fac2 = scl_fac + delta;
%             patch2 = csx + (avg_cont_c*scl_fac2)*artcsx;
%             merit2 = evaluate_catvs_patch_2(patch2, dart, h, wng);
%             dmds = (merit2-merit) / delta; % dm/ds: = (merit(scl+dscl)-merit(scl)) / dscl;
% 
%             % Problem checks...
%             if isinf(merit) || isinf(merit2)
%                 status(l,c) = -2; scl_fac = 0.0;
%                 break;
%             end
%             if abs(dmds) < 1e-23
%                 % zero_deriv_count = zero_deriv_count+1;
%                 status(l,c) = -3; scl_fac = 0.0;
%                 break;
%             end
% 
%             dscl = -merit/dmds;
%             scl_fac = scl_fac+dscl;
% 
%             % patchx = csx + avg_cont_c * scl_fac * artcsx;
%             % merit = evaluate_catvs_patch_2(patchx, dart, h, wng);
% 
%             niter = niter + 1;
%             if niter > MAXITER
%                 status(l,c) = -4; scl_fac = 0.0;
%                 break;
%             end
% 
%         end
%         outscl(l,c)  = scl_fac;
%         outeval(l,c) = merit;
% 
%     end
% 
%     % patched spectrum:
%     img_corr_patched_c = img_corr_cx' + avg_cont(:,c) .* outscl(:,c) .* artx';
%     img_corr_patched(:,c,ib1:ib2) = reshape(img_corr_patched_c,[L,1,Bx(c)]);
%     % img_corr_patched(:,c,ib1:ib2) =  ...
%     %    img_corr_patched(:,c,ib1:ib2) + avg_cont(:,c) .* outscl(:,c) .* vsart(1,c,ib1:ib2);
% end

out = [];
out.scl   = scale_factor;
out.merit = outeval;
out.status = status;


end

function [merit] = evaluate_catvs_patch_2(patch,dart,h,wng)
% if rem(MERIT_SMW, 2)==0, MERIT_SMW=MERIT_SMW+1; end
N_DROP = 3;
n = length(patch);
% Merit is correlation between bands 3 inside art_ntrp
patch_smooth = patch;
patch_smooth((wng+1):(n-wng)) = conv(patch,h,'valid');
% patch_smooth((wng+1):(n-wng)) = movmean(patch,3,'endpoints','discard');
dp = patch - patch_smooth;
corr = dp(4:n-3) .* dart(4:n-3);
corr = sort(corr);

% Skip extreme pts on each end to avoid spurious points. 
% Limit number points dropped so at least 5 remain...
nc = length(corr);
ndrp = max(min(N_DROP,floor((nc-5)/2)),0);

merit = sum(corr((1+ndrp):(nc-ndrp)));

% merit = sum(corr) - sum(maxk(corr,ndrp)) - sum(mink(corr,ndrp));

end

