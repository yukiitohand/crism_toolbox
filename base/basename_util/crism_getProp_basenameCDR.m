function [propCDR] = getProp_basenameCDR(basenameCDR)


if isCDR4(basenameCDR)
    propCDR = getProp_basenameCDR4(basenameCDR);
elseif isCDR6(basenameCDR)
    propCDR = getProp_basenameCDR6(basenameCDR);
else
    error('This basename %s is not either CDR4 or CDR6',basenameCDR);
end

end