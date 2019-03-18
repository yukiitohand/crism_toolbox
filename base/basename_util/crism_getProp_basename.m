function [prop,data_type] = crism_getProp_basename(basename)

if ~isempty(getProp_basenameOBSERVATION(basename))
    prop = getProp_basenameOBSERVATION(basename);
    data_type = 'OBSERVATION';
elseif ~isempty(getProp_basenameCDR4(basename))
    prop = getProp_basenameCDR4(basename);
    data_type = 'CDR4';
elseif ~isempty(getProp_basenameCDR6(basename))
    prop = getProp_basenameCDR6(basename);
    data_type = 'CDR6';
elseif ~isempty(getProp_basenameOTT(basename))
    prop = getProp_basenameOTT(basename);
    data_type = 'OTT';
end

end