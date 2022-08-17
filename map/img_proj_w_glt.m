function [img_proj] = img_proj_w_glt(img,GLTdata)
% [img_proj] = img_proj_w_glt(img,GLTdata)
%   projected image using GLT
%  Inputs
%   img: image data [L x S x B]
%   GLTdata: CRISM GLT data (geometric lookup table)
%  Outputs
%   img_proj: projected image, number of bands is same, and image size is
%   the size of the GLT image

if isempty(GLTdata.img), GLTdata.readimg(); end

[L,S,B] = size(img);

X_GLT = abs(double(GLTdata.img(:,:,1)));
Y_GLT = abs(double(GLTdata.img(:,:,2)));

cumIdx = Y_GLT(:)+(X_GLT(:)-1)*L;

img_proj_2d = nan(B,length(cumIdx));

cumIdx_nonzero_idx = (cumIdx>0);
cumIdx_nonzero = cumIdx(cumIdx_nonzero_idx);

flat_img_2d = reshape(img,[S*L,B])';
img_proj_2d_nozero = flat_img_2d(:,cumIdx_nonzero);

img_proj_2d(:,cumIdx_nonzero_idx) = img_proj_2d_nozero;

img_proj = reshape(img_proj_2d',[GLTdata.hdr.lines,GLTdata.hdr.samples,B]);

end