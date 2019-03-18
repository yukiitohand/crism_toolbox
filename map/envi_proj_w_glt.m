function [] = envi_proj_w_glt(in_imgdata,GLTdata,varargin)
% [] = envi_proj_w_glt(in_crismdata,GLTdata,varargin)
%   perform map projection using GLT image data.
%  Input
%   in_crismdata: input CRISM data, to be projected
%   GLTdata: CRISM GLT data
%  Output
%   save a projected image. 
%   Default directory is the directory of the input CRISM data. Default
%   basename is the basename of the input CRISM data suffixed with suffix
%  Optional Parameters
%   'BANDS' : selected bands, boolean or array
%             (default) all the bands will be used
%   'DEFAULT_BANDS' : "default bands" property of the output image
%                     (default) selected using "get_default_bands.m"
%   'SUFFIX'  : suffix to the basename of the output image.
%               (default) '_p'
%   'SAVE_DIR' : saved directory
%                (default) same as the directory of input CRISM image
%   'FORCE'   : whether or not to force processing if the image exists
%               (default) 0


% default bands are all.
bands = 1:in_imgdata.hdr.bands;
band_inverse = false;
suffix = '_p';
default_bands = []; % if this is empty, estimated with "get_default_bands.m"
save_dir = in_imgdata.dirpath; % default is the same directory as the input image.
force = 0;
skip_ifexist = 0;

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
            case 'SKIP_IFEXIST'
                skip_ifexist = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

if force && skip_ifexist
    error('You are forcing or skipping? Not sure what you want');
end

%% check the existence of the file

basename_proj = [in_imgdata.basename suffix];

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
            return;
        elseif strcmpi(ow,'y')
            fprintf('processing continues and will overwrite...\n');
        end
    end
end

if ~exist(save_dir,'dir'), mkdir(save_dir); end

%% main processing
%in_imgdata.readimg();

img_flat = in_imgdata.img;
[img_proj] = img_proj_w_glt(img_flat(:,:,bands),GLTdata);


%% construct header file

hdr_proj = in_imgdata.hdr;

B = length(bands);
if isfield(hdr_proj,'wavelength'), hdr_proj.wavelength = hdr_proj.wavelength(bands); end
if isfield(hdr_proj,'bbl'), hdr_proj.bbl = hdr_proj.bbl(bands); end
if isfield(hdr_proj,'fwhm'), hdr_proj.fwhm = hdr_proj.fwhm(bands); end

hdr_proj.band_names = arrayfun(@(x) sprintf('Georef (Band %d: %s)',x,in_imgdata.basename),bands,...
                      'UniformOutput',false);
hdr_proj.samples = GLTdata.hdr.samples;
hdr_proj.lines = GLTdata.hdr.lines;
hdr_proj.bands = B;
hdr_proj.map_info = GLTdata.hdr.map_info;
hdr_proj.projection_info = GLTdata.hdr.projection_info;

hdr_proj.history = 'MAP projected';
hdr_proj.input_files = [in_imgdata.basename ', ' GLTdata.basename];

if ~isempty(default_bands)
    hdr_proj.default_bands = default_bands;
end


%% saving the image
fprintf('Saving %s ...\n',fpath_hdr_proj);
envihdrwritex(hdr_proj,fpath_hdr_proj,'OPT_CMOUT',false);
fprintf('Done\n');
fprintf('Saving %s ...\n',fpath_img_proj);
envidatawrite(single(img_proj),fpath_img_proj,hdr_proj);
fprintf('Done\n');
