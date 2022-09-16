function [out] = crism_vscor_internal_main(crism_data_obj,varargin)
% [out] = crism_vscor_internal_main(crism_data_obj,varargin)
%   crism volcano scan correction, main loop
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
%     settings
% OPTIONAL Parameters
%   ## ADR VS OPTIONS #----------------------------------------------------
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
%   ## PROCESSING OPTIONS #------------------------------------------------
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
%   {'ARTIFACT_CORRCETION','ART','ENABLE_ARTIFACT'}: boolean
%      (default) true
%   'ATMT_VSID': char, only valid with 'ATMT_SRC_OPT'='user'
%      (default) ''
%   {'DDRDATA','DDR'} : CRISMDDRdata class obj associated with 
%      crism_data_obj, only valid with 'PHOTOMETRIC_CORRECTION' = true
%      (default) []
% 
%   ## Image Options #-----------------------------------------------------
%   {'CLIST'} : 1d array, sample indices to be processed
%      (default) ':'
%   {'LLIST'} : 1d array, line indices to be processed
%      (default) ':'
%   {'BLIST'} : 1d array, band indices to be processed
%      (default) ':'
%   {'BLIST_INVERSE'} : boolean,
%      whether or not the input BLIST is inverted.
%      (default) false
%   
%   

% ## ADR VS OPTIONS #------------------------------------------------------
adrvs_sclk = '0';
adrvs_vr   = 9;
artifact_pre = false;

