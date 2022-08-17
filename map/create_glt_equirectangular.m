function [x_glt,y_glt] = create_glt_equirectangular(inlatMap,inlonMap,outlatNS,outlonEW,outlatd0,varargin)
% [x_glt,y_glt] = create_glt_equirectangular(inlatMap,inlonMap,outlatNS,outlonEW,outlatd0,varargin)
% INPUTS
%   inlatMap: [Lin x Sin] latitude for each pixel of the input image
%   inlonMap: [Lin x Sin] longitude for each pixel of the input image
%   outlatNS: Lout length vector
%   outlonEX: Sout length vector
%   outlatd0: base latitude parameter for the equirectangular projection of
%             the output image, unit is degree
% OUTPUTS
%   x_glt : [Lout x Sout] nearest x coordinate of the input image pixel.
%   y_glt : [Lout x Sout] nearest y coordinate of the input image pixel.


valid_lines = true(size(inlatMap,1),1);
valid_samples = true(1,size(inlatMap,2));
dst_lmt_param = 2;

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
inMap_invalid_1d = ~inMap_valid(:);

coslatd0_out = cosd(outlatd0);

outlatstp = outlatNS(1) - outlatNS(2);
outlonstp = outlonEW(2) - outlonEW(1);

dstsqrt2_lmt = sqrt(outlatstp^2 + (coslatd0_out*outlonstp)^2)*dst_lmt_param;

leny_out = length(outlatNS);
lenx_out = length(outlonEW);
[leny_in,lenx_in] = size(inlatMap);

inlat_vec = inlatMap(:);
inlon_vec = inlonMap(:);

outlatNS = outlatNS(:)';
outlonEW = outlonEW(:)';

% trim output
inlat_vec_max = max(inlat_vec) + outlatstp*2;
inlat_vec_min = min(inlat_vec) - outlatstp*2;
outlat_actv = and(outlatNS >= inlat_vec_min, outlatNS <= inlat_vec_max);

inlon_vec_max = max(inlon_vec) + outlonstp*2;
inlon_vec_min = min(inlon_vec) - outlonstp*2;
outlon_actv = and(outlonEW >= inlon_vec_min, outlonEW <= inlon_vec_max);

outlatNS_trm = outlatNS(outlat_actv);
outlonEW_trm = outlonEW(outlon_actv);

leny_out_trm = length(outlatNS_trm);
lenx_out_trm = length(outlonEW_trm);

ydst2_scale = (outlatNS_trm-inlat_vec).^2;

% mask invalid pixels
ydst2_scale(inMap_invalid_1d,:) = 65535;

ydst2_valid = sqrt(ydst2_scale)<dstsqrt2_lmt;
ydst2_scale(~ydst2_valid) = 65535;

% ydst2_scale_sp = sparse(leny_out,leny_in);
% ydst2_scale_sp(ydst2_valid) = ydst2_scale(ydst2_valid);
% xdst2_scale(xdst2_scale>dst2_lmt) = nan;
xdst2_scale = (coslatd0_out * (outlonEW_trm-inlon_vec)).^2;

% mask invalid pixels
xdst2_scale(inMap_invalid_1d,:) = 65535;

xdst2_valid = sqrt(xdst2_scale)<dstsqrt2_lmt;
xdst2_scale(~xdst2_valid) = 65535;

ii_glt_trm = nan(leny_out_trm,lenx_out_trm);
vv_glt_trm = 65535*ones(leny_out_trm,lenx_out_trm);

yidx_list = cell(leny_out_trm,2);
for j=1:leny_out_trm
    yidx_list{j} = find(ydst2_valid(:,j));
end
% 
% xidx_list = cell(leny_out_trm,2);
% for j=1:lenx_out_trm
%     xidx_list{j} = find(xdst2_valid(:,j));
% end

% for i=1:lenx_out_trm
%     tic;
%     for j=1:leny_out_trm
%         % yidx = yidx_list{j};
%         idx_valid = find(and(xdst2_valid(:,i),ydst2_valid(:,j)));
%         if ~isempty(idx_valid)
%             di = xdst2_scale(idx_valid,i) + ydst2_scale(idx_valid,j);
%             [di_min,ii_min] = min(di);
%             vv_glt_trm(j,i) = di_min;
%             ii_glt_trm(j,i) = idx_valid(ii_min);
%         end
%     end
%     toc;
% end

% for i=1:lenx_out_trm
%     % tic;
%     for j=1:leny_out_trm
%         yidx = yidx_list{j};
%         if ~isempty(yidx)
%             if any(xdst2_valid(yidx,i))
%                 di = xdst2_scale(yidx,i) + ydst2_scale(yidx,j);
%                 [di_min,ii_min] = min(di);
%                 vv_glt_trm(j,i) = di_min;
%                 ii_glt_trm(j,i) = yidx(ii_min);
%             end
%         end
%     end
%     % toc;
% end

% fastest below
for i=1:lenx_out_trm
    % tic;
    for j=1:leny_out_trm
        yidx = yidx_list{j};
        if ~isempty(yidx)
            di = xdst2_scale(yidx,i) + ydst2_scale(yidx,j);
            [di_min,ii_min] = min(di);
            vv_glt_trm(j,i) = di_min;
            ii_glt_trm(j,i) = yidx(ii_min);
        end
    end
    % toc;
end

% for i=1:lenx_out_trm
%     tic;
%     di = bsxfun(@plus,xdst2_scale(:,i),ydst2_scale);
%     [di_min,ii_min] = min(di);
%     vv_glt_trm(:,i) = di_min;
%     ii_glt_trm(:,i) = ii_min;
%     toc;
% end

vv_invalid_trim = (vv_glt_trm>=65535);
ii_glt_trm(vv_invalid_trim) = nan;

y_glt_trm = mod(ii_glt_trm,leny_in);
y_glt_trm(y_glt_trm==0) = leny_in;

x_glt_trm = ceil(ii_glt_trm/leny_in);

x_glt = nan(leny_out,lenx_out);
y_glt = nan(leny_out,lenx_out);

x_glt(outlat_actv,outlon_actv) = x_glt_trm;
y_glt(outlat_actv,outlon_actv) = y_glt_trm;


end