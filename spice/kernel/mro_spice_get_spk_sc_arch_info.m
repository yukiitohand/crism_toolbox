function [spk_arch_infostruct] = mro_spice_get_spk_sc_arch_info()

spk_arch_tbl = { ...
'cruise', '2005 AUG 12', '2006 MAR 10'; ...
'ab'   , '2006 MAR 10', '2006 SEP 12'; ...
'psp1' , '2006 SEP 12', '2007 JAN 01'; ...
'psp2' , '2007 JAN 01', '2007 APR 01'; ...
'psp3' , '2007 APR 01', '2007 JUL 01'; ...
'psp4' , '2007 JUL 01', '2007 OCT 01'; ...
'psp5' , '2007 OCT 01', '2008 JAN 01'; ...
'psp6' , '2008 JAN 01', '2008 APR 01'; ...
'psp7' , '2008 APR 01', '2008 JUL 01'; ...
'psp8' , '2008 JUL 01', '2008 OCT 01'; ...
'psp9' , '2008 OCT 01', '2009 JAN 01'; ...
'psp10', '2009 JAN 01', '2009 APR 01'; ...
'psp11', '2009 APR 01', '2009 JUL 01'; ...
'psp12', '2009 JUL 01', '2009 OCT 01'; ...
'psp13', '2009 OCT 01', '2010 JAN 01'; ...
'psp14', '2010 JAN 01', '2010 APR 01'; ...
'psp15', '2010 APR 01', '2010 JUL 01'; ...
'psp16', '2010 JUL 01', '2010 OCT 01'; ...
'psp17', '2010 OCT 01', '2011 JAN 01'; ...
'psp18', '2011 JAN 01', '2011 APR 01'; ...
'psp19', '2011 APR 01', '2011 JUL 01'; ...
'psp20', '2011 JUL 01', '2011 OCT 01'; ...
'psp21', '2011 OCT 01', '2012 JAN 01'; ...
'psp22', '2012 JAN 01', '2012 APR 01'; ...
'psp23', '2012 APR 01', '2012 JUL 01'; ...
'psp24', '2012 JUL 01', '2012 OCT 01'; ...
'psp25', '2012 OCT 01', '2013 JAN 01'; ...
'psp26', '2013 JAN 01', '2013 APR 01'; ...
'psp27', '2013 APR 01', '2013 JUL 01'; ...
'psp28', '2013 JUL 01', '2013 OCT 01'; ...
'psp29', '2013 OCT 01', '2014 JAN 01'; ...
'psp30', '2014 JAN 01', '2014 APR 01'; ...
'psp31', '2014 APR 01', '2014 JUL 01'; ...
'psp32', '2014 JUL 01', '2014 OCT 01'; ...
'psp33', '2014 OCT 01', '2015 JAN 01'; ...
'psp34', '2015 JAN 01', '2015 APR 01'; ...
'psp35', '2015 APR 01', '2015 JUL 01'; ...
'psp36', '2015 JUL 01', '2015 OCT 01'; ...
'psp37', '2015 OCT 01', '2016 JAN 01'; ...
'psp38', '2016 JAN 01', '2016 APR 01'; ...
'psp39', '2016 APR 01', '2016 JUL 01'; ...
'psp40', '2016 JUL 01', '2016 OCT 01'; ...
'psp41', '2016 OCT 01', '2017 JAN 01'; ...
'psp42', '2017 JAN 01', '2017 APR 01'; ...
'psp43', '2017 APR 01', '2017 JUL 01'; ...
'psp44', '2017 JUL 01', '2017 OCT 01'; ...
'psp45', '2017 OCT 01', '2018 JAN 01'; ...
'psp46', '2018 JAN 01', '2018 APR 01'; ...
'psp47', '2018 APR 01', '2018 JUL 01'; ...
'psp48', '2018 JUL 01', '2018 OCT 01'; ...
'psp49', '2018 OCT 01', '2019 JAN 01'; ...
'psp50', '2019 JAN 01', '2019 APR 01'; ...
'psp51', '2019 APR 01', '2019 JUL 01'; ...
'psp52', '2019 JUL 01', '2019 OCT 01'; ...
'psp53', '2019 OCT 01', '2020 JAN 01'; ...
'psp54', '2020 JAN 01', '2020 APR 01'; ...
'psp55', '2020 APR 01', '2020 JUL 01'; ...
'psp56', '2020 JUL 01', '2020 OCT 01'; ...
'psp57', '2020 OCT 01', '2021 JAN 01'; ...
'psp58', '2021 JAN 01', '2021 APR 01'; ...
'psp59', '2021 APR 01', '2021 JUL 01'; ...
'psp60', '2021 JUL 01', '2021 OCT 01'; ...
'psp61', '2021 OCT 01', '2022 JAN 01'; ...
'psp62', '2022 JAN 01', '2022 APR 01'; ...
'psp63', '2022 APR 01', '2022 JUL 01'; ...
'psp64', '2022 JUL 01', '2022 OCT 01'  ...
};

spk_arch_dttbl = datetime(spk_arch_tbl(:,2:3),'InputFormat','yyyy MMM dd');

N = size(spk_arch_tbl,1);
spk_arch_infostruct = struct( ...
    'PHASE',      deal(spk_arch_tbl(:,1)), ...
    'START_TIME', deal(num2cell(spk_arch_dttbl(:,1))), ...
    'END_TIME',   deal(num2cell(spk_arch_dttbl(:,2)))  ...
    );

end

% save spk_arch_infostruct.mat spk_arch_infostruct