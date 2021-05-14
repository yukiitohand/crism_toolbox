function [cdr_basenames] = readWASBbasename(lbl)

cdr_basenames = [];
% wavelength and spectral response function.
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