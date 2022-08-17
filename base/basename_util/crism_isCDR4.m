function [decision] = crism_isCDR4(basename)

prop = crism_getProp_basenameCDR4(basename);

if isempty(prop)
    decision = false;
else
    decision = true;
end

end