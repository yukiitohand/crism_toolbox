function [decision] = isCDR6(basename)

prop = getProp_basenameCDR6(basename);

if isempty(prop)
    decision = false;
else
    decision = true;
end

end