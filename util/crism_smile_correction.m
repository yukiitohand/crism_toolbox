function [img_corr] = smile_correction(img,wa,wv,varargin)
% [img_corr] = smile_correction(img,wa,wv,varargin)
% Smile correction using wavelength frame file
%  INPUTS
%   img: image before correction [LxSxB]
%   wa: wavelength frame [1 x S x B]
%   wv: wavelength samples for which interpolation is performed [Bx1]
%  OUTPUTS
%   img_corr: image file
%  OPTIONAL PARAMETERS
%      'METHOD' : {'interpGaussConv', 'interp1'}
%                 (default) 'interp1'
%                 interpCRISMspc is recommended for high spectral resolutio
%                 data, otherwise use 'interp1'
%      'RETAINRATIO': option for 'interpGaussConv'
%                     (default) 0.1
%      'FWHM'       : option for 'interpGaussConv'
%                     (default) []

method = 'interp1';
retainRatio = 0.1;
fwhm = [];
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'METHOD'
                method = varargin{i+1};
            case 'RETAINRATIO'
                retainRatio = varargin{i+1};
            case 'FWHM'
                fwhm = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

[L,S,B] = size(img);
Bw = length(wv);

img_corr = nan([L,S,Bw]);

isvalid_wv = ~isnan(wv);
switch lower(method)
    case 'interpgaussconv'
        isvalid_fwhm = ~isnan(fwhm);
        isvalid_wv = and(isvalid_wv,isvalid_fwhm);
end
Bw_valid = sum(isvalid_wv);

for s=1:S
    wv_in = squeeze(wa(1,s,:));
    isnan_wv_in = isnan(wv_in);
    if ~all(isnan_wv_in)
        isvalid_wv_in = ~isnan_wv_in;
        img_s = squeeze(img(:,s,isvalid_wv_in))';
        wv_in_valid = wv_in(isvalid_wv_in);
        switch lower(method)
            case 'interp1'
                img_corr_s_valid = interp1(wv_in_valid,img_s,wv(isvalid_wv),'linear');
            case 'interpgaussconv'
                if isempty(fwhm)
                    error('specify fwhm for method interpgaussconv');
                end
                img_corr_s_valid = interpGaussConv_v2(wv_in_valid,img_s,...
                    wv(isvalid_wv),fwhm(isvalid_wv),'RETAINRATIO',retainRatio);
            otherwise
                error('Undefined method %s.',method);  
        end
        img_corr(:,s,isvalid_wv) = reshape(img_corr_s_valid',[L,1,Bw_valid]);
    end
end

end
