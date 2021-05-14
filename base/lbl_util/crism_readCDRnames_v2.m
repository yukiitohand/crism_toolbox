function [cdr_basenames] = crism_readCDRnames_v2(lbl)    
% read names of CDR file using lbl file.
cdr_basenames = [];

if isfield(lbl,'SOURCE_PRODUCT_ID') && iscell(lbl.SOURCE_PRODUCT_ID)
    for i=1:length(lbl.SOURCE_PRODUCT_ID)
        name = lbl.SOURCE_PRODUCT_ID{i};
        if crism_isCDR4(name)
            prop = crism_getProp_basenameCDR4(name);
        elseif crism_isCDR6(name)
            prop = crism_getProp_basenameCDR6(name);
        else
            prop = [];
        end
        if ~isempty(prop)
            productID = prop.acro_calibration_type;
            cdr_basenames = addField(cdr_basenames,productID,name);
        end
    end
end

% wavelength and spectral response function.
if isfield(lbl,'MRO_WAVELENGTH_FILE_NAME')
    wavelength_file = lbl.MRO_WAVELENGTH_FILE_NAME;
    propWA = crism_getProp_basenameCDR4(wavelength_file);
    basenameWA = crism_get_basenameCDR4_fromProp(propWA);
    cdr_basenames.(propWA.acro_calibration_type) = basenameWA;
    if strcmpi(propWA.acro_calibration_type,'WA')
        propSB = propWA;
        propSB.acro_calibration_type = 'SB';
        basenameSB = crism_get_basenameCDR4_fromProp(propSB);
        cdr_basenames.SB = basenameSB;
    end
end
% pixel_proc_file
if ~isfield(cdr_basenames,'PP')
    if isfield(lbl,'MRO_PIXEL_PROC_FILE_NAME')
        pp_file = lbl.MRO_PIXEL_PROC_FILE_NAME;
        propPP = crism_getProp_basenameCDR6(pp_file);
        basenamePP = crism_get_basenameCDR6_fromProp(propPP);
        cdr_basenames.PP = basenamePP;
    end
end
% inverse lookup table file
if ~isfield(cdr_basenames,'LI')
    if isfield(lbl,'MRO_PIXEL_PROC_FILE_NAME')
        li_file = lbl.MRO_PIXEL_PROC_FILE_NAME;
        propLI = crism_getProp_basenameCDR6(li_file);
        basenameLI = crism_get_basenameCDR6_fromProp(propLI);
        cdr_basenames.LI = basenameLI;
    end
end

end
