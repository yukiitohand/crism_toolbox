function [spclib_crismTABColle] = readCRISMspclibTABCollection(varargin)
% [spclib_crismTABColle] = readCRISMspclibTABCollection(varargin)
%  read all spectra of the CRISM spectral library stored in PDS .TAB format.
%  Output Parameters
%    spclib_crismTABColle = struct having fields below
%     'product_id'             : 'PRODUCT_ID' in TAB
%     'product_name'           : 'PRODUCT_NAME' in TAB
%     'specimen_name'          : 'MRO_SPECIMEN_NAME' in TAB
%     'specimen_desc'          : 'MRO_SPECIMEN_DESC' in TAB
%     'specimen_class_name'    : 'MRO_SPECIMEN_CLASS_NAME' in TAB
%     'wavelength'             : array of the wavelength
%     'wavelength_unit'        : tab.colinfo_names.WAVELENGTH.UNIT (in TABLE Object in TAB)
%     'reflectance'            : array of the reflectance
%     'column_name_reflectance': column name for the reflectance
%     'instrument_id'          : 'INSTRUMENT_ID' in TAB
%     'instrument_name'        : 'INSTRUMENT_NAME' in TAB
%     'instrument_host_name'   : 'INSTRUMENT_HOST_NAME' in TAB
%     'subfolder'              : folder where the file is like
%                                'mrocr_90xx/.*'
%     'filename'               : filename of TAB file
%  Optional Parameters
%    'DIR' : root directory of the library
%       (default) crism_env_vars.dir_crismTypeLib
%       path to the directory where 'mrocr_90xx' is saved.
%    'VERBOSE' : show progress or not. (default) false
%    'CLEAR_CACHEFILE_SPCLIB' : 
%      whether or not to clear a cache file for spclib_crismTABColle
%      (default) false

global crism_env_vars

dir_CRISMspclibTABColle = crism_env_vars.dir_CRISMspclibTABCollection;

verbose = false;
clearcspclib = false;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'DIR'
                dir_CRISMspclibTABColle = varargin{i+1};
            case 'VERBOSE'
                verbose = varargin{i+1};
            case 'CLEAR_CACHEFILE_SPCLIB'
                clearcspclib = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end

dir_CRISMspclibTABColle_data = fullfile(dir_CRISMspclibTABColle,'mrocr_90xx','data');

if ~exist(dir_CRISMspclibTABColle_data,'dir')
    error('"%s" does not exist.',dir_CRISMspclibTABColle_data);
end

cachefile_spclib = joinPath(dir_CRISMspclibTABColle_data,'spclib_crismTABColle.mat');
if ~clearcspclib && exist(cachefile_spclib,'file')
    % load cache file if it exists and don't update the cache
    load(cachefile_spclib,'spclib_crismTABColle');
else

    [Files_struct] = walk(dir_CRISMspclibTABColle_data);

    file_notisdir = ~logical([Files_struct.isdir]);
    file_istab = regexpi({Files_struct.name},'.*\.tab','ONCE');
    file_istab = cellfun(@(x) ~isempty(x),file_istab);

    tab_files = Files_struct(and(file_notisdir,file_istab));
    ptrn_subfolder = '^.*(?<subfolder>mrocr_90xx/.*)$';

    L = length(tab_files);
    spclib_crismTABColle = struct(...
        'product_id'             , repmat({''},[L,1]),...
        'product_name'           , repmat({''},[L,1]),...
        'specimen_name'          , repmat({''},[L,1]),...
        'specimen_desc'          , repmat({''},[L,1]),...
        'specimen_class_name'    , repmat({''},[L,1]),...
        'wavelength'             , repmat({''},[L,1]),...
        'wavelength_unit'        , repmat({''},[L,1]),...
        'reflectance'            , repmat({''},[L,1]),...
        'column_name_reflectance', repmat({''},[L,1]),...
        'instrument_id'          , repmat({''},[L,1]),...
        'instrument_name'        , repmat({''},[L,1]),...
        'instrument_host_name'   , repmat({''},[L,1]),...
        'subfolder'              , repmat({''},[L,1]),...
        'filename'               , repmat({''},[L,1])...
        );

    if verbose
        textprogressbar('Reading files: ');
    end

    for i=1:L
        % show progress
        if verbose
            textprogressbar(floor(i/L*100));
        end
        fpath = tab_files(i).path;
        mtch_subfolder = regexpi(tab_files(i).folder,ptrn_subfolder,'names');
        [tab,lbl] = crismspclibTABread(fpath);
        spclib_crismTABColle(i).product_id    = lbl.PRODUCT_ID;
        if isfield(lbl,'PRODUCT_NAME')
            spclib_crismTABColle(i).product_name  = lbl.PRODUCT_NAME;
        end
        spclib_crismTABColle(i).specimen_name        = lbl.MRO_SPECIMEN_NAME;
        spclib_crismTABColle(i).specimen_desc        = lbl.MRO_SPECIMEN_DESC;
        spclib_crismTABColle(i).specimen_class_name  = lbl.MRO_SPECIMEN_CLASS_NAME;
        spclib_crismTABColle(i).wavelength           = [tab.data.WAVELENGTH]';
        spclib_crismTABColle(i).wavelength_unit      = tab.colinfo_names.WAVELENGTH.UNIT;
        spclib_crismTABColle(i).instrument_id        = lbl.INSTRUMENT_ID;
        spclib_crismTABColle(i).instrument_name      = lbl.INSTRUMENT_NAME;
        spclib_crismTABColle(i).instrument_host_name = lbl.INSTRUMENT_HOST_NAME;
        if isfield(tab.data,'ABSOLUTE')
            spclib_crismTABColle(i).column_name_reflectance...
                = tab.colinfo_names.ABSOLUTE.NAME;
            spclib_crismTABColle(i).reflectance   = [tab.data.ABSOLUTE]';
        elseif isfield(tab.data, 'ABSOLUTE_REFLECTANCE')
            spclib_crismTABColle(i).column_name_reflectance...
                = tab.colinfo_names.ABSOLUTE_REFLECTANCE.NAME;
            spclib_crismTABColle(i).reflectance   = [tab.data.ABSOLUTE_REFLECTANCE]';
        elseif isfield(tab.data, 'REFLECTANCE')
            spclib_crismTABColle(i).column_name_reflectance...
                = tab.colinfo_names.REFLECTANCE.NAME;
            spclib_crismTABColle(i).reflectance   = [tab.data.REFLECTANCE]';
        elseif isfield(tab.data, 'ABSOLUTE_REFLECTIVITY')
            spclib_crismTABColle(i).column_name_reflectance...
                = tab.colinfo_names.ABSOLUTE_REFLECTIVITY.NAME;
            spclib_crismTABColle(i).reflectance   = [tab.data.ABSOLUTE_REFLECTIVITY]';
        else
            error('check data %s',fpath);
        end
        spclib_crismTABColle(i).subfolder = mtch_subfolder.subfolder;
        spclib_crismTABColle(i).filename  = tab_files(i).name;
        % spclib_crismTABColle(i).lbl       = lbl;
    end

    if verbose
        textprogressbar('done');
    end
    
    % save cachefile
    save(cachefile_spclib,'spclib_crismTABColle');
end
    
end