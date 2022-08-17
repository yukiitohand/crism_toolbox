function [spc,wv,band_idxes] = get_spectrum_CRISMdataEquirectProjRot0_wGLT(...
    crismdata_wglt_obj,s,l,varargin)
% [spc,wv,band_idxes] = get_spectrum_CRISMdataEquirectProjRot0_wGLT(...
%     crismdata_wglt_obj,s,l,varargin)
%  Get spectrum/spectra and corresponding wavelength from
%  CRISMdata class object.
% INPUTS:
%   crismdata_wglt_obj: CRISMdataEquiRectProjRot0_wGLT obj
%   s,l     : sample and line indexes for which data is extracted
% OUTPUTS:
%   spc     : output spectrum. A column vector if do_average==true,
%             spectrum direction will be in the depth direction if not.
%   wv      : wavelength, column vector. If not found, empty is returned.
%   band_indexes: band indexes corrsponding output spectrum
% OPTIONAL Parameters
%   "BANDS" : bands to be ouput. can be boolean or integer vector. In case
%       of boolean, it needs to be the length of rastermb.hdr.bands. If
%       empty, all the bands are read
%     (default) []
%   "BAND_INVERSE" : boolean, if the input band vector is in the
%       opposite direction, with respect to the image in the saved file.
%     (default) false
%   
%   "AVERAGE_WINDOW": [l_size,s_size]
%     (default) [1 1]
%   "DO_AVERAGE": whether or not to perform average or not.
%     (default) true
%   "AVERAGE_DOMAIN": {"PROJECTIVE","SOURCE"}
%     (default) "PROJECTIVE"
%   
%   "COEFF": multiplier vector to be multiplied to the output spc
%      can be the length of rastermb.hdr.bands, or the output spc
%      (specified by "BANDS"). Can be a scalar, too.
%      (default) 1
%   "COEFF_INVERSE":  boolean, if the input COEFF vector is in the
%      opposite direction, with respect to the image in the saved file.
%      (default) false
%   "LOGARITHMIC"  : boolean, if spc is in the logarithmic domain or not. If
%      so, negative values will be replaced with NaNs
%      (default) false
%  Following options are used in reading spectra from file directly. If
%  image is already loaded to rastermb, they are not used.
%   "PRECISION": char, string; data type of the output image.
%       'raw','double', 'single', 'uint8', 'int16', 'int32','int64'
%       'uint8','uint16','uint32','uint64'
%      if 'raw', the data is returned with the original data type of the
%      image.
%      (default) 'double'
%  "Replace_data_ignore_value": boolean, 
%      whether or not to replace data_ignore_value with NaNs or not.
%      (default) true (for single and double data types)
%                false (for integer types)
%  "RepVal_data_ignore_value": 
%      replaced values for the pixels with data_ignore_value.
%      (default) nan (for double and single precisions). Need to specify 
%                for integer precisions.
% 
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>  
% 
ave_window = [1 1];
do_average = true;
bands = [];
coeff = 1;
is_bands_inverse    = false;
is_coeff_inverse    = false;
is_logarithmic      = false;

precision  = 'double';
rep_div    = [];
repval_div = [];
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'BANDS'
                bands = varargin{i+1};
            case 'BANDS_INVERSE'
                is_bands_inverse = varargin{i+1};
            case 'AVERAGE_WINDOW'
                ave_window = varargin{i+1};
            case 'DO_AVERAGE'
                do_average = varargin{i+1};
            case 'COEFF'
                coeff = varargin{i+1};
            case 'COEFF_INVERSE'
                is_coeff_inverse = varargin{i+1};
            case 'LOGARITMIC'
                is_logarithmic = varargin{i+1};
            case 'PRECISION'
                precision = varargin{i+1};
            case 'REPLACE_DATA_IGNORE_VALUE'
                rep_div = varargin{i+1};
            case 'REPVAL_DATA_IGNORE_VALUE'
                repval_div = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

if isempty(bands)
    bands_bool = true(crismdata_wglt_obj.hdr.bands,1);
elseif ~islogical(bands)
    bands_bool = false(crismdata_wglt_obj.hdr.bands,1);
    bands_bool(bands) = true;
    if is_bands_inverse, bands_bool = flip(bands_bool); end
end

l_bands = sum(bands_bool);
l_coeff = length(coeff);
coeff = coeff(:);
if is_coeff_inverse, coeff = flip(coeff); end

