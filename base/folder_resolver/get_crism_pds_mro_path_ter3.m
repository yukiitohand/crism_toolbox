function [ter3_rootsubpath] = get_crism_pds_mro_path_ter3(yyyy_doy)
% [ter3_rootsubpath] = get_crism_pds_mro_path_ter3(yyyy_doy)
%   locate the public pds path for TER depending on yyyy_doy
% Input parameters
%   yyyy_doy: string, year and doy of the year
% Output parameters
%   ter3_rootsubpath: string, path to the data in yyyy_doy, like
%       'mro-m-crism-4-rdr-targeted-v1/mrocr_60xx/'
%       xx could be {'01','02',...}
%
% the information below is from 
% pds-geosciences.wustl.edu/missions/mro/crism.htm
%
% MROCR_4001	Sept. 30, 2006 - May 21, 2012


range_mat = [
    [datetime('Sep 30, 2006') datetime('May 21, 2012')];
];

root_subfolder = 'mro-m-crism-4-rdr-targeted-v1';
folder_func = @(x) sprintf('mrocr_60%02d',x);

[ter3_rootsubpath] = get_crism_pds_mro_path(...
    yyyy_doy,range_mat,root_subfolder,folder_func);

end