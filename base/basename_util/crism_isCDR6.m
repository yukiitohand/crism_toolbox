function [decision] = crism_isCDR6(basename)

prop = crism_getProp_basenameCDR6(basename);

if isempty(prop)
    decision = false;
else
    decision = true;
end

end