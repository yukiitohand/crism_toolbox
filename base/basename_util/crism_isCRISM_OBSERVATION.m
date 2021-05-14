function [decision] = crism_isCRISM_OBSERVATION(basename)

prop = crism_getProp_basenameOBSERVATION(basename);

if isempty(prop)
    decision = false;
else
    decision = true;
end

end