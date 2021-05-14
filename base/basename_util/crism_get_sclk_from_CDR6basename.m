function [sclk] = get_sclk_from_CDR6basename(basename)
    prop = getProp_basenameCDR6(basename);
    sclk = prop.sclk;
end