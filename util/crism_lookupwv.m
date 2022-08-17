function [bdxes] = crism_lookupwv(wvq,waimg)
% [bdxes] = crism_lookupwv(wvq,waimg)
% Return the bands closest to the queried wavelength(s) for each spatial
% column of the given wavelenth frame image (waimg).
% Similar to idl function in CAT
%   CAT_ENVI/save_add/CAT_programs/Additions/mro_crism_lookupwv.pro
% INPUTS
%   wvq: [1 x N], [N x 1] queried wavelengths, can be a vector, but but not
%        a matrix or  multi-dimensional array.
%   waimg: wavelength frame image in the original shape [1 x S x B]
% OUTPUTS
%   bdxes: [N x S] band indexes for the queried samples for each column.

if ~isvector(wvq)
    error('query wavelength can be a vector, but not a matrix or multi-dimensional array.');
end

N = length(wvq);
[v_min,bdxes] = min(abs(waimg-reshape(wvq,[N 1])),[],3,'omitnan');
bdxes_valid = convertBoolTo1nan(~isnan(v_min));
bdxes = bdxes .* bdxes_valid;

end