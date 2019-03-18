function [BP_pri1nan] = formatBPpri1nan(BPdata1,BPdata2,varargin)
% [BP_pri1nan] = formatBPpri1nan(BPdata1,BPdata2,varargin)
%   combine BP detection arrays of two BPdata
%  INPUTS
%   BPdata

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

[BP11nan] = formatBP1nan(BPdata1,'Band_Inverse',band_inverse);
if ~isempty(BPdata2)
    [BP21nan] = formatBP1nan(BPdata2,'Band_Inverse',band_inverse);
    BP_pri1nan = nanmean(cat(3,BP11nan,BP21nan),3);
else
    BP_pri1nan = BP11nan;
end

end