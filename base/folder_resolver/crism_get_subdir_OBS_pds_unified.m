function [subdir] = crism_get_subdir_OBS_pds_unified(yyyy_doy,base_dir,data_type)
% [subdir] = crism_get_subdir_OBS_pds_unified(yyyy_doy,base_dir,fldsys,data_type)
%  get subdir for pds_unified folder system
%  INPUTS
%    yyyy_doy: string, year and day of the year
%    base_dir: string, subfolder following after yyyy_doy
%    data_type: data type {'ter','mtr','trr','ddr','edr'}
%  OUTPUT
%    subdir, string, something like
%         'trdr/TRDR/[yyyy_doy]/[base_dir]'


switch lower(data_type)
    case 'ter'
        [ subdir ] = fullfile('ter','TER',yyyy_doy,base_dir);
    case 'mtr'
        [ subdir ] = fullfile('mtrdr','MTRDR',yyyy_doy,base_dir);
    case 'trr'
        [ subdir ] = fullfile('trdr','TRDR',yyyy_doy,base_dir);
    case 'ddr'
        [ subdir ] = fullfile('ddr','DDR',yyyy_doy,base_dir);
    case 'edr'
        [ subdir ] = fullfile('edr','EDR',yyyy_doy,base_dir);
    case 'glt'
        [ subdir ] = fullfile('ddr','GLT',yyyy_doy,base_dir);
    otherwise
        error('Undefined data type %s.',data_type);
end

    
end