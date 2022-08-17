function [vr] = crism_get_version_from_CDR4basename(basename)
    prop = crism_getProp_basenameCDR4(basename);
    vr = prop.version;
end