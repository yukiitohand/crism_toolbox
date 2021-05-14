function [vr] = get_version_from_CDR4basename(basename)
    prop = getProp_basenameCDR4(basename);
    vr = prop.version;
end