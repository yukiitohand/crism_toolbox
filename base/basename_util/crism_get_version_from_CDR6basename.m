function [vr] = crism_get_version_from_CDR6basename(basename)
    prop = crism_getProp_basenameCDR6(basename);
    vr = prop.version;
end