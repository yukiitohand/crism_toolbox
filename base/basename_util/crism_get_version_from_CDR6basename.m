function [vr] = get_version_from_CDR6basename(basename)
    prop = getProp_basenameCDR6(basename);
    vr = prop.version;
end