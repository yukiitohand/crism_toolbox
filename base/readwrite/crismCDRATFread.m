function [atf] = crismCDRATFread(yyyy_doy,sensor_id,varargin)

global localCRISM_PDSrootDir

crism_pds_archiveURL = 'utopia.jhuapl.edu/flight/crism_pds_archive/';
localrootDir = localCRISM_PDSrootDir;
dwld = 0;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'CRISM_PDS_ARCHIVE_URL'
                crism_pds_archiveURL = varargin{i+1};
            case 'LOCALROOTDIR'
                localrootDir = varargin{i+1};
            case 'DOWNLOAD'
                dwld=varargin{i+1};
        end
    end
end
    
local_dir = fullfile(localrootDir,crism_pds_archiveURL);


switch upper(sensor_id)
    case 'L'
        sensor_acro = 'IR';
    case 'S'
        sensor_acro = 'VN';
    otherwise
        error('Undefined sensor_id %s.',sensor_id);
end


basenamePtr = ['(ATF_' sensor_acro '_' yyyy_doy '_11)'];
remote_subdir = fullfile('edr','CDR', yyyy_doy, 'ATF');
dirpath = fullfile(local_dir,remote_subdir);

[basename] = readDownloadBasename_v2(basenamePtr,dirpath,remote_subdir,varargin{:});

if ~isempty(basename)
    lblfpath = fullfile(dirpath,[basename '.LBL']);
    tabfpath = fullfile(dirpath,[basename '.TAB']);
    lbl = crismlblread(lblfpath);
    tab = crismTABread(tabfpath,lbl);
    atf = [];
    atf.tab = tab;
    atf.lbl = lbl;
else
    atf = [];
end
            
end