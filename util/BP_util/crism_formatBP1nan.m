function [BP1nan] = crism_formatBP1nan(BPdata,varargin)
% [BP1nan] = crism_formatBP1nan(BPdata,varargin)
%   BPdata
%  INPUTS
%   BPdata: CRISMdata obj, BPdata
%  OUTPUT
%   BP1nan: [L x S x B] array where, BPs are filled with 1s and non-BPs
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

if isempty(BPdata.img)
    if band_inverse
        imgpost = BPdata.readimgi();
    else
        imgpost = BPdata.readimg();
    end
else
    if BPdata.is_img_band_inverse ~= band_inverse
        imgpost = BPdata.img_flip_band();
    else
        imgpost = BPdata.img;
    end
end

BP1nan = replace0withNaN(imgpost);


interleave_original = 'lsb'; % original BPdata.img output
prmt_ordr = [find(interleave(1)==interleave_original),...
             find(interleave(2)==interleave_original),...
             find(interleave(3)==interleave_original)];
BP1nan    = permute(BP1nan, prmt_ordr);

end