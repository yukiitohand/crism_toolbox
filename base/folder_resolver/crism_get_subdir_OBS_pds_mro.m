function [subdir] = crism_get_subdir_OBS_pds_mro(yyyy_doy,base_dir,data_type)
% [subdir] = crism_get_subdir_OBS_pds_mro(yyyy_doy,base_dir,data_type)
%  get subdir for pds_mro system that can be used for an input of 
%  pds_downloader.m
%  INPUTS
%    yyyy_doy: string, year and day of the year
%    base_dir: string, subfolder following after yyyy_doy
%    data_type: data type {'ter','mtr','trr','ddr','edr'}
%  OUTPUT
%    subdir: string, something like
%     'mro-m-crism-3-rdr-targeted-v1/mrocr_2104/trdr/[yyyy_doy]/[base_dir]'
%         

if ~isempty(yyyy_doy)
    [yyyy,~] = dec_yyyy_doy(yyyy_doy);
    yyyy_str = num2str(yyyy);
end
switch lower(data_type)
    case 'ter'
        [subdir] = get_crism_pds_mro_path_ter3(yyyy_doy);
        subdir = joinPath(subdir,'ter',yyyy_str,yyyy_doy,lower(base_dir));
    case 'mtr'
        [subdir] = get_crism_pds_mro_path_mtr3(yyyy_doy);
        subdir = joinPath(subdir,'mtrdr',yyyy_str,yyyy_doy,lower(base_dir));
    case 'trr'
        [subdir] = get_crism_pds_mro_path_trr3(yyyy_doy);
        subdir = joinPath(subdir,'trdr',yyyy_str,yyyy_doy,lower(base_dir));
    case 'ddr'
        [subdir] = get_crism_pds_mro_path_ddr(yyyy_doy);
        subdir = joinPath(subdir,'ddr',yyyy_str,yyyy_doy,lower(base_dir));
    case 'edr'
        [subdir] = get_crism_pds_mro_path_edr(yyyy_doy);
        subdir = joinPath(subdir,'edr',yyyy_str,yyyy_doy,lower(base_dir));
    case 'glt'
        [subdir] = get_crism_pds_mro_path_ddr(yyyy_doy);
        subdir = joinPath(subdir,'glt',yyyy_str,yyyy_doy,lower(base_dir));
    case 'edr_misc'
        [subdir] = get_crism_pds_mro_path_edr_latest();
        subdir = joinPath(subdir,lower(base_dir));
    case 'trr_misc'
        [subdir] = get_crism_pds_mro_path_trr_latest();
        subdir = joinPath(subdir,lower(base_dir));
    otherwise
        error('Undefined data type %s.',data_type);
end


end