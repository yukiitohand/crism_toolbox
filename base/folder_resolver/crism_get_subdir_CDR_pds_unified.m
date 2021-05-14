function [subdir] = get_subdir_CDR_pds_unified(acro,cdr_folder_type,yyyy_doy)
% [subdir] = get_subdir_CDR_pds_unified(acro,cdr_folder_type,yyyy_doy)
%  get subdir for pds_unified folder system
%  INPUTS
%    acro: two character acronym for the CDR product
%    cdr_folder_type: cdr_folder_type {1,2}
%    yyyy_doy: string, year and day of the year
%  OUTPUT
%    subdir, string, something like
%         'edr/CDR/[yyyy_doy]/[acro]' or 'edr/CDR/[acro]'


switch cdr_folder_type
    case 1
        subdir = joinPath('edr/CDR/',yyyy_doy,acro);
    case 2
        subdir = joinPath('edr/CDR/',acro);
    case 3
        error('folder_type==3 is not defined in utopia system.');
    otherwise
        error('Undefined data type %s.',data_type);
end

    
end