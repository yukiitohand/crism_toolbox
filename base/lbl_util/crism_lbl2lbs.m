function [lbs] = crism_lbl2lbs(lbl)

hdr = crism_lbl2hdr(lbl);
[SAMPLE_TYPE,SAMPLE_BITS] = envihdr_dtbo2pds3_stsb(hdr.data_type,hdr.byte_order);
BAND_STORAGE_TYPE = envihdr_interleave2pds3_bst(hdr.interleave);

char_w_dq = @(x) ['"' strip(x,'both','"') '"'];

lbs = [];
lbs.LINES        = hdr.lines;
lbs.LINE_SAMPLES = hdr.samples;
lbs.SAMPLE_TYPE  = SAMPLE_TYPE;
lbs.BANDS        = hdr.bands;
lbs.BAND_STORAGE_TYPE = BAND_STORAGE_TYPE;
lbs.SAMPLE_BITS       = SAMPLE_BITS;
lbs.UNIT = '';
lbs.START_TIME = lbl.START_TIME;
lbs.STOP_TIME  = lbl.STOP_TIME;
lbs.SPACECRAFT_CLOCK_START_COUNT = char_w_dq(lbl.SPACECRAFT_CLOCK_START_COUNT);
lbs.SPACECRAFT_CLOCK_STOP_COUNT  = char_w_dq(lbl.SPACECRAFT_CLOCK_STOP_COUNT);
lbs.SOLAR_DISTANCE           = lbl.SOLAR_DISTANCE.value;
lbs.SOLAR_LONGITUDE          = lbl.SOLAR_LONGITUDE;
lbs.OBSERVATION_TYPE         = char_w_dq(lbl.OBSERVATION_TYPE);
lbs.OBSERVATION_ID           = char_w_dq(lbl.OBSERVATION_ID);
lbs.MRO_SENSOR_ID            = char_w_dq(lbl.MRO_SENSOR_ID);
lbs.MRO_OBSERVATION_NUMBER   = char_w_dq(lbl.MRO_OBSERVATION_NUMBER);
lbs.MRO_WAVELENGTH_FILE_NAME = char_w_dq(lbl.MRO_WAVELENGTH_FILE_NAME);
lbs.MRO_DETECTOR_TEMPERATURE = lbl.MRO_DETECTOR_TEMPERATURE;
lbs.MRO_OPTICAL_BENCH_TEMPERATURE = lbl.MRO_OPTICAL_BENCH_TEMPERATURE;
lbs.MRO_SPECTROMETER_HOUSING_TEMP = lbl.MRO_SPECTROMETER_HOUSING_TEMP;
pos_dot = strfind(lbl.MRO_WAVELENGTH_FILE_NAME,'.');
if ~isempty(pos_dot)
    basenameWA = lbl.MRO_WAVELENGTH_FILE_NAME(1:pos_dot-1);
    WAdata = CRISMdata(basenameWA,'');
    SWdata = crism_getSWBWfromWA(WAdata,'SW');
    lbs.MRO_SWEET_SPOT_WAVELENGTH_FILE_NAME = [SWdata.basename '.TAB'];
    
    BWdata = crism_getSWBWfromWA(WAdata,'BW');
    lbs.MRO_SWEET_SPOT_BANDPASS_FILE_NAME = [BWdata.basename '.TAB'];
else
    lbs.MRO_SWEET_SPOT_WAVELENGTH_FILE_NAME = '';
    lbs.MRO_SWEET_SPOT_BANDPASS_FILE_NAME   = '';
end
end