function crismlbswrite(lbs,lbsfile)

fid = fopen(lbsfile,'w');

fprintf(fid,'LINES             = %d\n', lbs.LINES);
fprintf(fid,'LINE_SAMPLES      = %d\n', lbs.LINE_SAMPLES);
fprintf(fid,'SAMPLE_TYPE       = %s\n', lbs.SAMPLE_TYPE);
fprintf(fid,'BANDS             = %d\n', lbs.BANDS);
fprintf(fid,'BAND_STORAGE_TYPE = %s\n', lbs.BAND_STORAGE_TYPE);
fprintf(fid,'SAMPLE_BITS       = %d\n', lbs.SAMPLE_BITS);
fprintf(fid,'UNIT              = %s\n', lbs.UNIT);
fprintf(fid,'START_TIME                    = %s\n', lbs.START_TIME);
fprintf(fid,'STOP_TIME                     = %s\n', lbs.STOP_TIME);
fprintf(fid,'SPACECRAFT_CLOCK_START_COUNT  = %s\n', lbs.SPACECRAFT_CLOCK_START_COUNT);
fprintf(fid,'SPACECRAFT_CLOCK_STOP_COUNT   = %s\n', lbs.SPACECRAFT_CLOCK_STOP_COUNT);
fprintf(fid,'SOLAR_DISTANCE                = %.6f\n', lbs.SOLAR_DISTANCE);
fprintf(fid,'SOLAR_LONGITUDE               = %.6f\n', lbs.SOLAR_LONGITUDE);
fprintf(fid,'OBSERVATION_TYPE              = %s\n', lbs.OBSERVATION_TYPE);
fprintf(fid,'OBSERVATION_ID                = %s\n', lbs.OBSERVATION_ID);
fprintf(fid,'MRO:SENSOR_ID                 = %s\n', lbs.MRO_SENSOR_ID);
fprintf(fid,'MRO:OBSERVATION_NUMBER        = %s\n', lbs.MRO_OBSERVATION_NUMBER);
fprintf(fid,'MRO:WAVELENGTH_FILE_NAME      = %s\n', lbs.MRO_WAVELENGTH_FILE_NAME);
fprintf(fid,'MRO:DETECTOR_TEMPERATURE      = %.3f\n', lbs.MRO_DETECTOR_TEMPERATURE);
fprintf(fid,'MRO:OPTICAL_BENCH_TEMPERATURE = %.3f\n', lbs.MRO_OPTICAL_BENCH_TEMPERATURE);
fprintf(fid,'MRO:SPECTROMETER_HOUSING_TEMP = %.3f\n', lbs.MRO_SPECTROMETER_HOUSING_TEMP);
fprintf(fid,'MRO:SWEET_SPOT_WAVELENGTH_FILE_NAME = %s\n', lbs.MRO_SWEET_SPOT_WAVELENGTH_FILE_NAME);
fprintf(fid,'MRO:SWEET_SPOT_BANDPASS_FILE_NAME   = %s\n', lbs.MRO_SWEET_SPOT_BANDPASS_FILE_NAME);
if isfield(lbs,'BAND_NAME')
    fprintf(fid,'BAND_NAME = (%s,\n', lbs.BAND_NAME{1});
    fprintf(fid, strjoin(cellfun(@(x) [repmat(' ', [1,13]) x],  ...
        lbs.BAND_NAME(2:end), 'UniformOutput', false),',\n'));
    fprintf(fid,')\n');
end

if isfield(lbs,'ROWNUM')
    fprintf(fid,'ROWNUM = (%s,\n', lbs.ROWNUM{1});
    fprintf(fid, strjoin(cellfun(@(x) [repmat(' ', [1,10]) x],  ...
        lbs.ROWNUM(2:end), 'UniformOutput', false),',\n'));
    fprintf(fid,')\n');
end

fclose(fid);

end

