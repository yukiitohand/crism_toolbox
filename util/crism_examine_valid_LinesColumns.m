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

scan_motor_pos = [RAdata.hkt.data.SCAN_MOTOR_ENCPOS2]';
scan_motor_pos(scan_motor_pos<(-2^21-1)) = scan_motor_pos(scan_motor_pos<(-2^21-1)) + (2^22-1);    
scan_motor_diff = abs(scan_motor_pos(2:end) - scan_motor_pos(1:end-1));
valid_lines = false(RAdata.hdr.lines,1);
valid_lines(2:end) = scan_motor_diff>500;
valid_lines(1:end-1) = or(valid_lines(1:end-1),scan_motor_diff>500);
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