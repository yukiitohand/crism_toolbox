function [ img ] = missing_replace( img,lbl,hdr )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if ~isempty(lbl)
    img(img==lbl.OBJECT_FILE{1}.OBJECT_IMAGE.MISSING_CONSTANT) = nan;
elseif ~isempty(hdr)
    img(img==hdr.data_ignore_value) = nan;
end

end

