function [subdir] = crism_get_subdir_CDR_pds_mro(acro,cdr_folder_type,yyyy_doy)
% [subdir] = crism_get_subdir_CDR_pds_mro(acro,cdr_folder_type,yyyy_doy)
%  get subdir for jhuapl pds mro server that can be used for an input of 
%  pds_downloader.m
%  INPUTS
%    acro: two character acronym for the CDR product
%    cdr_folder_type: cdr_folder_type {1,2}
%    yyyy_doy: string, year and day of the year
%  OUTPUT
%    subdir: string, something like
%     'mro-m-crism-2-edr-v1/mrocr_00xx/cdr/[yyyy_doy]/[acro]' or
%     'mro-m-crism-2-edr-v1/mrocr_0001/cdr/[acro]' or

if ~isempty(yyyy_doy)
    [yyyy,~] = dec_yyyy_doy(yyyy_doy);
    yyyy_str = num2str(yyyy);
end

switch cdr_folder_type
    case 1
        [subdir] = get_crism_pds_mro_path_cdr_type1(yyyy_doy);
        subdir = fullfile(subdir,'cdr',yyyy_str,yyyy_doy,acro);
    case 2
        [subdir] = get_crism_pds_mro_path_cdr_type2();
        subdir = fullfile(subdir,'cdr',acro);
    case 3
        error('folder_type==3 is not defined in pds_mro system.');
    otherwise
        error('Undefined data type %s.',data_type);
end

    
end