function [img_aligned] = crism_alignImagewithCM(img_ref,CMimg_ref,CMimg_tar,DMmask_ref,DMmask_tar)
% Perform aligning image with CM (camara model)
% Input parameters
%   img_ref: image to be projected [L,S,B]
%   CMimg_ref: image of CDR CMdata [1,S,B]
%   CMimg_tar: image of CDR CMdata in the targeted space [1,S',B']
%   DMmask_ref: image of CDR DM data for the reference image [1,S,B],
%               boolean, 1 for scene and 0 for the others
%   DMmask_tar: iamge of CDR DM data for the target image [1,S',B']
%               boolean, 1 for scene and 0 for the others
% Output Parameters
%   img_alignged: image aligned to target CM data space [L,S',B']
%                 Masked pixels are filled with NaNs

[L,S,B] = size(img_ref);
img_aligned = nan(L,S,B);

meanB_tar = floor(size(DMmask_tar,3)/2);
dmmaskl = squeeze(DMmask_tar(1,:,meanB_tar));
xq = squeeze(CMimg_tar(1,dmmaskl,1));

for b=1:B
    dmmasks = squeeze(DMmask_ref(1,:,b));
    x = squeeze(CMimg_ref(1,dmmasks,b));
    for l=1:L
        y = squeeze(img_ref(l,dmmasks,b));
        prf_intrp = interp1(x,y,xq,'linear','extrap');
        img_aligned(l,dmmaskl,b) = prf_intrp;
    end
end

end