function [S] = crism_getSampleSize(binx)
if ischar(binx)
    binx = str2num(binx);
end
S = 640./binx;
end
    