function [edr_rootsubpath] = get_crism_pds_mro_path_edr(yyyy_doy)
% [edr_rootsubpath] = get_crism_pds_mro_path_edr(yyyy_doy)
%   locate the public pds path for EDR depending on yyyy_doy
% Input parameters
%   yyyy_doy: string, year and doy of the year
% Output parameters
%   edr_rootsubpath: string, path to the data in yyyy_doy, like
%       'mro-m-crism-2-edr-v1/mrocr_00xx/'
%       xx could be {'01','02',...}
%
% the information below is from 
% pds-geosciences.wustl.edu/missions/mro/crism.htm
%
% MROCR_0001	Sept. 27, 2006 - Dec. 31, 2007*
% MROCR_0002	Jan. 1, 2008 - Aug. 8, 2008*
% MROCR_0003	Aug. 9, 2008 - Aug. 8, 2010*
% MROCR_0004	Aug. 9, 2010 - Aug. 8, 2011
% MROCR_0005	Aug. 11, 2011 - Aug. 3, 2012
% MROCR_0006	Sept. 14, 2012 - Aug. 8, 2013
% MROCR_0007	Aug. 9, 2013 - Aug. 8, 2014
% MROCR_0008	Aug. 9, 2014 - Nov. 8, 2015
% MROCR_0009	Nov. 9, 2015 - Nov. 8, 2016
% MROCR_0010	Nov. 9, 2016 - Nov. 8, 2017
% MROCR_0011	Nov. 9, 2017 - Aug. 8, 2018

range_mat = [
    [datetime('Sep 27, 2006') datetime('Dec 31, 2007')];
    [datetime('Jan 1, 2008')  datetime('Aug 8, 2008')];
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

root_subfolder = 'mro-m-crism-2-edr-v1/';
folder_func = @(x) sprintf('mrocr_00%02d',x);

[edr_rootsubpath] = get_crism_pds_mro_path(...
    yyyy_doy,range_mat,root_subfolder,folder_func);

end