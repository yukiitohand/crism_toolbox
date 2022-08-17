function [imbList] = hsi_slice_bandBycolumn_1frame(img,bList)
% [imbList] = hsi_slice_bandBycolumn_1frame(img,bList)
%   Create a single_layer image from a 3 dimensional hyperspectral image by
%   taking one band for each column.
% INPUTS
%   img: [L x S x B] input image
%   bList: [1 x S] band indices for each column
% OUTPUTS
%   imbList: [L x S] single layer images
%
[L,S,B] = size(img);
if L==1 && isvector(bList) && length(bList)==S
    imbList = nan(1,S);
    notisnan_bList = find(~isnan(bList));
    indices = sub2ind([1,S,B],ones(1,length(notisnan_bList)),notisnan_bList,bList(notisnan_bList));
    imbList(notisnan_bList) = img(indices);
    % for c=notisnan_bList
    %     imbList(:,c) = img(:,c,bList(c));
    % end
else
    error('bList needs to be a vector of the length equal to the column of img and line of the image should be equal to one.');
end


end