if ~isempty(crismdata_wglt_obj.RasterSource.wa)
    wv_mode = 'wa';
elseif isfield(crismdata_wglt_obj.hdr,'wavelength') && ...
        ~isempty(crismdata_wglt_obj.hdr.wavelength)
    wv = crismdata_wglt_obj.hdr.wavelength(:);
    wv_mode = 'hdr';
else
    % wv = reshape(1:rastermb.hdr.bands,[],1); 
    % band index is returned when no information for wavelength
    % now no wavelength is returned if no information is available.
    wv = [];
    wv_mode = 'none';
end


%% Load spectrum
wdw_strt = max(-floor((ave_window-1)/2)+[l,s],[1 1]);
wdw_end = min(floor(ave_window/2)+[l,s],...
    [crismdata_wglt_obj.hdr.lines,crismdata_wglt_obj.hdr.samples]);

line_idxes = wdw_strt(1):wdw_end(1);
smpl_idxes = wdw_strt(2):wdw_end(2);
samplesc = length(smpl_idxes); linesc = length(line_idxes);
spc = nan(linesc,samplesc,crismdata_wglt_obj.hdr.bands);
switch lower(wv_mode)
    case 'wa'
        wv  = nan(linesc,samplesc,crismdata_wglt_obj.hdr.bands);
end

if isempty(crismdata_wglt_obj.RasterSource.img)
    for yi=1:linesc
        for xi=1:samplesc
            x=smpl_idxes(xi); y=line_idxes(yi);
            [spci,xf,yf] = crismdata_wglt_obj.lazyEnviRead(x,y, ...
                'precision',precision,...
                'REPLACE_DATA_IGNORE_VALUE',rep_div,...
                'REPVAL_DATA_IGNORE_VALUE',repval_div);
            if ~isempty(spci)
                spc(yi,xi,:) = spci;
                switch lower(wv_mode)
                    case 'wa'
                        wv(yi,xi,:)  = crismdata_wglt_obj.RasterSource.wa(:,xf);
                end
            end
        end
    end
else
    for yi=1:linesc
        for xi=1:samplesc
            x=smpl_idxes(xi); y=line_idxes(yi);
            xf = crismdata_wglt_obj.GLTdata.img(y,x,1);
            yf = crismdata_wglt_obj.GLTdata.img(y,x,2);
            spc(yi,xi,:) = crismdata_wglt_obj.RasterSource.img(yf,xf,:);
            switch lower(wv_mode)
                case 'wa'
                    wv(yi,xi,:)  = crismdata_wglt_obj.RasterSource.wa(:,xf);
            end
        end
    end
    if crismdata_wglt_obj.RasterSource.is_img_band_inverse
        spc = flip(spc,3);
    end
end

switch lower(wv_mode)
    case 'wa'
        if crismdata_wglt_obj.RasterSource.is_wa_band_inverse
            wv  = flip(wv,3);
        end
end

if is_logarithmic
    spc(spc<0) = nan;
end

if do_average
    if verLessThan('matlab','9.6')
        % code to run MATLAB R2018b and earlier here
        spc = nanmean(nanmean(spc,1),2);
        switch lower(wv_mode)
            case 'wa'
                wv  = nanmean(nanmean(wv,1),2);
        end
    else
        spc = mean(spc,[1,2],'omitnan');
        switch lower(wv_mode)
            case 'wa'
                wv  = mean(wv,[1,2],'omitnan');
        end
    end
end

%% Post processing ...

% Applying coefficient to the output spectrum
if l_coeff==l_bands
    % perform bands option if given
    spc = spc(:,:,bands_bool);
    spc = spc .* permute(coeff,[3,2,1]);
elseif l_coeff==crismdata_wglt_obj.hdr.bands
    spc = spc .* permute(coeff,[3,2,1]);
    % perform bands option if given
    spc = spc(:,:,bands_bool);
elseif l_coeff==1
    spc = spc(:,:,bands_bool) .* coeff;
else
    error('length of coeff %d is wrong.',l_coeff);
end

band_idxes = find(bands_bool);

spc = squeeze(spc);
wv = squeeze(wv);

if ~isempty(wv)
    if isvector(wv)
        wv = wv(bands_bool); 
    elseif ismatrix(wv)
        wv = wv(bands_bool,:);
    elseif ndims(wv)==3
        wv = wv(:,:,bands_bool);
    end
end


end