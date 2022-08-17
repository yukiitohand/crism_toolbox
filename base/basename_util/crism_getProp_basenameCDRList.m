function [propCDRList] = crism_getProp_basenameCDRList(basenameCDRList,level)
% [propCDRList] = crism_getProp_basenameCDRList(basenameCDRList,level)
%  get struct of CDR property from the cell array of basenames
%   Input Parameters
%     basenameCDRList: cell array of the basenameCDRs
%     level: level of the CDR
%   Output Parameters
%     propCDRList: list of CDR property struct.
if isempty(basenameCDRList)
    propCDRList = [];
else
    if ischar(basenameCDRList)
        basenameCDRList = {basenameCDRList};
    end
    for i=1:length(basenameCDRList)
        switch level
            case 4
                propCDRtmp = crism_getProp_basenameCDR4(basenameCDRList{i});
            case 6
                propCDRtmp = crism_getProp_basenameCDR6(basenameCDRList{i});
            otherwise
                error('CDR Level %d is not defined',propCDR.level);
        end
        if i==1
            propCDRList = propCDRtmp;
        else
            propCDRList(i) = propCDRtmp;
        end
    end
    
end
end