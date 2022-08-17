function [propCDRmrb,idx_mrb,psclk_mrb] = crism_find_psclk_mrb_fromCDRpropList(propCDRList,propCDRref)
%  [propCDRmrb,idx_mrb,psclk_mrb] = crism_find_psclk_mrb_fromCDRpropList(propCDRList,propCDRref)
%   find the most recent CDR property before the reference CDR. Note that
%   partition is also considered. psclk means partition sclk
%  Input Parameters
%    propCDRList: list of the CDR property
%    propCDRref: reference CDR property
%  Output Parameters
%    propCDRmrb: CDR property most recent before the reference
%    idx_mrb: idx of the most recent before the reference
%    psclk_mrb: (partition*10^10+sclk) at the most recent before the reference CDR

propCDRmrb = [];idx_mrb = []; psclk_mrb = [];
if ~isempty(propCDRList)
    psclkList = [propCDRList.sclk];%+10^10*[propCDRList.partition];
    psclk_ref = propCDRref.sclk;%+10^10*propCDRref.partition;
    [psclk_mrb,idx_mrb] = maxleq(psclkList,psclk_ref);
    if ~isempty(psclk_mrb)
        propCDRmrb = propCDRList(idx_mrb);
    end
end

end
