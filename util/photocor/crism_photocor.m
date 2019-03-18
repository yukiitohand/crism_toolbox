function [img_cor] = crism_photocor(img,incang)
% apply photometric correction 1/cos(incang)
%  Input parameters
%    img: image, [L x S x B]
%    incang: image of incident angles, degree [L x S]
%  Output parameters
%    img_cor: corrected image [L x S x B]

icosincang = 1./cosd(incang);

if verLessThan('matlab','8.1')
    img_cor = nan(size(img));
        for b = 1:size(img,3)
            img_cor(:,:,b) = img(:,:,b) .* icosincang;
        end
else
    img_cor = img .* icosincang;
end