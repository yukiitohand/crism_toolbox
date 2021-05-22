function [PROJIMGdata] = crism_proj_w_glt_v2(in_crismdata,GLTdata,varargin)
% [] = crism_proj_w_glt(in_crismdata,GLTdata,varargin)
%   perform map projection using GLT image data.
%  Input
%   in_crismdata: input CRISM data, to be projected
%   GLTdata: CRISM GLT data
%  Output
%   save a projected image. 
%   Default directory is the directory of the input CRISM data. Default
%   basename is the basename of the input CRISM data suffixed with suffix
%  Optional Parameters
%   'BANDS' : selected bands, boolean or array. If BAND_INVERSE is true,
%             the bands are applied after BAND_INVERSE is applied.
%             (default) all the bands will be used
%   'BAND_INVERSE' : whether or not to invert bands or not
%                    (default) false
%   'DEFAULT_BANDS' : "default bands" property of the output image
%                     (default) selected using "get_default_bands.m"
%   'SUFFIX'  : suffix to the basename of the output image.
%               (default) '_p'
%   'SAVE_DIR' : saved directory
%                (default) same as the directory of input CRISM image
%   'FORCE'   : whether or not to force processing if the image exists
%               (default) 0


% default bands are all.
bands = 1:in_crismdata.hdr.bands;
band_inverse = false;
suffix = '_p';
default_bands = []; % if this is empty, estimated with "crism_get_default_bands_L.m" or "crism_get_default_bands_S.m"
save_dir = in_crismdata.dirpath; % default is the same directory as the input image.
force = 0;
skip_ifexist = false;
save_file = 0;
set_default_bands = false;

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
            case 'SET_DEFAULT_BANDS'
                set_default_bands = varargin{i+1};
            case 'SUFFIX'
                suffix = varargin{i+1};
                if ~strcmpi(suffix(1),'_')
                    suffix = ['_' suffix];
                end
            case 'SAVE_FILE'
                save_file = varargin{i+1};
            case 'SAVE_DIR'
                save_dir = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'SKIP_IFEXIST'
                skip_ifexist = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

%% check the existence of the file
if save_file
    if ~exist(save_dir,'dir'), mkdir(save_dir); end
    basename_proj = [in_crismdata.basename suffix];

    fpath_hdr_proj = joinPath(save_dir, [basename_proj '.hdr']);
    fpath_img_proj = joinPath(save_dir, [basename_proj '.img']);

    outputs_fpath = {fpath_hdr_proj,fpath_img_proj};

    % examine if all the output files exist.
    exist_flg = all(cellfun(@(x) exist(x,'file'),outputs_fpath));

    if exist_flg
        if skip_ifexist
            return;
        elseif ~force
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
                PROJIMGdata = ENVIRasterMultBandEquirectProjRot0(basename_proj,save_dir);
                return;
            elseif strcmpi(ow,'y')
                fprintf('processing continues and will overwrite...\n');
            end
        end
    end

    
end

%% main processing
if band_inverse
    in_crismdata.readimgi();
else
    in_crismdata.readimg();
end

img_flat = in_crismdata.img;
[img_proj] = img_proj_w_glt(img_flat(:,:,bands),GLTdata);


%% construct header file
if isfield(in_crismdata,'lbl') && ~isempty(in_crismdata.lbl)
    % assume direct processing from pds image
    hdr_proj = crism_const_cathdr(in_crismdata,band_inverse);
else
    % assume processing from CAT or second product
    hdr_proj = in_crismdata.hdr;
    if band_inverse
        hdr_proj.wavelength = flip(hdr_proj.wavelength);
        hdr_proj.fwhm = flip(hdr_proj.fwhm);
        hdr_proj.bbl = flip(hdr_proj.bbl);
        if ischar(hdr_proj.cat_ir_waves_reversed)
            if strcmpi(hdr_proj.cat_ir_waves_reversed,'YES')
                hdr_proj.cat_ir_waves_reversed = 'NO';
            elseif strcmpi(hdr_proj.cat_ir_waves_reversed,'NO')
                hdr_proj.cat_ir_waves_reversed = 'YES';
            end
        end
    end
end

B = length(bands);
if isfield(hdr_proj,'wavelength')
    hdr_proj.wavelength = hdr_proj.wavelength(bands);
end
if isfield(hdr_proj,'bbl')
    hdr_proj.bbl = hdr_proj.bbl(bands);
end
if isfield(hdr_proj,'fwhm')
    hdr_proj.fwhm = hdr_proj.fwhm(bands);
end

if isfield(hdr_proj,'band_names')
    if band_inverse
        hdr_proj.band_names = flip(hdr_proj.band_names);
        hdr_proj.band_names = hdr_proj.band_names(bands);
    else
        hdr_proj.band_names = hdr_proj.band_names(bands);
    end
else
    if band_inverse
        hdr_proj.band_names = arrayfun(@(x) sprintf('Georef (Band %d: %s)',x,in_crismdata.basename),(hdr_proj.bands-bands+1),...
        'UniformOutput',false);
    else
        hdr_proj.band_names = arrayfun(@(x) sprintf('Georef (Band %d: %s)',x,in_crismdata.basename),bands,...
            'UniformOutput',false);
    end
end
    
hdr_proj.samples = GLTdata.hdr.samples;
hdr_proj.lines = GLTdata.hdr.lines;
hdr_proj.bands = B;
if isfield(hdr_proj,'cat_history')
    hdr_proj.cat_history = [hdr_proj.cat_history '_MAP'];
end
hdr_proj.cat_input_files = [in_crismdata.basename ', ' GLTdata.basename];
hdr_proj.map_info = GLTdata.hdr.map_info;
hdr_proj.projection_info = GLTdata.hdr.projection_info;

if set_default_bands
    if isempty(default_bands)
        switch upper(in_crismdata.prop.sensor_id)
            case 'L'
                hdr_proj.default_bands = crism_get_default_bands_L(hdr_proj.wavelength);
            case 'S'
                hdr_proj.default_bands = crism_get_default_bands_S(hdr_proj.wavelength,1);
            otherwise
                error('Unsupported sensor_id %s',in_crismdata.prop.sensor_id);
        end
    else
        hdr_proj.default_bands = default_bands;
    end
end

%% saving the image
if save_file
    fprintf('Saving %s ...\n',fpath_hdr_proj);
    envihdrwritex(hdr_proj,fpath_hdr_proj,'OPT_CMOUT',false);
    fprintf('Done\n');
    fprintf('Saving %s ...\n',fpath_img_proj);
    envidatawrite(img_proj,fpath_img_proj,hdr_proj);
    fprintf('Done\n');
end

PROJIMGdata = ENVIRasterMultBandEquirectProjRot0('','');
PROJIMGdata.hdr = hdr_proj;
PROJIMGdata.img = img_proj;

if save_file
    PROJIMGdata.basename = basename_proj;
    PROJIMGdata.dirpath  = save_dir;
    PROJIMGdata.imgpath  = fpath_img_proj;
    PROJIMGdata.hdrpath  = fpath_hdr_proj;
end



end

