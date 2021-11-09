function [out] = crism_vscor(crism_data_obj,varargin)
% [out] = crism_vscor(crism_data_obj,varargin)
%   crism volcano scan correction
% INPUTS
%   crism_data_obj: CRISMdata class obj, needs to be I/F products
% OUTPUTS
%   out: struct holding the result of the correction
%     img_corr      : [L x S x B] corrected image cube
%     wa            : [1 x S x B] wavelenth frame
%     ADRVSdata     : CRISMADRVSdata class obj for the selected ADR
%     trans_spc     : [1 x S x B] original transmission spectrum frame
%     scale_factor  : [L x S], scaling factor for trans_spc
%     artifact      : [1 x S x B] original artifact shape (only enable_artifact)
%     artifact_scale_factor : [L x S], scaling factor for artifact (only enable_artifact)
%     hdr
%     samples
%     lines
%     bands
%     interleave_out
%     settings
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
%       (default) ''
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
%   # ADR VS OPTIONS #-----------------------------------------------------
%   {'ADRVS_SCLK'} : sclk time of the ADR VS
%     (default) '0'
%   {'ADRVS_VERSION'} : 
%     version of the ADR VS data
%     (default) 9
%   {'ARTIFACT_PRE'} : {false, 'mcg', 'pel'}
%     This option is created by Yuki.
%     whether or not to apply artifact beforehand. Recommend this to use
%     without artifact correction since the component is applied in a
%     different way.
%     false : do not apply
%     'mcg' : subtract mcg artifact from the transmission before scale_atmt
%     'pel' : subtract mcg artifact from the transmission before scale_atmt
%     (default) false
%
%   # PROCESSING OPTIONS #-------------------------------------------------
%   {'PHOTOMETRIC_CORRECTION','PHC'} : boolean
%      (default) false
%   'PHC_ANGLE_TOPO' : char, {'AREOID','MOLA'}
%      the topography on which emission angles are defined
%      (default) 'AREOID'
%   {'ATMT_SRC_OPT','ATMT_SRC'} : char, 
%      {'trial','user'} potential future support:{'auto',tbench','default'}
%      (default) 'trial'
%   'BANDSET_ID' : str, {'pel','mcg',0,1}
%       'mcg',0 : McGuire (2007/1980)
%       'pel',1 : Pelky   (2011/1899)
%      (default) 'mcg'
%   {'ARTIFACT_CORRECTION','ART','ENABLE_ARTIFACT'}: boolean
%      (default) true
%   'ATMT_VSID': char, only valid with 'ATMT_SRC_OPT'='user'
%      (default) ''
%   {'DDRDATA','DDR'} : CRISMDDRdata class obj associated with 
%      crism_data_obj, only valid with 'PHOTOMETRIC_CORRECTION' = true
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
% # ADR VS OPTIONS #-------------------------------------------------------
adrvs_sclk = '0';
adrvs_vr   = 9;
artifact_pre = false;

% # PROCESSING OPTIONS #---------------------------------------------------
phot       = false;   % boolean
opt_incang = 'AREOID';% {'AREOID','MOLA'}
atmt_src   = 'trial'; % {'trial','user','auto',tbench','default'}
bandset_id = 'mcg';   % {'pel','mcg',0,1}
enable_artifact = true; % boolean
atmt_vsid  = '';
DEdata    = [];


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
            % # ADR VS OPTIONS #-------------------------------------------
            case 'ADRVS_SCLK'
                adrvs_sclk = varargin{i+1};
            case 'ADRVS_VERSION'
                adrvs_vr = varargin{i+1};
            case 'ARTIFACT_PRE'
                artifact_pre = varargin{i+1};
            
            % # PROCESSING OPTIONS #---------------------------------------
            case {'PHOTOMETRIC_CORRECTION','PHC'}
                phot = varargin{i+1};
            case {'PHC_ANGLE_TOPO'}
                opt_incang = varargin{i+1};
            case {'ATMT_SRC_OPT','ATMT_SRC'}
                atmt_src = varargin{i+1};
            case 'BANDSET_ID'
                bandset_id = varargin{i+1};
            case {'ARTIFACT_CORRECTION','ART','ENABLE_ARTIFACT'}
                enable_artifact = varargin{i+1};
            case 'ATMT_VSID'
                atmt_vsid = varargin{i+1};
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
        [suffix] = crism_vscor_get_suffix('ARTIFACT_PRE',artifact_pre, ...
            'PHOTOMETRIC_CORRECTION',phot,'PHC_ANGLE_TOPO',opt_incang, ...
            'ATMT_SRC',atmt_src,'BANDSET_ID',bandset_id, ...
            'ENABLE_ARTIFACT',enable_artifact,'ATMT_VSID',atmt_vsid,'DDR',DEdata);
        % if artifact_pre
        %     suffix = sprintf('corr_phot%d_%s_%s_a%d_ap%s',phot,atmt_src, ...
        %         bandset_id,enable_artifact,artifact_pre);
        % else
        %     suffix = sprintf('corr_phot%d_%s_%s_a%d',phot,atmt_src, ...
        %         bandset_id,enable_artifact);
        % end
        
    end
    if ~isempty(additional_suffix)
        suffix = [suffix '_' additional_suffix];
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
[out] = crism_vscor_internal_main(crism_data_obj, ...
    'ADRVS_SCLK',adrvs_sclk,'ADRVS_VERSION',adrvs_vr,'ARTIFACT_PRE',artifact_pre, ...
    'PHOTOMETRIC_CORRECTION',phot,'PHC_ANGLE_TOPO',opt_incang, ...
    'ATMT_SRC',atmt_src,'BANDSET_ID',bandset_id, ...
    'ENABLE_ARTIFACT',enable_artifact,'ATMT_VSID',atmt_vsid,'DDR',DEdata, ...
    'CLIST',cList,'LLIST',lList,'BList',bList,'BList_Inverse',bList_inverse);
%   out: struct holding the result of the correction
%     img_corr       : [L x S x B] corrected image cube
%     wa            : [1 x S x B] wavelenth frame
%     ADRVSdata     : CRISMADRVSdata class obj for the selected ADR
%     trans_spc     : [1 x S x B] original transmission spectrum frame
%     scale_factor  : [L x S], scaling factor for trans_spc
%     artifact      : [1 x S x B] original artifact shape (only enable_artifact)
%     artifact_scale_factor : [L x S], scaling factor for artifact (only enable_artifact)
%     settings
%% Post processing tasks
% =========================================================================
% Create Header file for the output
% =========================================================================
dt = datetime('now','TimeZone','local','Format','eee MMM dd hh:mm:ss yyyy');
[hdr_cat] = crism_const_cathdr(crism_data_obj,0,'date_time',dt);
hdr_cat.samples = size(out.img_corr,2);
hdr_cat.lines   = size(out.img_corr,1);
hdr_cat.bands   = size(out.img_corr,3);
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
if phot
    if isempty(hdr_cat.cat_history)
        cat_history = 'PHCc';
    else
        cat_history = [hdr_cat.cat_history '_' 'PHCc'];
    end
else
    cat_history = hdr_cat.cat_history;
end
% Atmospheric correction
switch enable_artifact
    case 0
        if artifact_pre
            enable_artifact_code = 'vy'; % Version Yuki.
        else
            enable_artifact_code = 'v1';
        end
    case 1
        enable_artifact_code = 'v2';
end
% Bandset ID
switch lower(bandset_id)
    case {0,'mcg'}
        bandset_id_code = 'm';
    case {1,'pel'}
        bandset_id_code = 'p';
    otherwise
        error('Undefined bandset_id %s',bandset_id);
end
% Observation ID for the ADR
vsid_trim = strip(out.settings.vsid,'left','0');
% atcode is the 
atcode = ['ATC' enable_artifact_code bandset_id_code vsid_trim];

if isempty(cat_history)
    cat_history = atcode;
else
    cat_history = [cat_history '_' atcode];
end

hdr_cat.cat_history = cat_history;

% Input files
[~,inputimgfilename,ext] = fileparts(crism_data_obj.imgpath);
hdr_cat.cat_input_files = [inputimgfilename ext];

%% 
if flip_band
    out.img_corr  = flip(out.img_corr,3);
    out.wa        = flip(out.wa,3);
    out.trans_spc = flip(out.trans_spc,3);
    if enable_artifact
        out.artifact  = flip(out.artifact,3);
    end
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
    envidatawrite(single(out.img_corr),imgpath_cr,hdr_cat);
    chmod777(imgpath_cr,verbose);
    fprintf('Done\n');

    % SAVE supporting file
    fpath_supple = joinPath(save_dir,[basename_cr '.mat']);   
    fprintf('Saving %s ...\n',fpath_supple);
    trans_spc = out.trans_spc;
    wa = out.wa;
    if enable_artifact
        artifact  = out.artifact;
        artifact_scale_factor = out.artifact_scale_factor;
    end
    scale_factor = out.scale_factor;
    
    settings = out.settings;
    if enable_artifact
        save(fpath_supple,'wa','trans_spc','scale_factor','artifact', ...
            'artifact_scale_factor','settings','lList','cList','bands');
    else
        save(fpath_supple,'wa','trans_spc','scale_factor', ...
            'settings','lList','cList','bands');
    end
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
    out.img_corr  = permute(out.img_corr,   prmt_ordr);
    out.wa        = permute(out.wa, prmt_ordr);
    out.trans_spc = permute(out.trans_spc, prmt_ordr);
    out.scale_factor = permute(out.scale_factor,  prmt_ordr);

    if enable_artifact
        out.artifact  = permute(out.artifact,  prmt_ordr);
        out.artifact_scale_factor = permute(out.artifact_scale_factor, prmt_ordr);
    end

    out.hdr          = hdr_cat;
    out.lines        = lList;
    out.columns      = cList;
    out.bands        = bands;
    out.interleave_out = interleave_out;
    
end
end



