function [x_glt,y_glt] = create_glt_equirectangular_wRegionMask(inlatMap,...
    inlonMap,outlatNS,outlonEW,outlatd0,inImage,varargin)
% [x_glt,y_glt] = create_glt_equirectangular_wRegionMask(inlatMap,...
%   inlonMap,outlatNS,outlonEW,outlatd0,inImage,varargin)
%  Version 2 is for fixing edge issues by using Image region mask.
% INPUTS
%   inlatMap: [Lin x Sin] latitude for each pixel of the input image
%   inlonMap: [Lin x Sin] longitude for each pixel of the input image
%   outlatNS: Lout length vector
%   outlonEX: Sout length vector
%   outlatd0: base latitude parameter for the equirectangular projection of
%             the output image, unit is degree
%   inImage : [Lout x Sout] boolean matrix. true means that the pixel is
%             inside the image and false means otherwise.
% OUTPUTS
%   x_glt : [Lout x Sout] nearest x coordinate of the input image pixel.
%   y_glt : [Lout x Sout] nearest y coordinate of the input image pixel.


valid_lines = true(size(inlatMap,1),1);
valid_samples = true(1,size(inlatMap,2));
dst_lmt_param = 3;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'VALID_LINES'
                valid_lines = varargin{i+1};
            case 'VALID_SAMPLES'
                valid_samples = varargin{i+1};
            case 'DST_LMT_PARAM'
                dst_lmt_param = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

inMap_valid = false(size(inlatMap));
inMap_valid(valid_lines,valid_samples) = true;
inMap_invalid_idx = reshape(find(~inMap_valid),[],1);
% inMap_invalid_1d = ~inMap_valid(:);

coslatd0_out = cosd(outlatd0);

% latitude and longitude steps
outlatstp = outlatNS(1) - outlatNS(2);
outlonstp = outlonEW(2) - outlonEW(1);

dstsqrt2_lmt = sqrt(outlatstp^2 + (coslatd0_out*outlonstp)^2)*dst_lmt_param;

Lout = length(outlatNS);
Sout = length(outlonEW);
[Lin,Sin] = size(inlatMap);

%%
% reshape the input vectors. Two input latitude and longitude maps are
% vectorized into column vectors. Two output latitude longitude vectors are
% converted into row vectors.
inlat_vec = inlatMap(:) ;  inlon_vec = inlonMap(:) ;
outlatNS  = outlatNS(:)';  outlonEW  = outlonEW(:)';

% trim output
% samples and lines that have at least one pixels inside the image
lout_vld     = find(any(inImage',1));  sout_vld     = find(any(inImage,1)); 
outlatNS_trm = outlatNS(lout_vld)   ;  outlonEW_trm = outlonEW(sout_vld)  ;
Lout_trm     = length(outlatNS_trm) ;  Sout_trm     = length(outlonEW_trm);

%% Main computation

% ydst2_scale = (outlatNS_trm-inlat_vec).^2;
% ydst2_valid = sqrt(ydst2_scale)<dstsqrt2_lmt;
% ydst2_scale(~ydst2_valid) = 65535;
% ydst2_scale(inMap_invalid_1d,:) = 65535; % mask invalid pixels

% actual distance in the longitude direction should be 
xdst2_scale = (inlon_vec-outlonEW_trm).^2;
% xdst2_scale(inMap_invalid_1d,:) = 65535; % mask invalid pixels
xdst2_valid = sqrt(xdst2_scale)<dstsqrt2_lmt;
xdst2_scale(~xdst2_valid) = 65535;

% pre-screening of the pixels that can be excluded solely by vertical
% distance.
% tic; 
% yidx_list = cell(Lout_trm,1);
% for j=1:Lout_trm
%     yidx_list{j} = find(ydst2_valid(:,j));
% end

ii_glt_trm = nan(Lout_trm,Sout_trm);
vv_glt_trm = 65535*ones(Lout_trm,Sout_trm);

inImage_trm = inImage(lout_vld,sout_vld); 
for l=1:Lout_trm
    % Take advantage of the well-conditioned shape of equirectangular 
    % projection. Take the distance in the vertical and horizontal 
    % directions independently to reduce the computation burden.
    ydst2_scale = (inlat_vec-outlatNS_trm(l)).^2;
    yidx = find(sqrt(ydst2_scale) < dstsqrt2_lmt);
    if ~isempty(yidx)
        % coefficient for the longitude based distance
        cosdl = cosd(outlatNS_trm(l));
        ydst2_scalel = ydst2_scale(yidx);
        for s=1:Sout_trm
            if inImage_trm(l,s)
                di = cosdl.*xdst2_scale(yidx,s) + ydst2_scalel;
                [di_min,ii_min] = min(di);
                vv_glt_trm(l,s) = di_min;
                ii_glt_trm(l,s) = yidx(ii_min);
            end
        end
    end
end

if any(and(inImage_trm,isnan(ii_glt_trm)),[1,2])
    warning(...
        ['There exist a pixel that is not filled with the current ' ...
         'configuration.']...
    );
end

% If the closest pixel matches with an invalid pixel of the input image,
% then it is replaced with a NaN.
for l=1:Lout_trm
    invalid_l = any(ii_glt_trm(l,:)==inMap_invalid_idx,1);
    ii_glt_trm(l,invalid_l) = nan;
    vv_glt_trm(l,invalid_l) = nan;
end

%% Post processing
vv_invalid_trim = (vv_glt_trm>=65535);
ii_glt_trm(vv_invalid_trim) = nan;

y_glt_trm = mod(ii_glt_trm,Lin);
y_glt_trm(y_glt_trm==0) = Lin;

x_glt_trm = ceil(ii_glt_trm/Lin);

x_glt = nan(Lout,Sout); y_glt = nan(Lout,Sout);
x_glt(lout_vld,sout_vld) = x_glt_trm; y_glt(lout_vld,sout_vld) = y_glt_trm;


end