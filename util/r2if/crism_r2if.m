function [out] = crism_r2if(crism_data_obj,varargin)
% [out] = crism_r2if(crism_data_obj,varargin)
%   crism radiance to I/F conversion
% INPUTS
%   crism_data_obj: CRISMdata class obj, needs to be I/F products
% OUTPUTS
%   out: struct, storing the result of r2if
%    IoF : I/F cube [L x S x B]
%    wa
%    sfimg
%    d_au
%    settings
%     
% OPTIONAL Parameters
%  ## I/O OPTIONS  #-------------------------------------------------------
%   'SAVE_FILE': boolean
%       whether or not to save processed images. If true, two optioal 
%       parameters 'FORCE','SKIP_IFEXIST' have no effect.
%       (default) true
%   'SAVE_PDIR': any string or empty.
%       root directory path where the processed data are stored. The data
%       will be by default to save to the same directory as the input
%       image. By default, this is empty.
%       If specified, processed image will be saved at 
%       <SAVE_PDIR>/CCCNNNNNNNN, where CCC the class type of the obervation
%       and NNNNNNNN is the observation id.
%       It doesn't matter if trailing slash is there or not.
%       (default) []
%   'SAVE_DIR_YYYY_DOY': boolean
%       if true, processed images are saved at 
%           <SAVE_PDIR>/YYYY_DOY/CCCNNNNNNNN,
%       otherwise, 
%           <SAVE_PDIR>/CCCNNNNNNNN.
%       (default) false
%   'FORCE': boolean
%       if true, processing is forcefully performed and all the existing
%       images will overwritten. Otherwise, you will see a prompt asking
%       whether or not to continue and overwrite images or not when there
%       alreadly exist processed images.
%       (default) false
%   'SKIP_IF_EXIST': boolean
%       if true, processing will be automatically skipped if there already 
%       exist processed images. No prompt asking whether or not to continue
%       and overwrite images or not.
%       (default) false
%   'SUFFIX': any string,
%       Custom suffix
%       (default) 'RA_IF'
%   'ADDITIONAL_SUFFIX': any string,
%       any additional suffix added to the name of processd images.
%       (default) ''
%   'INTERLEAVE_OUT': string, {'lsb','bls'}
%       interleave option of the images in the output parameter, out. This
%       is not the interleave used for saving processed images. 
%       'lsb': Line-Sample-Band
%       'bls': Band-Line-Sample
%       (default) 'lsb'
%   'FLIP_BAND': Boolean
%       whether or not to flip bands 
%       (default) false
%
%  ## PROCESSING OPTIONS  #------------------------------------------------
%   {'DDRDATA','DDR'} : CRISMDDRdata class obj associated with 
%      crism_data_obj, only valid with 'PHOTOMETRIC_CORRECTION' = true
%      (default) []
%   {'SFDATA'} : SFdata class obj associated with 
%      (default) []
%   {'DISTANCE_KM'} : distance in kilometers
%      (default) []
%   
%   # Image Options #------------------------------------------------------
%   {'CLIST'} : 1d array, sample indices to be processed
%      (default) ':'
%   {'LLIST'} : 1d array, line indices to be processed
%      (default) ':'
%   {'BLIST'} : 1d array, band indices to be processed
%      (default) ':'
%   {'BLIST_INVERSE'} : boolean,
%      whether or not the input BLIST is reversed or not.
%      (default) false

%   # Other Options #------------------------------------------------------
%   'VERBOSE' : boolean, whether to print details
%      (default) true

% ## I/O OPTIONS #---------------------------------------------------------
save_file          = true;
save_pdir          = [];
save_dir_yyyy_doy  = false;
force              = false;
skip_ifexist       = false;
suffix             = '';
additional_suffix  = '';
interleave_out     = 'lsb';
interleave_default = 'lsb';
flip_band          = false;

% ## PROCESSING OPTIONS #--------------------------------------------------
DEdata = [];
SFdata = [];
dst_km = [];


% # Image Options #--------------------------------------------------------
cList = ':';
lList = ':';
bList = ':';
bList_inverse = false;

