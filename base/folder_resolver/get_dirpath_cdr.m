function [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname] = get_dirpath_cdr(basenameCDR,varargin)
% [dirfullpath_local,subdir_local,subdir_remote,yyyy_doy,dirname] = get_dirpath_cdr(basenameCDR,varargin)
%  get directory path of the given basename of the CDR file. The file could
%  be downloaded using an option
%  Inputs
%   basenameCDR: basename of the CDR file
%  Outputs
%   dirfullpath_local: full local directroy path of the CDR file
%   subdir_local     : subdirectory path
%   subdir_remote    : subdirectory for the remote server
%   yyyy_doy    : yyyy_doy, if applicable,
%   dirname: directory name, two character acronym.
%  Optional Parameters (passed onto get_dirpath_cdr_fromProp)
%      'DWLD','DOWNLOAD' : if download the data or not, 2: download, 1:
%                         access an only show the path, 0: nothing
%                         (default) 0
%      'OUT_FILE'       : path to the output file
%                         (default) ''
%      'Force'          : binary, whether or not to force performing
%                         pds_downloader. (default) false

propCDR = getProp_basenameCDR(basenameCDR);
[dirfullpath_local,subdir_local,subdir_remote,~,...
    acro,~,yyyy_doy] = get_dirpath_cdr_fromProp(propCDR,varargin{:});

dirname = acro;

% global crism_env_vars
% localCATrootDir = crism_env_vars.localCATrootDir;
% localrootDir = crism_env_vars.localCRISM_PDSrootDir;
% local_fldsys = crism_env_vars.local_fldsys;
% url_local_root = crism_env_vars.([local_fldsys '_URL']);
% 
% yyyy_doy = '';
%     
% if isCDR4(basenameCDR)
%     propCDR = getProp_basenameCDR4(basenameCDR);
% elseif isCDR6(basenameCDR)
%     propCDR = getProp_basenameCDR6(basenameCDR);
% else
%     error('basename %s is not valid',basenameCDR);
% end
% 
% acro = propCDR.acro_calibration_type;
% folder_type = assessCDRForderType(acro);
%     
% switch folder_type
%     case 1
%         sclk = propCDR.sclk;
%         s = sclk/86400; % 86400=24*3600 (1 day)
%         ds = floor(s);
%         yyyy_doy_shifted = shift_yyyy_doy('1980_001',ds); % estimate yyyy_doy
%         if (s-ds)<0.5
%             init_move_coef = 1;
%         else
%             init_move_coef = -1;
%         end
%         j=0;
%         exist_flg=0;
%         while (~exist_flg && (j<5))
%             shift_day = j*(-1)^(j)*init_move_coef;
%             yyyy_doy_shifted = shift_yyyy_doy(yyyy_doy_shifted,shift_day);
%             subdir_remote = get_subdir_CDR_remote(acro,folder_type,yyyy_doy_shifted);
%             subdir_local = get_subdir_CDR_local(acro,folder_type,yyyy_doy_shifted);
%             [basenameCDRtmp] = readDownloadBasename_v3(basenameCDR,subdir_local,subdir_remote,varargin{:});
%             if ~isempty(basenameCDRtmp)
%                 exist_flg = 1;
%             else
%                 j=j+1;
%             end
%         end
%         if exist_flg
%             yyyy_doy = yyyy_doy_shifted;
%             dirpath_local = joinPath(localrootDir,url_local_root,subdir_local);
%         else
%             subdir_local = '';
%         end
%     case 2
%         subdir_remote = get_subdir_CDR_remote(acro,folder_type,'');
%         subdir_local = get_subdir_CDR_local(acro,folder_type,'');
%         dirpath_local = joinPath(localrootDir,url_local_root,subdir_local);
% %         [basenameCDR] = readDownloadBasename_v3(basenameCDR,dirpath_cdr,remote_subdir,varargin{:});
%     case 3
%         dirpath_local = joinPath(localCATrootDir,'CAT_ENVI/aux_files/',acro);
%         subdir_local = '';
%         subdir_remote = '';
%     otherwise
%         error('folder_type==%d is not defined',folder_type);
% end
% 
% dirname = acro;

end