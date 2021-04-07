function [pmc_pxlvrtcsCell_new] = crism_rotate_pmcFOVcell(pmc_pxlvrtcsCell,R)
% [pmc_pxlvrtcsCell_new] = crism_rotate_pmcFOVcell(pmc_pxlvrtcsCell,R)
%  Rotate pmc vectors stored in the cell format 
% INPUTS
%   pmc_pxlvrtcsCell: cell array
%   R: rotational matrix
% OUTPUTS
%   pmc_pxlvrtcsCell_new: cell array
% 
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>

pmc_pxlvrtcsCell_new = cell(size(pmc_pxlvrtcsCell));
N = length(pmc_pxlvrtcsCell);

for i=1:N
    pmc_pxlvrtcsCell_new{i} = R * pmc_pxlvrtcsCell{i};
end

end