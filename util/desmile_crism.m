function [] = desmile_crism(hsi_sabcond,bands,varargin)
% desmile_crism(hsi_sabcond,bands,varargin)
%  Perform desmiling using simple linear interpolation
% INPUTS
%  hsi_sabcond: CRISMdataCAT object
%  bands      : list of bands for which de-smiling is performed.
% OUTPUTS
%  No outputs
% OPTIONAL PARAMETERS
%   'SAVE_PDIR': any string
%       root directory path where the processed data are stored. The
%       processed image will be saved at <SAVE_PDIR>/CCCNNNNNNNN, where CCC
%       the class type of the obervation and NNNNNNNN is the observation id.
%       It doesn't matter if trailing slash is there or not.
%       If empty, same directory as the input data is selected.
%       (default) ''
%   'SAVE_DIR_YYYY_DOY': boolean (Future implementation)
%       Only valid with non-empty 'SAVE_PDIR'
%       if true, processed images are saved at 
%           <SAVE_PDIR>/YYYY_DOY/CCCNNNNNNNN,
%       otherwise, 
%           <SAVE_PDIR>/CCCNNNNNNNN.
%       (default) false
%   'BANDS_CROP': boolean
%       Whether or not to crop the interpolated image. This could reduce
%       the output image file size
%       (default) false
%   'WQ': 
%       Wavelength samples to which the image is interpolated.
%       If it is empty, wavelenght information in the input image header is
%       used.
%       (default) []
%   'EXTRAP': boolean
%       Whether or not to extrapolate spectra if you encounterd such
%       situation. Extrapolation is not applied to channels outside of
%       "bands". Recommend to turn on since, edges of WQ are slightly
%       outside for some columns due to smile effect.
%       (default) true
%       
% 
save_pdir = [];
save_dir_yyyy_doy = 0;
suffix = 'ds';
bands_crop = false;
wv_tar = [];
do_extrap = true;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'SAVE_PDIR'
                save_pdir = varargin{i+1};
            case 'SAVE_DIR_YYYY_DOY'
                error('Future implementation');
            case 'SUFFIX'
                suffix = varargin{i+1};
            case 'BANDS_CROP'
                bands_crop = varargin{i+1};    
            case 'WQ'
                wv_tar = varargin{i+1};
            case 'EXTRAP'
                do_extrap = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

if isempty(save_pdir)
    save_dir = hsi_sabcond.dirpath;
else
    if save_dir_yyyy_doy
        error('not implemented yet');
    else
        save_dir = joinPath(save_pdir,hsi_sabcond.dirname);
    end
    if ~exist(save_dir,'dir')
        mkdir(save_dir);
    end
end

if do_extrap
    interp_extrap_opt = {'extrap'};
else
    interp_extrap_opt = {};
end

if isempty(wv_tar)
    wv_tar = hsi_sabcond.hdr.wavelength(bands);
end

if isempty(hsi_sabcond.wa)
    error('Wavelength frame is not set yet.');
else
    wab = hsi_sabcond.wa(bands,:)/1000;
end

%% Performing interpolation.
img = hsi_sabcond.readimg();
img_ds = nan(hsi_sabcond.hdr.lines,hsi_sabcond.hdr.samples,length(wv_tar));
for c=1:hsi_sabcond.hdr.samples
    img_ds_c = permute(img(:,c,bands),[3,1,2]);
    if ~all(isnan(img_ds_c),'all')
        img_ds_c = interp1(wab(:,c),img_ds_c,wv_tar,'linear',interp_extrap_opt{:});
        img_ds(:,c,:) = permute(img_ds_c,[2,3,1]);
    end
end

if ~bands_crop
    img(:,:,bands) = img_ds;
    img_ds = img;
end

%% Save the data
hdr_ds = hsi_sabcond.hdr;
if bands_crop
    hdr_ds.wavelength = wv_tar;
    hdr_ds.bands      = length(wv_tar);
    if isfield(hdr_ds,'fwhm')
        hdr_ds = rmfield(hdr_ds,'fwhm');
    end
    if isfield(hdr_ds,'bbl')
        hdr_ds = rmfield(hdr_ds,'bbl');
    end
end
basename_ds = [hsi_sabcond.basename '_' suffix];

if isfield(hdr_ds,'cat_history')
    hdr_ds.cat_history = [hdr_ds.cat_history '_' suffix];
end

fprintf('Saving %s ...\n',joinPath(save_dir, [basename_ds '.hdr']));
envihdrwritex(hdr_ds,joinPath(save_dir,[basename_ds '.hdr']),'OPT_CMOUT',false);
fprintf('Done\n');
fprintf('Saving %s ...\n',joinPath(save_dir, [basename_ds '.img']));
envidatawrite(single(img_ds),joinPath(save_dir, [basename_ds '.img']),hdr_ds);
fprintf('Done\n');

end