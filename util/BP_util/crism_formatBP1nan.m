function [BP1nan] = crism_formatBP1nan(BPdata,varargin)

% input assessment
band_inverse_default = true;
p = inputParser;
addParameter(p,'Band_Inverse',band_inverse_default,@(x) validateattributes(x,{'numeric','logical'},{'binary'},mfilename,'Band_Inverse'));
parse(p,varargin{:});
band_inverse = p.Results.Band_Inverse;
% if (rem(length(varargin),2)==1)
%     error('Optional parameters should always go by pairs');
% else
%     for n=1:2:(length(varargin)-1)
%         switch upper(varargin{n}) 
%             case 'BAND_INVERSE'
%                 band_inverse = varargin{n+1};
%             otherwise
%                 % Hmmm, something wrong with the parameter string
%                 error(['Unrecognized option: ''' varargin{n} '''']);
%         end
%     end
% end

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
BP1nan = squeeze(BP1nan)';

end