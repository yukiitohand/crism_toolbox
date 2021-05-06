function [hdr_cat] = crism_const_cathdr(TRRdata,band_inverse,varargin)
% [hdr_cat] = crism_const_cathdr(TRRIFdata,band_inverse,varargin)
%  construct header struct to mimic _CAT.hdr
%  Input
%    TRRdata: CRISMdata obj, TRR data (RA/IF) is recommended
%    band_inverse: whether or not to invert the band or not
%  Output
%    hdr_cat: struct, for the CAT file.
%  Optional Parameters
%    'DATE_TIME': string
%       date time information
%       (default) [] (and produced within this function)

dt = [];
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'DATE_TIME'
                dt = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

if isempty(dt)
    dt = datetime('now','TimeZone','local','Format','eee MMM dd hh:mm:ss yyyy');
end

if isempty(TRRdata.basenamesCDR), TRRdata.load_basenamesCDR(); end

propTRRdata = getProp_basenameOBSERVATION(TRRdata.basename);

WAdata = TRRdata.readCDR('WA');
SWdata = getSWBWfromWA(WAdata,'SW');

wv_sweetspot = getWV_sweetspotfromSW(WAdata,'BAND_INVERSE',band_inverse,'SENSOR_ID',TRRdata.prop.sensor_id);
wv_sweetspot(wv_sweetspot==65535) = nan;
fwhm_sweetspot = getFWHM_sweetspotfromBW(WAdata,'BAND_INVERSE',band_inverse,'SENSOR_ID',TRRdata.prop.sensor_id);
fwhm_sweetspot(fwhm_sweetspot==65535) = nan;
bbl = create_crism_bbl(wv_sweetspot,TRRdata.lbl.MRO_SENSOR_ID,'BAND_INVERSE',false);

hdr_cat = [];
% dt = datetime('now','TimeZone','local','Format','eee MMM dd hh:mm:ss yyyy');
hdr_cat.description = sprintf('{CRISM DATA [%s] header editted timestamp}',dt);
% hdr_cr = TRRIFdata.hdr;
hdr_cat.samples = TRRdata.hdr.samples;
hdr_cat.lines = TRRdata.hdr.lines;
hdr_cat.bands = TRRdata.hdr.bands;
hdr_cat.header_offset = TRRdata.hdr.header_offset;
hdr_cat.file_type = 'ENVI Standard';
hdr_cat.data_type = TRRdata.hdr.data_type;
hdr_cat.interleave = TRRdata.hdr.interleave;
hdr_cat.sensor_type = 'Unknown';
hdr_cat.byte_order = TRRdata.hdr.byte_order;
switch upper(TRRdata.prop.sensor_id)
    case 'L'
        hdr_cat.default_bands = crism_get_default_bands_L(wv_sweetspot);
    case 'S'
        hdr_cat.default_bands = crism_get_default_bands_S(wv_sweetspot);
    otherwise
        error('Undefined sensor_id %s',TRRdata.prop.sensor_id);
end
hdr_cat.wavelength_units = 'Micrometers';
hdr_cat.data_ignore_value = 65535;
hdr_cat.wavelength = wv_sweetspot/1000;
hdr_cat.wavelength(isnan(hdr_cat.wavelength)) = 65535;
hdr_cat.fwhm = fwhm_sweetspot/1000;
hdr_cat.fwhm(isnan(hdr_cat.fwhm)) = 65535;
hdr_cat.bbl = bbl;

hdr_cat.cat_start_time = TRRdata.lbl.START_TIME;
[partition,sclk] = get_startsclkfromlbl(TRRdata.lbl);
sclk = round(sclk);
hdr_cat.cat_sclk_start = sprintf('%d/%010d',partition,sclk);
hdr_cat.cat_crism_obsid = propTRRdata.obs_id;
hdr_cat.cat_obs_type = propTRRdata.obs_class_type;
hdr_cat.cat_product_version = TRRdata.lbl.PRODUCT_VERSION_ID;
hdr_cat.cat_crism_detector_id = TRRdata.lbl.MRO_SENSOR_ID;
hdr_cat.cat_bin_mode = get_binning_id(TRRdata.lbl.PIXEL_AVERAGING_WIDTH);
hdr_cat.cat_wavelength_filter = TRRdata.lbl.MRO_WAVELENGTH_FILTER;
hdr_cat.cat_crism_detector_temp = TRRdata.lbl.MRO_DETECTOR_TEMPERATURE;
hdr_cat.cat_crism_bench_temp = TRRdata.lbl.MRO_OPTICAL_BENCH_TEMPERATURE;
hdr_cat.cat_crism_housing_temp = TRRdata.lbl.MRO_SPECTROMETER_HOUSING_TEMP;
hdr_cat.cat_solar_longitude = round(TRRdata.lbl.SOLAR_LONGITUDE,3);
hdr_cat.cat_pds_label_file = joinPath(TRRdata.dirpath,[TRRdata.basename,'.LBL']);
if strcmpi(TRRdata.lbl.MRO_SPECTRAL_RESAMPLING_FLAG,'ON')
    hdr_cat.cat_spectrum_resampled = 1;
elseif strcmpi(TRRdata.lbl.MRO_SPECTRAL_RESAMPLING_FLAG,'OFF')
    hdr_cat.cat_spectrum_resampled = 0;
end
hdr_cat.cat_sweetspot_wave_file = joinPath(SWdata.dirpath,[SWdata.basename '.TAB']);
hdr_cat.cat_wa_wave_file = joinPath(WAdata.dirpath,[WAdata.basename '.IMG']);
if band_inverse
    hdr_cat.cat_ir_waves_reversed = 'YES';
else
    hdr_cat.cat_ir_waves_reversed = 'NO';
end
hdr_cat.cat_photometric_correction_flag = -1;
hdr_cat.cat_atmospheric_correction_flag = -1;
hdr_cat.cat_ratio_shift_correction_flag = -1;
hdr_cat.cat_empirical_geometric_normalization_flag = -1;
hdr_cat.cat_empirical_smile_correction_flag = -1;
hdr_cat.cat_sensor_space_transform_flag = -1;
hdr_cat.cat_history = 'CAT';
hdr_cat.cat_input_files = [TRRdata.basename '.IMG'];

end

