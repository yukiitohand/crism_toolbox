function [propCDR] = crism_getProp_basenameCDR(basenameCDR)


if crism_isCDR4(basenameCDR)
    propCDR = crism_getProp_basenameCDR4(basenameCDR);
elseif crism_isCDR6(basenameCDR)
    propCDR = crism_getProp_basenameCDR6(basenameCDR);
else
    error('This basename %s is not either CDR4 or CDR6',basenameCDR);
end

end