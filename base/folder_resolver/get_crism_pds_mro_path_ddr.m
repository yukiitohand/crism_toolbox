function [ddr_rootsubpath] = get_crism_pds_mro_path_ddr(yyyy_doy)
% [ddr_rootsubpath] = get_crism_pds_mro_path_ddr(yyyy_doy)
%   locate the public pds path for DDR depending on yyyy_doy
% Input parameters
%   yyyy_doy: string, year and doy of the year
% Output parameters
%   ddr_rootsubpath: string, path to the data in yyyy_doy, like
%       'mro-m-crism-6-ddr-v1/mrocr_10xx/'
%       xx could be {'01','02',...}
%
% the information below is from 
% pds-geosciences.wustl.edu/missions/mro/crism.htm
%
% MROCR_1001	Sept. 27, 2006 - Aug. 8, 2008
% MROCR_1002	Aug. 9, 2008 - Aug. 8, 2010
% MROCR_1003	Aug. 9, 2010 - Aug. 8, 2011
% MROCR_1004	Aug. 11, 2011 - Aug. 3, 2012
% MROCR_1005	Sept. 14, 2012 - Aug. 8, 2013
% MROCR_1006	Aug. 9, 2013 - Aug. 8, 2014
% MROCR_1007	Aug. 9, 2014 - Nov. 8, 2015
% MROCR_1008	Nov. 9, 2015 - Nov. 8, 2016
% MROCR_1009	Nov. 9, 2016 - Nov. 8, 2017
% MROCR_1010	Nov. 9, 2017 - Aug. 8, 2018


range_mat = [
    [datetime('Sep 27, 2006') datetime('Aug 8, 2008')];
    [datetime('Aug 9, 2008')  datetime('Aug 8, 2010')];
    [datetime('Aug 9, 2010')  datetime('Aug 8, 2011')];
    [datetime('Aug 11, 2011') datetime('Aug 3, 2012')];
    [datetime('Sep 14, 2012') datetime('Aug 8, 2013')];
    [datetime('Aug 9, 2013')  datetime('Aug 8, 2014')];
    [datetime('Aug 9, 2014')  datetime('Nov 8, 2015')];
    [datetime('Nov 9, 2015')  datetime('Nov 8, 2016')];
    [datetime('Nov 9, 2016')  datetime('Nov 8, 2017')];
    [datetime('Nov 9, 2017')  datetime('Aug 8, 2018')];
];

root_subfolder = 'mro-m-crism-6-ddr-v1/';
folder_func = @(x) sprintf('mrocr_10%02d',x);

[ddr_rootsubpath] = get_crism_pds_mro_path(...
    yyyy_doy,range_mat,root_subfolder,folder_func);

end