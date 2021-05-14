function [basenameCDRmrb,propCDRmrb] = crism_searchCDRmrb(propCDRref,varargin)
% [basenameCDRmrb,propCDRmrb] = crism_searchCDRmrb(propCDRref,varargin)
%   find the most recent CDR by looking at sclk of the basename
%  Input Parameters
%    propCDRref: reference CDR property (version 4 or 6)
%  Optional Parameters
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false
%  Output Parameters
%    basenameCDRmrb: basename of the most recent CDR before the reference,
%                    empty if not found
%    propCDRmrb: property struct of the most recent CDR before the 
%                       reference, empty if not found

global crism_env_vars
localCATrootDir = crism_env_vars.localCATrootDir;

dwld = 0;
force = false;
outfile = '';
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case {'DWLD','DOWNLOAD'}
                dwld = varargin{i+1};
            case 'FORCE'
                force = varargin{i+1};
            case 'OUT_FILE'
                outfile = varargin{i+1};
        end
    end
end

acro = propCDRref.acro_calibration_type;
[folder_type] = assessCDRForderType(acro);

propCDR_search = propCDRref;
propCDR_search.sclk = '(?<sclk>[\d]{10})';
propCDR_search.partition = '(?<partition>[\d]{1})';
[basenameCDRPtrn] = get_basenameCDR_fromProp(propCDR_search);

propCDRmrb = [];
basenameCDRmrb = '';

switch folder_type
    case 1
        % sclk = sclkfromCDRbasename(basenameCDR); % sclk is read from the basename
        sclk = propCDRref.sclk;
        s = sclk/86400; % 86400=24*3600 (1 day)
        ds = floor(s);
        yyyy_doy_shifted = shift_yyyy_doy('1980_001',ds); % estimate yyyy_doy
        %yyyy_doy_shifted = shift_yyyy_doy(yyyy_doy_shifted,1);

        j=0;
        exist_flg=0;
        
        while (~exist_flg)
            % start looking from the one day ahead, just in case.
            
            subdir_remote = crism_get_subdir_CDR_remote(acro,folder_type,yyyy_doy_shifted);
            subdir_local  = crism_get_subdir_CDR_local(acro,folder_type,yyyy_doy_shifted);
            [basenameCDRList] = crism_readDownloadBasename(basenameCDRPtrn,...
                subdir_local,subdir_remote,dwld,'Force',force,'Out_File',outfile);
            % [basenameCDRList] = readDownloadBasename_v3(basenameCDRPtrn,dirpath_cdr,remote_subdir,varargin{:});
            [propCDRcandidates] = getProp_basenameCDRList(basenameCDRList,propCDRref.level);
            [propCDRmrb,idx_mrb,psclk_mrb] = find_psclk_mrb_fromCDRpropList(propCDRcandidates,propCDRref);
            if ~isempty(propCDRmrb)
                if iscell(basenameCDRList)
                    basenameCDRmrb = basenameCDRList{idx_mrb};
                elseif ischar(basenameCDRList)
                    basenameCDRmrb = basenameCDRList;
                else
                    error('Something wrong...');
                end
                exist_flg = 1;
            else
                yyyy_doy_shifted = shift_yyyy_doy(yyyy_doy_shifted,-1);
            end
        end
    case 2
        subdir_remote = crism_get_subdir_CDR_remote(acro,folder_type,'');
        subdir_local  = crism_get_subdir_CDR_local(acro,folder_type,'');
        [basenameCDRList] = crism_readDownloadBasename(basenameCDRPtrn,...
                subdir_local,subdir_remote,dwld,'Force',force,'Out_File',outfile);
        % [basenameCDRList] = readDownloadBasename_v3(basenameCDRPtrn,dirpath_cdr,remote_subdir,varargin{:});
        [propCDRcandidates] = getProp_basenameCDRList(basenameCDRList,propCDRref.level);
        [propCDRmrb,idx_mrb,psclk_mrb] = find_psclk_mrb_fromCDRpropList(propCDRcandidates,propCDRref);
        if iscell(basenameCDRList)
            basenameCDRmrb = basenameCDRList{idx_mrb};
        elseif ischar(basenameCDRList)
            basenameCDRmrb = basenameCDRList;
        else
            error('Something wrong...');
        end
    case 3
        subdir_local = joinPath('CAT_ENVI/aux_files/CDRs/',acro);
        dirfullpath_local = joinPath(localCATrootDir,subdir_local);
        subdir_remote = '';
        fnamelist = dir(dirfullpath_local);
        [basenameCDRList] = extractMatchedBasename_v2(basenameCDRPtrn,[{fnamelist.name}]);
        [propCDRcandidates] = getProp_basenameCDRList(basenameCDRList,propCDRref.level);
        [propCDRmrb,idx_mrb,psclk_mrb] = find_psclk_mrb_fromCDRpropList(propCDRcandidates,propCDRref);
        if iscell(basenameCDRList)
            basenameCDRmrb = basenameCDRList{idx_mrb};
        elseif ischar(basenameCDRList)
            basenameCDRmrb = basenameCDRList;
        else
            error('Something wrong...');
        end
    otherwise
        error('not defined case');
end


end