% # Other Options #--------------------------------------------------------
verbose = true;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            % ## I/O OPTIONS #---------------------------------------------
            case 'SAVE_FILE'
                save_file = varargin{i+1};
            case 'SAVE_PDIR'
                save_pdir = varargin{i+1};
            case 'SAVE_DIR_YYYY_DOY'
                save_dir_yyyy_doy = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'SKIP_IFEXIST'
                skip_ifexist = varargin{i+1};
            case 'SUFFIX'
                suffix = varargin{i+1};
            case 'ADDITIONAL_SUFFIX'
                additional_suffix = varargin{i+1};
            case 'INTERLEAVE_OUT'
                interleave_out = varargin{i+1};
            case 'FLIP_BAND'
                flip_band = varargin{i+1};
                
            % ## PROCESSING OPTIONS #--------------------------------------
            case {'DDRDATA','DDR','DEDATA'}
                DEdata = varargin{i+1};
            % # Image OPTIONS #--------------------------------------------
            case {'CLIST'}
                cList = varargin{i+1};
            case {'LLIST'}
                lList = varargin{i+1};
            case {'BLIST'}
                bList = varargin{i+1};
            case {'BLIST_INVERSE'}
                bList_inverse = varargin{i+1};
            
            % ## OTHER OPTIONS #-------------------------------------------
            case 'VERBOSE'
                verbose = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

if save_file && force && skip_ifexist
    error('You are forcing or skipping? Not sure what you want');
end

if save_file && ~isempty(save_pdir) && ~exist(save_pdir,'dir')
    [status] = mkdir(save_pdir); 
    if status
        if verbose, fprintf('"%s" is created.\n',save_pdir); end
        chmod777(save_pdir,verbose);
    else
        error('Failed to create %s',save_pdir);
    end
end

%%
%--------------------------------------------------------------------------
% cheking the directory path
%--------------------------------------------------------------------------
if save_file
    if isempty(save_pdir)
        save_dir = crism_data_obj.dirpath;
        [status777] = chmod777(save_dir,verbose);
    else
        if save_dir_yyyy_doy
            dirpath_yyyy_doy = joinPath(save_pdir,crism_obs.info.yyyy_doy);
            [status,status777] = mkdir777(dirpath_yyyy_doy,verbose);
            save_dir = joinPath(dirpath_yyyy_doy,crism_obs.info.dirname);
        else
            save_dir = joinPath(save_pdir,crism_obs.info.dirname);
        end
        [status,status777] = mkdir777(save_dir,verbose);
    end
end

%--------------------------------------------------------------------------
% cheking the processed file exists or not.
%--------------------------------------------------------------------------
if save_file 
    if isempty(suffix)
        suffix = 'IF';
        if ~isempty(additional_suffix)
            suffix = [suffix '_' additional_suffix];
        end
    end
    
    fprintf('suffix will be \n"%s"\n',suffix);
    basename_cr = [crism_data_obj.basename '_' suffix];

    imgpath_cr = joinPath(save_dir,[basename_cr,'.img']);
    hdrpath_cr = joinPath(save_dir,[basename_cr,'.hdr']);
    % collect all 
    cachepaths = {imgpath_cr,hdrpath_cr};
    
    % Evaluate to perform the 
    [flg_reproc] = doyouwanttoprocess(cachepaths,force,skip_ifexist);
    if ~flg_reproc
        return;
    end

end

%% Perform computation
[out] = crism_r2if_internal_main(crism_data_obj, ...
    'DDR',DEdata, 'SFdata',SFdata, 'DISTANCE_KM',dst_km, ...
    'CLIST',cList,'LLIST',lList,'BList',bList,'BList_Inverse',bList_inverse);
%   out: struct, storing the result of r2if
%    IoF : I/F cube [L x S x B]
%    wa
%    sfimg
%    d_au
%    settings
%% Post processing tasks
% =========================================================================
% Create Header file for the output
% =========================================================================
dt = datetime('now','TimeZone','local','Format','eee MMM dd hh:mm:ss yyyy');
[hdr_cat] = crism_const_cathdr(crism_data_obj,0,'date_time',dt);
hdr_cat.samples = size(out.IoF,2);
hdr_cat.lines   = size(out.IoF,1);
hdr_cat.bands   = size(out.IoF,3);
nBall = crism_data_obj.hdr.bands;
if strcmpi(bList,':')
    bands = 1:nBall;