% ## PROCESSING OPTIONS #--------------------------------------------------
phot       = false;   % boolean
opt_incang = 'AREOID';% {'AREOID','MOLA'}
atmt_src   = 'trial'; % {'trial','user','auto',tbench','default'}
bandset_id = 'mcg';   % {'pel','mcg',0,1}
enable_artifact = true; % boolean
atmt_vsid  = '';
DEdata    = [];


% ## Image Options #-------------------------------------------------------
cList = ':';
lList = ':';
bList = ':';
bList_inverse = false;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            % ## ADR VS OPTIONS #------------------------------------------
            case 'ADRVS_SCLK'
                adrvs_sclk = varargin{i+1};
            case 'ADRVS_VERSION'
                adrvs_vr = varargin{i+1};
            case 'ARTIFACT_PRE'
                artifact_pre = varargin{i+1};
            % ## PROCESSING OPTIONS #--------------------------------------
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
            % ## Image OPTIONS #-------------------------------------------
            case {'CLIST'}
                cList = varargin{i+1};
            case {'LLIST'}
                lList = varargin{i+1};
            case {'BLIST'}
                bList = varargin{i+1};
            case {'BLIST_INVERSE'}
                bList_inverse = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

% Flip bList
if ~strcmpi(bList,':') && bList_inverse
    if logical(bList)
        bList = flip(bList);
    elseif isnumeric(bList)
        bList = crism_data_obj.hdr.bands - bList + 1;
    else
        error('Something wrong with bList');
    end
end


%% read base information
img = crism_data_obj.readimg();
switch class(crism_data_obj)
    case 'CRISMdata'
        if isempty(crism_data_obj.basenamesCDR)
            crism_data_obj.load_basenamesCDR();
        end
        if isempty(crism_data_obj.cdr) || ~isfield(crism_data_obj.cdr,'WA')
            crism_data_obj.readCDR('WA');
        end
        WAdata = crism_data_obj.cdr.WA;
    case 'CRISMdataCAT'
        crism_data_obj.load_basenamesCDR_fromCRISMdata_parent();
        crism_data_obj.CRISMdata_parent.readCDR('WA');
        WAdata = crism_data_obj.CRISMdata_parent.cdr.WA;
    otherwise
        error('Invalid crism_data_obj (class %s)',class(crism_data_obj));
end

waimg  = WAdata.readimg();
binning_id = WAdata.prop.binning;
wv_filter  = WAdata.prop.wavelength_filter;

%% Photometric correction
if phot
    if isempty(DEdata)
        [DEdata] = crism_get_associated_DDR(crism_data_obj);
    end
    fprintf('Selected %s in %s.\n',DEdata.basename,DEdata.dirpath);
    DEdata.readimg();
    
    switch upper(opt_incang)
        case 'MOLA'
            incang = DEdata.ddr.INA_at_surface_from_MOLA.img;
        case 'AREOID'
            incang = DEdata.ddr.INA_at_areoid.img;
        otherwise
            error('%s is not defined',opt_incang);
    end

    [img] = crism_photocor(img,incang);
end

%% First select observation ids for VS.
switch lower(atmt_src)
    case 'trial'
        % First try loading pre-selected vsid for the given obs_id.
        % This information is in CAT_ENVI/aux_files/obs_info/crism_obs_info.txt
        obs_id = crism_data_obj.prop.obs_id;
        vsid = crism_vscor_get_vsid_from_obsinfo(obs_id,bandset_id);

        % If vsid is not detected, then perform trial
        if isempty(vsid) || hex2dec(vsid)==0
            ADRVSdataList = crism_get_ADRVSdatax( ...
                'binning',binning_id, 'wavelength_filter', wv_filter, ...
                'SCLK',adrvs_sclk, 'Version',adrvs_vr, ...
                'NO_ICY',true, 'NO_DUSTY',true ...
            );
            vsid = crism_vscor_get_trial(img,waimg,bandset_id,ADRVSdataList);
        end
    case 'user'
        vsid = atmt_vsid;
        % if isempty(vsid)
        %     vsid = crism_vscor_get_vsid_user();
        % end
    case 'default'
        vsid = '61C4';
        % vsid = crism_vscor_get_vsid_default();
    case {'auto','tbench'}
        error('ATMT_SRC_OPT=%s\n is not supported.');
        % vsid = crism_vscor_get_vsid_auto();
        % vsid = crism_vscor_get_vsid_tbench();
    otherwise
        error('Undefined ATMT_SRC_OPT=%s\n',atmt_src);
end

% 
adrvsdata_obj = crism_get_ADRVSdatax('obs_id_short',vsid, ...
    'binning',binning_id, 'wavelength_filter', wv_filter, ...
    'SCLK',adrvs_sclk, 'Version',adrvs_vr ...
);
if length(adrvsdata_obj)>1
    error('Multiple ADR VS data are selected.');
end
fprintf('Selected %s.\n',vsid);
fprintf('Selected %s in %s.\n',adrvsdata_obj.basename,adrvsdata_obj.dirpath);


%% Perform correction

% scale atmospheric transmission
adrvsdata_obj.load_data();
vstrans = adrvsdata_obj.trans;

if strcmpi(cList,':') || lList~=':' || bList~=':'
    img     = img(lList,cList,bList);
    waimg   = waimg(1,cList,bList);
    vstrans = vstrans(1,cList,bList);
end

% Perform ARTIFACT_PRE
if artifact_pre
    switch lower(artifact_pre)
        case 'mcg'
            vsart_pre = adrvsdata_obj.art_mcg;
        case 'pel'
            vsart_pre = adrvsdata_obj.art_pel;
        otherwise
            error('Undefined ARTIFACT_PRE %s',bandset_id);
    end
    vsart_pre = vsart_pre(1,cList,bList);
    vstrans   = vstrans - vsart_pre;
end

[img_corr,scale_factor] = crism_vscor_scaleatm_pcm(img,waimg,bandset_id,vstrans);

% artifact correction
if enable_artifact
    % Get artifact array:
    switch lower(bandset_id)
        case {'mcg',0}
            vsart = adrvsdata_obj.art_mcg;
        case {'pel',1}
            vsart = adrvsdata_obj.art_pel;
        otherwise
            if isnumeric(bandset_id), bandset_id = num2str(bandset_id); end
            error('Undefined bandset_id %s',bandset_id);
    end
    if cList~=':' || lList~=';' || bList~=':'
        vsart = vsart(1,cList,bList);
    end
    % Perform artifact correction
    [img_corr_patched,out_art] = crism_vscor_patch_vs_artifact_v2(waimg,img_corr,vsart);
    % for some reason, v3 is not working.
    % [img_corr_patched,out_art] = crism_vscor_patch_vs_artifact_v3(waimg,img_corr,vsart);
    img_corr = img_corr_patched;
else
    vsart = [];
end

%% Post processing
settings = [];
settings.PHOTOMETRIC_CORRECTION = phot;
settings.PHC_ANGLE_TOPO = opt_incang;
settings.DDR  = DEdata;
settings.ATMT_SRC = atmt_src;
settings.BANDSET_ID = bandset_id;
settings.ENABLE_ARTIFACT = enable_artifact;
settings.vsid = vsid;
settings.ARTIFACT_PRE = artifact_pre;


out = [];
out.img_corr  = img_corr;
out.wa        = waimg;
out.ADRVSdata = adrvsdata_obj;
out.trans_spc = vstrans;
out.scale_factor = scale_factor;
if enable_artifact
    out.artifact  = vsart;
    out.artifact_scale_factor = out_art.scl;
end
out.settings = settings;



end

