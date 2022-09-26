function [valid_lines_bool] = crism_examine_valid_lines_fast(hkp_fpath)
% [valid_lines_bool] = crism_examine_valid_lines_fast(hkp_fpath)
% examine valid lines from the scan motor position
% Input parameters
%    hkp_fpath: file path to the HKP table file.
% Output parameters
%    valid_lines_bool: boolean, ith element is true if the line is valid

[scan_motor_pos1,scan_motor_pos2,scan_motor_pos3] = crism_hkp_get_scan_motor_pos(hkp_fpath);

scan_motor_pos3(scan_motor_pos3<(-2^21-1)) = scan_motor_pos3(scan_motor_pos3<(-2^21-1)) + (2^22-1);
scan_motor_pos1(scan_motor_pos1<(-2^21-1)) = scan_motor_pos1(scan_motor_pos1<(-2^21-1)) + (2^22-1);   
scan_motor_diff = abs(scan_motor_pos3- scan_motor_pos1);
valid_lines_bool = scan_motor_diff>median(scan_motor_diff)*0.6;

end