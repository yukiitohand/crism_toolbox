function [hkp] = crism_hkp_get_cols(hkp_fpath,colnames)

fid = fopen(hkp_fpath,'r');
hkp_txt = textscan(fid,'%s','Delimiter','\r\n');
hkp_txt = hkp_txt{1};
fclose(fid);
hkp_char = cat(1,hkp_txt{:});

hkp = [];
for i=1:length(colnames)
    switch upper(colnames{i})
        case 'EXPOSURE_SCLK_S'
            hkp.exposure_sclk_s = str2num(hkp_char(:,125:134));
        case 'EXPOSURE_SCLK_SS'
            hkp.exposure_sclk_ss = str2num(hkp_char(:,136:140)); 
        case 'SCAN_MOTOR_ENCPOS1'
            hkp.scan_motor_encpos1 = str2num(hkp_char(:,193:200));
        case 'SCAN_MOTOR_ENCPOS2'
            hkp.scan_motor_encpos2 = str2num(hkp_char(:,202:209));
        case 'SCAN_MOTOR_ENCPOS3'
            hkp.scan_motor_encpos3 = str2num(hkp_char(:,211:218));
        case 'EXPOSURE'
            hkp.exposure = str2num(hkp_char(:,224:227));
        case 'RATE'
            hkp.rate = str2num(hkp_char(:,228));
        otherwise
            error('COLUMN NAME %s is not implmented yet.');
    end

end