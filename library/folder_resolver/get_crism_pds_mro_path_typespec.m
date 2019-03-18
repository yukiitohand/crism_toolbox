function [typespec_rootsubpath] = get_crism_pds_mro_path_typespec()
% [typespec_rootsubpath] = get_crism_pds_mro_path_typespec()
%   locate the public pds path for CRISM Type spectra
% Input parameters
%   yyyy_doy: string, year and doy of the year
% Output parameters
%   typespec_rootsubpath: string, path to the data,
%        'mro-m-crism-4-typespec-v1/mrocr_8001/'
%
% the detail information is at
% pds-geosciences.wustl.edu/missions/mro/crism.htm

typespec_rootsubpath = 'mro-m-crism-4-typespec-v1/mrocr_8001/';

end