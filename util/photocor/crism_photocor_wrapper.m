function [] = crism_photocor_wrapper(in_crismdata,DEdata,varargin)
% [] = crism_photocor_wrapper(in_crismdata,DEdata,varargin)
%   perform map projection using GLT image data.
%  Input
%   in_crismdata: input CRISM data, to be projected
%   DEdata: CRISM DE data
%  Output
%   save a projected image. 
%   Default directory is the directory of the input CRISM data. Default
%   basename is the basename of the input CRISM data suffixed with suffix
%  Optional Parameters
%   'OPT_INCANG' : which angle will be used for photometric correction
%                  (default) 'AREOID'
%                  {'AREOID', 'MOLA'}
%   'BANDS' : selected bands, boolean or array
%             (default) all the bands will be used
%   'BAND_INVERSE' : whether or not to invert bands or not
%                    (default) false
%   'DEFAULT_BANDS' : "default bands" property of the output image
%                     (default) selected using "get_default_bands.m"
%   'SUFFIX'  : suffix to the basename of the output image.
%               (default) '_phot1'
%   'SAVE_DIR' : saved directory
%                (default) same as the directory of input CRISM image
%   'FORCE'   : whether or not to force processing if the image exists
%               (default) 0


% default bands are all.
opt_incang = 'AREOID';
bands = true(in_crismdata.hdr.bands,1);
band_inverse = false;
suffix = '_phot1';
default_bands = []; % if this is empty, estimated with "get_default_bands.m"
save_dir = in_crismdata.dirpath; % default is the same directory as the input image.
force = 0;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'BANDS'
                bands = varargin{i+1};
                if islogical(bands)
                    bands = find(bands);
                end
            case 'BAND_INVERSE'
                band_inverse = varargin{i+1};
            case 'DEFAULT_BANDS'
                default_bands = varargin{i+1};
            case 'SUFFIX'
                suffix = varargin{i+1};
                if ~strcmpi(suffix(1),'_')
                    suffix = ['_' suffix];
                end
            case 'SAVE_DIR'
                save_dir = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'OPT_INCANG'
                opt_incang = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

%% check the existence of the file

basename_proj = [in_crismdata.basename suffix];

fpath_hdr_proj = joinPath(save_dir, [basename_proj '.hdr']);
fpath_img_cor = joinPath(save_dir, [basename_proj '.img']);

outputs_fpath = {fpath_hdr_proj,fpath_img_cor};

% examine if all the output files exist.
exist_flg = all(cellfun(@(x) exist(x,'file'),outputs_fpath));

if exist_flg && ~force
    flg = 1;
    while flg
        prompt = sprintf('There exists processed images. Do you want to continue to process and overwrite?(y/n)');
        ow = input(prompt,'s');
        if any(strcmpi(ow,{'y','n'}))
            flg=0;
        else
            fprintf('Input %s is not valid.\n',ow);
        end
    end
    if strcmpi(ow,'n')
        fprintf('Process aborted...\n');
        return;
    elseif strcmpi(ow,'y')
        fprintf('processing continues and will overwrite...\n');
    end
end

if ~exist(save_dir,'dir'), mkdir(save_dir); end

%% main processing
if band_inverse
    in_crismdata.readimgi();
else
    in_crismdata.readimg();
end

DEdata.readimg();

img = in_crismdata.img;

switch upper(opt_incang)
    case 'MOLA'
        incang = DEdata.ddr.INA_at_surface_from_MOLA.img;
    case 'AREOID'
        incang = DEdata.ddr.INA_at_areoid.img;
    otherwise
        error('%s is not defined',opt_incang);
end
        
[img_cor] = crism_photocor(img(:,:,bands),incang);


%% construct header file
if isfield(in_crismdata,'lbl') && ~isempty(in_crismdata.lbl)
    % assume direct processing from pds image
    hdr_cor = crism_const_cathdr(in_crismdata,band_inverse);
else
    % assume processing from CAT or second product
    hdr_cor = in_crismdata.hdr;
    if band_inverse
        hdr_cor.wavelength = flip(hdr_cor.wavelength);
        hdr_cor.fwhm = flip(hdr_cor.fwhm);
        hdr_cor.bbl = flip(hdr_cor.bbl);
        if ischar(hdr_cor.cat_ir_waves_reversed)
            if strcmpi(hdr_cor.cat_ir_waves_reversed,'YES')
                hdr_cor.cat_ir_waves_reversed = 'NO';
            elseif strcmpi(hdr_cor.cat_ir_waves_reversed,'NO')
                hdr_cor.cat_ir_waves_reversed = 'YES';
            end
        end
    end
end

B = length(bands);
hdr_cor.wavelength = hdr_cor.wavelength(bands);
hdr_cor.bbl = hdr_cor.bbl(bands);
hdr_cor.fwhm = hdr_cor.fwhm(bands);
hdr_cor.band_names = arrayfun(@(x) sprintf('Georef (Band %d: %s)',x,in_crismdata.basename),bands,...
    'UniformOutput',false);
hdr_cor.bands = B;
hdr_cor.cat_history = [hdr_cor.cat_history '_PHCc'];
hdr_cor.cat_input_files = [in_crismdata.basename ', ' DEdata.basename];

if isempty(default_bands)
    hdr_cor.default_bands = get_default_bands(hdr_cor.wavelength);
end

%% saving the image
fprintf('Saving %s ...\n',fpath_hdr_proj);
envihdrwritex(hdr_cor,fpath_hdr_proj,'OPT_CMOUT',false);
fprintf('Done\n');
fprintf('Saving %s ...\n',fpath_img_cor);
envidatawrite(single(img_cor),fpath_img_cor,hdr_cor);
fprintf('Done\n');




end