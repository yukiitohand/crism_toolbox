function [fldtp] = assessCDRForderType(acro)
%    Acronyms of the products stored in "edr/CDR/YYYY_DOY/" folder
%      ATF,BI,BK,BP,SP,ST,UB
%    Acronyms of the products stored in "edr/CDR" directly
%      AS, AT, BS, BW, CM, CT, DB, DM, EB, FFC, GH, HD, HK, HV, LC, LI,
%      LK, LL, MSV, NU, PC, PP, PS, RF, RT, RW, SB, SC, SF, SH, SL, SS, SW,
%      TD, VL, WA, WV
%    Acronyms of the products storeed in "CAT_ENVI/aux_files/CDRs"
%      AT, BW, CT, RF, RT, RW, SF, SS, SW, WA, WC, WV
%    

acro_cdr_YYYY_DOY_List = {'ATF','BI','BK','BP','SP','ST','UB'};
acro_cdr_others_List = ...
    {'AS','AT','BS','BW','CM','CT','DB','DM','EB','FFC','GH','HD','HK',...
     'HV','LC','LI','LK','LL','MSV','NU','PC','PP','PS','RF','RT','RW',...
     'SB','SC','SF','SH','SL','SS','SW','TD','VL','WA','WV'};
acro_cdr_CAT_ENVI_auxList = {'AT','BW','CT','RF','RT','RW','SF','SS','SW','WA','WC','WV'};

if any(cellfun(@(x) strcmpi(acro,x),acro_cdr_YYYY_DOY_List))
    fldtp = 1;
elseif any(cellfun(@(x) strcmpi(acro,x),acro_cdr_others_List))
    fldtp = 2;
elseif any(cellfun(@(x) strcmpi(acro,x),acro_cdr_CAT_ENVI_auxList))
    fldtp = 3;
else
    error('The acronym %s may be wrong',acro);
end

end