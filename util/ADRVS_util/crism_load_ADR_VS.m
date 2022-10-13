function [ trans_spcs ] = crism_load_ADR_VS( varargin )
% [ trans_spcs ] = crism_load_ADR_VS( varargin )
% 
% OUTPUTS
%  trans_spcs: stacked transmission spectra [n x S x L]
%              (n: number of frames, S: samples, L: bands)
% Optional parameters
%    'BAND_INVERSE': if the band should be inversed or not
%                    (default) true
%    'BINNING': binning mode either {0,1,2,3}, numeric or single character
%               (default) 0
%    'WAVELENGH_FILTER': wavelenth filter, either {0,1,2,3} numeric or single character
%                       (default) 0
%    'SCLK': sclk
%    'VERSION': scalar either [6,8,9] or str "latest". Versions 6 & 8 are not
%               recommended.
%              (default) 9
%    'OBS_ID_SHORT': OBSEVATION ID shortend. (defaut) ''
%    'MODE_ARTIFACT': specify how to deal with artifact. {'subtraction', 'none'}
%                     (default) 'subtraction'
%    'ARTIFACT_IDX': specify which data is used as artifact {2,3}. 2: new
%                    Patrick C. McGuire method and 3: old Pelky method.
%                    (default) 2
%    'OVERWRITE' : whether or not to overwrite the cache file
%                  (default) false
%    'DIR_CACHE' : Directory path where cache files are saved.
%       (default) crism_env_vars.dir_CACHE
%

global crism_env_vars
dir_cache = crism_env_vars.dir_CACHE;

is_band_inverse = true;
artifact_idx = 2;
mode_artifact = 'subtraction';
binning = '0'; wv_filter = '0'; vr = '9'; obs_id_short = '';
overwrite = false;
dwld = 0;
vr_latest = false;
sclk = 0;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'BINNING'
                binning = varargin{i+1};
                if isnumeric(binning)
                    binning = sprintf('%1d',binning);
                end
            case 'WAVELENGTH_FILTER'
                wv_filter = varargin{i+1};
                 if isnumeric(wv_filter)
                    wv_filter = sprintf('%1d',wv_filter);
                 end
            case 'VERSION'
                vr = varargin{i+1};
                if isscalar(vr)
                    vr = sprintf('%1d',vr);
                elseif ischar(vr)
                    if strcmpi(vr,'latest')
                        vr = ''; vr_latest = true;
                    elseif ~isempty(regexpi(vr,'\d{1}','ONCE'))
                        
                    else
                        error('given version is not supported, only scalar single degit or "latest"');
                    end
                else
                    error('given version is not supported, only scalar single degit or "latest"');
                end

            case 'OBS_ID_SHORT'
                obs_id_short = varargin{i+1};
            case 'SCLK'
                sclk = varargin{i+1};
            case 'MODE_ARTIFACT'
                mode_artifact = varargin{i+1};
            case 'ARTIFACT_IDX'
                artifact_idx = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'DIR_CACHE'
                dir_cache = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

if strcmpi(binning,'3') && strcmpi(wv_filter,'2')
    if sclk == 0
        error('BINNING:3 and WAVELENGTH_FILTER:2 requires sclk input.');
    end
else
    if sclk ~= 0
        sclk = 0;
    end
    
end
propADRVSPtr = crism_create_propADRVSbasename();
if ~isempty(binning), propADRVSPtr.binning = binning; end
if ~isempty(wv_filter), propADRVSPtr.wavelength_filter = wv_filter; end
if ~isempty(vr), propADRVSPtr.version = vr; end
if ~isempty(obs_id_short), propADRVSPtr.obs_id_short = obs_id_short; end
if ~isempty(sclk), propADRVSPtr.sclk = sclk; end

%%

if strcmpi(binning,'3') && strcmpi(wv_filter,'2')
    if isempty(obs_id_short)
        cachefname = sprintf('adr_sclk%010d_VS%1s%1s%1s_art%s_aid%d.mat',...
            sclk,binning,wv_filter,vr,mode_artifact,artifact_idx);
    else
        cachefname = sprintf('adr_sclk%010d_VS_%s_%1s%1s%1s_art%s_aid%d.mat',...
            sclk,obs_id_short,binning,wv_filter,vr,mode_artifact,artifact_idx);
    end
else
    if isempty(obs_id_short)
        cachefname = sprintf('adr_VS%1s%1s%1s_art%s_aid%d.mat',...
            binning,wv_filter,vr,mode_artifact,artifact_idx);
    else
        cachefname = sprintf('adr_VS_%s_%1s%1s%1s_art%s_aid%d.mat',...
            obs_id_short,binning,wv_filter,vr,mode_artifact,artifact_idx);
    end

end
    
cachefpath = joinPath(dir_cache,cachefname);
if ~exist(dir_cache,'dir'), mkdir(dir_cache); end

if ~overwrite && exist(cachefpath,'file')
    load(cachefpath,'trans_spcs');
else
    [ADRVSdataList] = crism_get_ADRVSdata(propADRVSPtr,'Dwld',dwld);
    if vr_latest
        % select the latest versions if vr='latest' is set
        [ADRVSdataList,idxes_latest] = crism_select_latest_version_ADRVSdata(ADRVSdataList);
    end
    % the data only different in psclk are same. 
    [ADRVSdataList,idxes_selected] = crism_get_ADRVSdata_psclk_ignored(ADRVSdataList);
    
    trans_spcs = [];
    for i=1:length(ADRVSdataList)
        [ T ] = crism_get_T_from_ADRVSdata(ADRVSdataList(i),'MODE',mode_artifact,...
            'Artifact_idx',artifact_idx,'band_inverse',is_band_inverse);
        trans_spcs = cat(1,trans_spcs,T);
    end
   
    save(cachefpath,'trans_spcs');
end

end

