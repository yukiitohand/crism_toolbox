function [prop,data_type] = crism_getProp_basename(basename)

if ~isempty(crism_getProp_basenameOBSERVATION(basename))
    prop = crism_getProp_basenameOBSERVATION(basename);
    data_type = 'OBSERVATION';
elseif ~isempty(crism_getProp_basenameCDR4(basename))
    prop = crism_getProp_basenameCDR4(basename);
    data_type = 'CDR4';
elseif ~isempty(crism_getProp_basenameCDR6(basename))
    prop = crism_getProp_basenameCDR6(basename);
    data_type = 'CDR6';
elseif ~isempty(crism_getProp_basenameOTT(basename))
    prop = crism_getProp_basenameOTT(basename);
    data_type = 'OTT';
end

end