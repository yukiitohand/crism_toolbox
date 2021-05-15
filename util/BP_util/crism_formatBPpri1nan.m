function [BP_pri1nan] = crism_formatBPpri1nan(BPdata1,BPdata2,varargin)
% [BP_pri1nan] = crism_formatBPpri1nan(BPdata1,BPdata2,varargin)
%   combine BP detection arrays of two BPdata
%  INPUTS
%   BPdata1: CRISMdata obj, BPdata
%   BPdata2: CRISMdata obj, BPdata
%  OUTPUT
%   BP_pri1nan: [L x S x B] array where, BPs are filled with 1s and non-BPs
%    are filled with NaNs.
%  OPTIONAL Parameters
%   'BAND_INVERSE': boolean
%      whether or not to flip the band direction from the original.
%      (default) true
%   'INTERLEAVE': string, {'lsb','lbs','slb','sbl','bls','bsl'}
%      represents 1st, 2nd, 3rd dimensions of BP_pri1nan corresponds to
%      line(l), sample(s), or band(b)
%      (default) 'bsl'

% input assessment
band_inverse_default = true;
interleave_default   = 'bsl';
interleave_valid_types = {'lsb','lbs','slb','sbl','bls','bsl'};
p = inputParser;
addParameter(p,'Band_Inverse',band_inverse_default, ...
    @(x) validateattributes(x,{'numeric','logical'},{'binary'},mfilename,'Band_Inverse'));
addParameter(p,'Interleave',interleave_default,@(x) any(validatestring(x,interleave_valid_types)));
parse(p,varargin{:});
band_inverse = p.Results.Band_Inverse;
interleave   = p.Results.Interleave;


[BP11nan] = crism_formatBP1nan(BPdata1,'Band_Inverse',band_inverse,'Interleave',interleave);
if ~isempty(BPdata2)
    [BP21nan] = crism_formatBP1nan(BPdata2,'Band_Inverse',band_inverse,'Interleave',interleave);
    % stack BP11nan and BP21nan along the dimension associated with 'l'
    dim_stack = find(interleave=='l');
    BP_pri1nan = mean(cat(dim_stack,BP11nan,BP21nan),dim_stack,'omitnan');
else
    BP_pri1nan = BP11nan;
end

end