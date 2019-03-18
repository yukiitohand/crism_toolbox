function [sclk] = get_sclk_from_CDR4basename(basename)
    prop = getProp_basenameCDR4(basename);
    sclk = prop.sclk;
end