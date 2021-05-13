function [] = makeIndexOBSID2YYYY_DOY_OTT(varargin)
% [] = makeIndexOBSID2YYYY_DOY_OTT(varargin)
% make index file that shows the map from OBSID to YYYY_DOY. Save the index
% file to current directory. 
%
% The file name is 'LUT_OBSID2YYYY_DOY.mat' saved in the same folder as
% this function.
% Saved file has a struct named 'LUT_OBSID2YYYY_DOY', where, field names are
% (obs class type[3 characters])(obs id[8 characters of hex numbers]) such
% as 'FRT000245DD'.
%   
%
%   Inputs:
%   Optional Parameters

dwld = 0;
overwrite = 0;
outfile = '';

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'OVERWRITE'
                overwrite = varargin{i+1};
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

[subdir_local]  = crism_get_subdir_OBS_local('','EXTRAS/OTT/','edr_misc');
[subdir_remote] = crism_get_subdir_OBS_remote('','extras/ott/','edr_misc');

function_path = mfilename('fullpath');

fpath = joinPath(function_path,'LUT_OBSID2YYYY_DOY.mat');

if exist(fpath,'file') && ~overwrite
    load(fpath,'LUT_OBSID2YYYY_DOY');
else

    LUT_OBSID2YYYY_DOY = [];  
    prop = create_propOTTbasename();
    ptrn = get_basenameOTT_fromProp(prop); 
    % basenames = readDownloadBasename_v3(ptrn,dirpath_OTT,remote_subdir,varargin{:});
    
    [basenames] = crism_readDownloadBasename(basenameCDRPtrn,...
            subdir_local,subdir_remote,dwld,'Force',force,'Out_File',outfile);
    
    for i=1:length(basenames)
        bname = basenames{i};
        fprintf('Entering %s...\n',bname);
        OBSIDdata = CRISMdata(bname,dirpath_OTT);
        OBSIDdata.readTAB();
        
        % EDR/2009_001/ICL000104A3/ICL000104A3_07_SP199L_EDR0.IMG
        for j=1:length(OBSIDdata.tab.data)
            record = OBSIDdata.tab.data(j);
            obs_id = record.OBSERVATION_ID;
            if ~strcmpi(obs_id,'N/A')
                obs_id = hex2dec(obs_id);
                if obs_id>length(LUT_OBSID2YYYY_DOY) || isempty(LUT_OBSID2YYYY_DOY{obs_id})
                    ptrn2 = ['[^/]+/(?<yyyy_doy>[\d]{4}_[\d]{3})/(?<folder_name>[a-zA-Z]{3}[0-9a=zA-Z]{8})/' record.PRODUCT_ID];
                    matching = regexpi(record.FILE_SPECIFICATION_NAME,ptrn2,'names');

                    if ~isempty(matching)
                        yyyy_doy = matching.yyyy_doy;
                        folder_name = matching.folder_name;
                        LUT_OBSID2YYYY_DOY.(folder_name) = yyyy_doy;
                    end
                end
            end
        end
    end

    save(fpath,'LUT_OBSID2YYYY_DOY');
end

end