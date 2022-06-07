function [trr3_rootsubpath] = get_crism_pds_mro_path_trr3(yyyy_doy)
% [trr3_rootsubpath] = get_crism_pds_mro_path_trr3(yyyy_doy)
%   locate the public pds path for TRR3 depending on yyyy_doy
% Input parameters
%   yyyy_doy: string, year and doy of the year
% Output parameters
%   trr3_rootsubpath: string, path to the data in yyyy_doy, like
%       'mro-m-crism-3-rdr-targeted-v1/mrocr_21xx/'
%       xx could be {'01','02',...}
%
% the information below is from 
% pds-geosciences.wustl.edu/missions/mro/crism.htm
%
% MROCR_2101	Sep. 27, 2006 - Aug. 8, 2007
% MROCR_2102	Aug. 9, 2007 - Aug. 8, 2008
% MROCR_2103	Aug. 9, 2008 - Aug. 6, 2009
% MROCR_2104	Aug. 11, 2009 - Aug. 8, 2010
% MROCR_2105	Aug. 9, 2010 - Aug. 8, 2011
% MROCR_2106	Aug. 11, 2011 - Aug. 3, 2012
% MROCR_2107	Sep. 14, 2012 - Aug. 8, 2013
% MROCR_2108	Aug. 9, 2013 - Aug. 8, 2014
% MROCR_2109	Aug. 9, 2014 - Nov. 8, 2015
% MROCR_2110	Nov. 9, 2015 - Nov. 8, 2016
% MROCR_2111	Nov. 9, 2016 - Nov. 8, 2017
% MROCR_2112	Nov. 9, 2017 - Nov. 8, 2018
% MROCR_2113	Nov. 9, 2018 - Nov. 8, 2019
% MROCR_2114	Nov. 9, 2019 - Nov. 8, 2020
% MROCR_2115	Nov. 9, 2020 - Nov. 8, 2021
% MROCR_2116	Nov. 9, 2021 - Feb. 8, 2022


range_mat = [
    [datetime('Sep 27, 2006') datetime('Aug 8, 2007')];
    [datetime('Aug 9, 2007')  datetime('Aug 8, 2008')];
    [datetime('Aug 9, 2008')  datetime('Aug 6, 2009')];
    [datetime('Aug 11, 2009') datetime('Aug 8, 2010')];
    [datetime('Aug 9, 2010')  datetime('Aug 8, 2011')];
    [datetime('Aug 11, 2011') datetime('Aug 3, 2012')];
    [datetime('Sep 14, 2012') datetime('Aug 8, 2013')];
    [datetime('Aug 9, 2013')  datetime('Aug 8, 2014')];
    [datetime('Aug 9, 2014')  datetime('Nov 8, 2015')];
    [datetime('Nov 9, 2015')  datetime('Nov 8, 2016')];
    [datetime('Nov 9, 2016')  datetime('Nov 8, 2017')];
    [datetime('Nov 9, 2017')  datetime('Nov 8, 2018')];
    [datetime('Nov 9, 2018')  datetime('Nov 8, 2019')];
    [datetime('Nov 9, 2019')  datetime('Nov 8, 2020')];
    [datetime('Nov 9, 2020')  datetime('Nov 8, 2021')];
    [datetime('Nov 9, 2021')  datetime('Feb 8, 2022')];
];

root_subfolder = 'mro-m-crism-3-rdr-targeted-v1/';
folder_func = @(x) sprintf('mrocr_21%02d',x);

[trr3_rootsubpath] = get_crism_pds_mro_path(...
    yyyy_doy,range_mat,root_subfolder,folder_func);

end