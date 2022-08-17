function [sclk] = crism_get_sclk_from_CDR6basename(basename)
    prop = crism_getProp_basenameCDR6(basename);
    sclk = prop.sclk;
end