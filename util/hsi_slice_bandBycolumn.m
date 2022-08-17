function [imbList] = hsi_slice_bandBycolumn(img,bList)
% [imbList] = hsi_slice_bandBycolumn(img,bList)
%   Create a single_layer image from a 3 dimensional hyperspectral image by
%   taking one band for each column.
% INPUTS
%   img: [L x S x B] input image
%   bList: [1 x S] band indices for each column
% OUTPUTS
%   imbList: [L x S] single layer images
%
[L,S,B] = size(img);
if isvector(bList) && length(bList)==S
    imbList = nan(L,S);
    notisnan_bList = find(~isnan(bList));
    for c=notisnan_bList
        imbList(:,c) = img(:,c,bList(c));
    end
else
    error('bList needs to be a vector of the length equal to the column of img');
end


end