function [ ADRVSdataList ] = crism_get_ADRVSdatax( varargin )
% [ ADRVSdataList ] = crism_get_ADRVSdatax( varargin )
%  Get ADRVSdata that matches given parameters.
% OUTPUTS
%   ADRVSdataList: List of CRISMADRVSdata obj of ADR VS data
% Optional parameters
%   'BINNING': {0,1,2,3}, numeric or single character
%     binning mode
%     (default) []
%   'WAVELENGH_FILTER': {0,1,2,3} numeric or single character
%     wavelenth filter
%     (default) []
%   'SCLK' : numeric or char "ignore"
%     spacecraft time of the filename of ADR VS data.
%     With "ignore", only ADR VS data with sclk=0 will be selected.
%     (default) []
%   'VERSION': [6,8,9] or char "latest". 
%     Versions number, 6 & 8 are not recommended.
%     (default) []
%   'OBS_ID_SHORT': char,
%     OBSEVATION ID shortend. 
%     (defaut) ''
%   'NO_ICY' : boolean
%     (default) false
%   'NO_DUSTY' : boolean
%     (default) false
%   'LOWNOISE' : boolean
%     (default) false

binning   = [];
wv_filter = [];
sclk      = [];
vr        = [];
obs_id_short = '';
vr_latest    = false;
sclk_ignore  = false;
no_dusty  = false;
no_icy    = false;
lownoise = false;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'BINNING'
                binning = varargin{i+1};
                if ischar(binning)
                    binning = str2num(binnig);
                end
            case 'WAVELENGTH_FILTER'
                wv_filter = varargin{i+1};
                 if ischar(wv_filter)
                    wv_filter = str2num(wv_filter);
                 end
            case 'SCLK'
                sclk = varargin{i+1};
                if ischar(sclk)
                    if strcmpi(sclk,'ignore')
                        sclk = [];
                        sclk_ignore = true;
                    else
                        sclk = str2num(sclk);
                    end
                end
            case 'VERSION'
                vr = varargin{i+1};
                if isnumeric(vr)

                elseif ischar(vr)
                    if strcmpi(vr,'latest')
                        vr = ''; vr_latest = true;
                    elseif ~isempty(regexpi(vr,'\d{1}','ONCE'))
                        vr = str2num(vr);
                    else
                        error('given version is not supported, only scalar single degit or "latest"');
                    end
                else
                    error('given version is not supported, only scalar single degit or "latest"');
                end

            case 'OBS_ID_SHORT'
                obs_id_short = varargin{i+1};

            case 'NO_ICY'
                no_icy = varargin{i+1};
            case 'NO_DUSTY'
                no_dusty = varargin{i+1};
            case 'LOWNOISE'
                lownoise = varargin{i+1};

            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

propADRVSPtr = crism_create_propADRVSbasename();
if ~isempty(binning), propADRVSPtr.binning = binning; end
if ~isempty(wv_filter), propADRVSPtr.wavelength_filter = wv_filter; end
if ~isempty(vr), propADRVSPtr.version = vr; end
if ~isempty(obs_id_short), propADRVSPtr.obs_id_short = obs_id_short; end
if ~isempty(sclk), propADRVSPtr.sclk = sclk; end

%%

[ADRVSdataList] = crism_get_ADRVSdata(propADRVSPtr);%,'Dwld',dwld);
if vr_latest
    % select the latest versions if vr='latest' is set
    [ADRVSdataList,idxes_latest] = crism_select_ADRVSdata_latest_version(ADRVSdataList);
end
if sclk_ignore
    % the data only different in psclk are same. 
    [ADRVSdataList,idxes_selected] = crism_get_ADRVSdata_psclk_ignored(ADRVSdataList);
end

if no_icy
    is_not_icy = ([ADRVSdataList.is_icy]==0);
    ADRVSdataList = ADRVSdataList(is_not_icy);
end

if no_dusty
    is_not_dusty = ([ADRVSdataList.is_dusty]==0);
    ADRVSdataList = ADRVSdataList(is_not_dusty);
end

if lownoise
    is_lownoise = ([ADRVSdataList.lownoise]==1);
    ADRVSdataList = ADRVSdataList(is_lownoise);
end

end
