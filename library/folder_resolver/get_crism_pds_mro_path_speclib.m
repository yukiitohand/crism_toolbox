function [speclib_rootsubpath] = get_crism_pds_mro_path_speclib()
% [speclib_rootsubpath] = get_crism_pds_mro_path_speclib()
%   locate the public pds path for CRISM Type spectra
% Input parameters
%   yyyy_doy: string, year and doy of the year
% Output parameters
%   speclib_rootsubpath: string, path to the data,
%        'mro-m-crism-4-typespec-v1/mrocr_8001/'
%
% the detail information is at
% pds-geosciences.wustl.edu/missions/mro/crism.htm

speclib_rootsubpath = 'mro-m-crism-4-speclib-v1/mrocr_90xx/';

end