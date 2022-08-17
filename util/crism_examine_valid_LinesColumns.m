function [valid_lines,valid_samples] = crism_examine_valid_LinesColumns(RAdata)
% [valid_lines,valid_samples] = crism_examine_valid_LinesColumns(RAdata)
% examine valid lines from the scan motor position
% Input parameters
%    RAdata: RA crism data
% Output parameters
%    valid_lines: boolean, ith element is true if the line is valid
%    valid_columns: boolean, ith element is true if the columns is scene
%                   pixel.
if isempty(RAdata.hkt), RAdata.readHKT(); end

scan_motor_pos3 = [RAdata.hkt.data.SCAN_MOTOR_ENCPOS3]';
scan_motor_pos1 = [RAdata.hkt.data.SCAN_MOTOR_ENCPOS1]';
scan_motor_pos3(scan_motor_pos3<(-2^21-1)) = scan_motor_pos3(scan_motor_pos3<(-2^21-1)) + (2^22-1);
scan_motor_pos1(scan_motor_pos1<(-2^21-1)) = scan_motor_pos1(scan_motor_pos1<(-2^21-1)) + (2^22-1);   
scan_motor_diff = abs(scan_motor_pos3- scan_motor_pos1);
valid_lines = scan_motor_diff>median(scan_motor_diff)*0.6;
% vl_idx = find(valid_lines);

% examine valid columns
[valid_samples] = crism_examine_valid_Columns(RAdata);
% if isempty(RAdata.basenamesCDR), RAdata.load_basenamesCDR(); end
% if ~isfield(RAdata.cdr,'DM'), DMdata = RAdata.readCDR('DM'); end
% DMdata = RAdata.cdr.DM;
% DMdata.readimgi();
% dm = squeeze(DMdata.img);
% valid_samples = (dm(:,300)==1);
% vs_idx = find(valid_samples);

end