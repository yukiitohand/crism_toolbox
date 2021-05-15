function [img_ds] = crism_smile_correction(img,wa,wv,bands,varargin)
% [img_corr] = crism_smile_correction(img,wa,wv,varargin)
% Smile correction of CRISM image
%  INPUTS
%   img  : image before correction [L x S x B]
%   wa   : wavelength frame [1 x S x B]
%   wv   : wavelength samples for which interpolation is performed [Bx1]
%   bands: list of bands for which de-smiling is performed.
%  OUTPUTS
%   img_ds: image file [L x S x B]
%  OPTIONAL PARAMETERS
%   'EXTRAP': boolean
%       Whether or not to extrapolate spectra if you encounterd such
%       situation. Extrapolation is not applied to channels outside of
%       "bands". Recommend to turn on since, edges of WQ are slightly
%       outside for some columns due to smile effect.
%       (default) true


do_extrap = true;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'EXTRAP'
                do_extrap = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

if do_extrap
    interp_extrap_opt = {'extrap'};
else
    interp_extrap_opt = {};
end

[L,S,B] = size(img);
Bw = length(wv);

if Bw~=B
    error('wv needs to the same number of bands as wa.');
end



%%

wv_tar = wv(bands); Btar = length(wv_tar);
if isnan(wv_tar)
    error('wv has nan over the specified bands.');
end

% only applied to bands
img_b = img(:,:,bands);
wa_b_sq = squeeze(wa(:,:,bands))';
img_b_ds = nan([L,S,Btar]);

for c=1:S
    img_b_ds_c = permute(img_b(:,c,:),[3,1,2]);
    wac = wa_b_sq(:,c);
    if ~all(isnan(img_b_ds_c),'all')
        img_b_ds_c = interp1(wac,img_b_ds_c,wv_tar,'linear',interp_extrap_opt{:});
        img_b_ds(:,c,:) = permute(img_b_ds_c,[2,3,1]);
    end
end

img_ds = img;
img_ds(:,:,bands) = img_b_ds;

end
