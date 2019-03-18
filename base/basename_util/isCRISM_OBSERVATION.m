function [decision] = isCRISM_OBSERVATION(basename)

prop = getProp_basenameOBSERVATION(basename);

if isempty(prop)
    decision = false;
else
    decision = true;
end

end