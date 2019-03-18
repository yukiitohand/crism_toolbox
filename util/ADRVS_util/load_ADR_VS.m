function [ trans_spcs ] = load_ADR_VS( varargin )
% [ trans_spcs ] = load_ADR_VS( varargin )
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
%

global crism_env_vars
local_rootDir = crism_env_vars.localCRISM_PDSrootDir;

is_band_inverse = true;
artifact_idx = 2;
mode_artifact = 'subtraction';
binning = 0; wv_filter = 0; vr = '9'; obs_id_short = '';
overwrite = false;
dwld = 0;
vr_latest = false;

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
            case 'MODE_ARTIFACT'
                mode_artifact = varargin{i+1};
            case 'ARTIFACT_IDX'
                artifact_idx = varargin{i+1};
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

propADRVSPtr = create_propADRVSbasename();
if ~isempty(binning), propADRVSPtr.binning = binning; end
if ~isempty(wv_filter), propADRVSPtr.wavelength_filter = wv_filter; end
if ~isempty(vr), propADRVSPtr.version = vr; end
if ~isempty(obs_id_short), propADRVSPtr.obs_id_short = obs_id_short; end

%%

cachedpath = joinPath(local_rootDir,'cache/');
cachefname = sprintf('adr_VS%1s%1s%1s_art%s_aid%d.mat',...
                                  binning,wv_filter,vr,mode_artifact,artifact_idx);
cachefpath = joinPath(cachedpath,cachefname);
if ~exist(cachedpath,'dir'), mkdir(cachedpath); end

if ~overwrite && exist(cachefpath,'file')
    load(cachefpath,'trans_spcs');
else
    [ADRVSdataList] = get_ADRVSdata(propADRVSPtr,'Dwld',dwld);
    if vr_latest
        % select the latest versions if vr='latest' is set
        [ADRVSdataList,idxes_latest] = select_latest_version_ADRVSdata(ADRVSdataList);
    end
    % the data only different in psclk are same. 
    [ADRVSdataList,idxes_selected] = get_ADRVSdata_psclk_ignored(ADRVSdataList);
    
    trans_spcs = [];
    for i=1:length(ADRVSdataList)
        [ T ] = get_T_from_ADRVSdata(ADRVSdataList(i),'MODE',mode_artifact,...
            'Artifact_idx',artifact_idx,'band_inverse',is_band_inverse);
        trans_spcs = cat(1,trans_spcs,T);
    end
   
    save(cachefpath,'trans_spcs');
end

end

