function [basenameCDR] = get_basenameCDR_fromProp(propCDR)

switch propCDR.level
    case 4
        basenameCDR = get_basenameCDR4_fromProp(propCDR);
    case 6
        basenameCDR = get_basenameCDR6_fromProp(propCDR);
    otherwise
        error('This property is not either CDR4 or CDR6');
end

end