function [trr_rootsubpath] = get_crism_pds_mro_path_trr_latest()
% [trr_rootsubpath] = get_crism_pds_mro_path_edr_latest()
%   locate the public pds path for latest trdr branch
% Input parameters
%   yyyy_doy: string, year and doy of the year
% Output parameters
%   trr_rootsubpath: string, path to the data,
%        'mro-m-crism-3-rdr-targeted-v1/mrocr_2116/'
%
% the detail information is at
% pds-geosciences.wustl.edu/missions/mro/crism.htm

trr_rootsubpath = fullfile('mro-m-crism-3-rdr-targeted-v1','mrocr_2116');

end