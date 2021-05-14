function [sclk] = crism_get_sclk_from_CDR4basename(basename)
    prop = crism_getProp_basenameCDR4(basename);
    sclk = prop.sclk;
end