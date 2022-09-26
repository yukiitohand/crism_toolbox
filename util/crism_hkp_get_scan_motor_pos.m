function [scan_motor_pos1,scan_motor_pos2,scan_motor_pos3] = crism_hkp_get_scan_motor_pos(hkp_fpath)

fid = fopen(hkp_fpath,'r');
hkp_txt = textscan(fid,'%s','Delimiter','\r\n');
hkp_txt = hkp_txt{1};
fclose(fid);
hkp_char = cat(1,hkp_txt{:});

scan_motor_pos1 = str2num(hkp_char(:,193:200));
scan_motor_pos2 = str2num(hkp_char(:,202:209));
scan_motor_pos3 = str2num(hkp_char(:,211:218));


end