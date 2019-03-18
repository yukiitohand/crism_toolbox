function [dirfullpath_local,subdir_local,subdir_remote,basenameCDR,...
    acro,folder_type,yyyy_doy] = get_dirpath_cdr_fromProp(propCDR,varargin)
% [dirfullpath_local,subdir_local,subdir_remote,basenameCDR] = get_dirpath_cdr_fromProp(propCDR,varargin)
%  get directory path of the given basename of the CDR file. The file could
%  be downloaded using an option
%  Inputs
%   propCDR: basename of the CDR file
%  Outputs
%   dirfullpath_local: full local directroy path of the CDR file
%   subdir_local     : subdirectory path
%   subdir_remote    : subdirectory for the remote server
%   basenameCDR: basename of the matched file
%  Optional Parameters
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false

global crism_env_vars
localCATrootDir = crism_env_vars.localCATrootDir;
localrootDir = crism_env_vars.localCRISM_PDSrootDir;
url_local_root = crism_env_vars.url_local_root;

dwld = 0;
force = 0;
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
            otherwise
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end


acro = propCDR.acro_calibration_type;
folder_type = assessCDRForderType(acro);
yyyy_doy = '';
    
switch folder_type
    case 1
        % sclk = sclkfromCDRbasename(basenameCDR); % sclk is read from the basename
        sclk = propCDR.sclk;
        s = sclk/86400; % 86400=24*3600 (1 day)
        ds = floor(s);
        yyyy_doy_shifted = shift_yyyy_doy('1980_001',ds); % estimate yyyy_doy
        if (s-ds)<0.5
            init_move_coef = 1;
        else
            init_move_coef = -1;
        end
        j=0;
        exist_flg=0;
        while (~exist_flg && (j<5))
            shift_day = j*(-1)^(j)*init_move_coef;
            yyyy_doy_shifted = shift_yyyy_doy(yyyy_doy_shifted,shift_day);
            subdir_remote = get_subdir_CDR_remote(acro,folder_type,yyyy_doy_shifted);
            subdir_local = get_subdir_CDR_local(acro,folder_type,yyyy_doy_shifted);
            dirfullpath_local = joinPath(localrootDir,url_local_root,subdir_local);
            [basenameCDRPtrn] = get_basenameCDR_fromProp(propCDR);
            [basenameCDR] = crism_readDownloadBasename(basenameCDRPtrn,...
                subdir_local,subdir_remote,dwld,'Force',force,'Out_File',outfile);
            if ~isempty(basenameCDR)
                exist_flg = 1;
            else
                j=j+1;
            end
        end
        if ~exist_flg
            dirfullpath_local=''; subdir_remote=''; basenameCDR='';
            warning('%s cannot be found in the local directory',basenameCDRPtrn);
        end
    case 2
        subdir_remote = get_subdir_CDR_remote(acro,folder_type,'');
        subdir_local = get_subdir_CDR_local(acro,folder_type,'');
        dirfullpath_local = joinPath(localrootDir,url_local_root,subdir_local);
        [basenameCDRPtrn] = get_basenameCDR_fromProp(propCDR);
        [basenameCDR] = crism_readDownloadBasename(basenameCDRPtrn,...
            subdir_local,subdir_remote,dwld,'Force',force,'Out_File',outfile);
    case 3
        subdir_local = joinPath('CAT_ENVI/aux_files/CDRs/',acro);
        dirfullpath_local = joinPath(localCATrootDir,subdir_local);
        subdir_remote = '';
        [basenameCDRPtrn] = get_basenameCDR_fromProp(propCDR);
        fnamelist = dir(dirfullpath_local);
        [basenameCDR] = extractMatchedBasename_v2(basenameCDRPtrn,[{fnamelist.name}]);
        if ischar(basenameCDR), basenameCDR = {basenameCDR}; end
        if dwld == -1
            if ~isempty(outfile)
                fp = fopen(outfile,'a');
            end
            if ~isempty(basesnameCDR)
                for j=1:length(basenameCDR)
                    subpath = joinPath(subdir_local,basenameCDR{j});
                    if ~isempty(outfile)
                        fprintf(fp,'%s\n',subpath);
                    end
                    fprintf('%s\n',subpath);
                end
            end
            if ~isempty(outfile)
                fclose(fp);
            end
        elseif dwld==1
            error('dwld==1 is not supported for folder_type=3');
        end
    otherwise
        error('not defined case');
end

end