function [mtr3_rootsubpath] = get_crism_pds_mro_path_mtr3(yyyy_doy)
% [mtr3_rootsubpath] = get_crism_pds_mro_path_mtr3(yyyy_doy)
%   locate the public pds path for MTRDR depending on yyyy_doy
% Input parameters
%   yyyy_doy: string, year and doy of the year
% Output parameters
%   mtr3_rootsubpath: string, path to the data in yyyy_doy, like
%       'mro-m-crism-5-rdr-mptargeted-v1/mrocr_21xx/'
%       xx could be {'01','02',...}
%
% the information below is from 
% pds-geosciences.wustl.edu/missions/mro/crism.htm
%
% MROCR_4001	Sept. 30, 2006 - May 21, 2012


range_mat = [
    [datetime('Sep 30, 2006') datetime('May 21, 2012')];
];

root_subfolder = 'mro-m-crism-5-rdr-mptargeted-v1';
folder_func = @(x) sprintf('mrocr_40%02d',x);

[mtr3_rootsubpath] = get_crism_pds_mro_path(...
    yyyy_doy,range_mat,root_subfolder,folder_func);

end