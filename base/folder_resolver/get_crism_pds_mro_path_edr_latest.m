function [edr_rootsubpath] = get_crism_pds_mro_path_edr_latest()
% [edr_rootsubpath] = get_crism_pds_mro_path_edr_latest()
%   locate the public pds path for latest edr branch
% Input parameters
%   yyyy_doy: string, year and doy of the year
% Output parameters
%   edr_rootsubpath: string, path to the data,
%        'mro-m-crism-2-edr-v1/mrocr_0011/'
%
% the detail information is at
% pds-geosciences.wustl.edu/missions/mro/crism.htm

edr_rootsubpath = 'mro-m-crism-2-edr-v1/mrocr_0015/';

end