else
    if islogical(bList)
        bands = find(bList);
        if bList_inverse, bands = nBall - bands + 1; end
    elseif isnumeric(bList)
        bands = bList;
    end
    hdr_cat.wavelength = hdr_cat.wavelength(bands);
    hdr_cat.fwhm = hdr_cat.fwhm(bands);
    hdr_cat.bbl  = hdr_cat.bbl(bands);
    if ~strcmpi(bList,':')
        hdr_cat.band_names = arrayfun( ...
            @(x) sprintf('Band %3d of %s',x,crism_data_obj.basename), ...
            bands,'UniformOutput',false);
    end
end


% -------------------------------------------------------------------------
% Create CAT_HISTORY field 
% -------------------------------------------------------------------------
% If Photometric correction is applied, then add "PHCc" to CAT_HISTORY
if isempty(hdr_cat.cat_history)
    hdr_cat.cat_history = 'RIF';
else
    hdr_cat.cat_history = [hdr_cat.cat_history '_' 'RIF'];
end

% Input files
[~,inputimgfilename,ext] = fileparts(crism_data_obj.imgpath);
hdr_cat.cat_input_files = [inputimgfilename ext];

%% 
if flip_band
    out.img_if = flip(out.IoF,3);
    out.wa     = flip(out.wa,3);
    out.sfimg  = flip(out.sfimg,3);
    if strcmpi(bList,':')
        hdr_cat.band_names = arrayfun( ...
            @(x) sprintf('Band %3d of %s',x,crism_data_obj.basename), ...
            bands,'UniformOutput',false);
    end
    hdr_cat.band_names = flip(hdr_cat.band_names);
    hdr_cat.wavelength = flip(hdr_cat.wavelength);
    hdr_cat.fwhm = flip(hdr_cat.fwhm);
    hdr_cat.bbl  = flip(hdr_cat.bbl);
    switch upper(crism_data_obj.prop.sensor_id)
        case 'L'
            hdr_cat.default_bands = crism_get_default_bands_L(hdr_cat.wavelength*1000);
        case 'S'
            hdr_cat.default_bands = crism_get_default_bands_S(hdr_cat.wavelength*1000);
        otherwise
            error('Undefined sensor_id %s',crism_data_obj.prop.sensor_id);
    end
    bands = flip(bands);
    hdr_cat.cat_ir_waves_reversed = 'YES';
end

% =========================================================================
% Save file
% =========================================================================
if save_file
    % SAVE the correct image cube
    fprintf('Saving %s ...\n',hdrpath_cr);
    envihdrwritex(hdr_cat,hdrpath_cr,'OPT_CMOUT',false);
    chmod777(hdrpath_cr,verbose);
    fprintf('Done\n');
    
    fprintf('Saving %s ...\n',imgpath_cr);
    envidatawrite(single(out.IoF),imgpath_cr,hdr_cat);
    chmod777(imgpath_cr,verbose);
    fprintf('Done\n');

    % SAVE supporting file
    fpath_supple = joinPath(save_dir,[basename_cr '.mat']);   
    fprintf('Saving %s ...\n',fpath_supple);
    wa = out.wa;
    sfimg  = out.sfimg;
    d_au   = out.d_au;
    settings = out.settings;
    save(fpath_supple,'wa','sfimg','d_au','settings','lList','cList','bands');
    chmod777(fpath_supple,verbose);
    fprintf('Done\n');
end

% =========================================================================
% Create Output
% =========================================================================
if nargout==0
    out = [];
elseif nargout==1

    % take the subset of the columns
    % Permute the output.
    prmt_ordr   = [find(interleave_out(1)==interleave_default),...
                   find(interleave_out(2)==interleave_default),...
                   find(interleave_out(3)==interleave_default)];
    out.IoF   = permute(out.IoF,   prmt_ordr);
    out.wa    = permute(out.wa,    prmt_ordr);
    out.sfimg = permute(out.sfimg, prmt_ordr);

    out.hdr          = hdr_cat;
    out.lines        = lList;
    out.columns      = cList;
    out.bands        = bands;
    out.interleave_out = interleave_out;
    
end
end



