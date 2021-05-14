function [decision] = isCDR4(basename)

prop = getProp_basenameCDR4(basename);

if isempty(prop)
    decision = false;
else
    decision = true;
end

end