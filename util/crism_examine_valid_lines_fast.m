function [valid_lines_bool] = crism_examine_valid_lines_fast(hkp_fpath,varargin)
% [valid_lines_bool] = crism_examine_valid_lines_fast(hkp_fpath)
% examine valid lines from the scan motor position
% Input parameters
%    hkp_fpath: file path to the HKP table file.
% Output parameters
%    valid_lines_bool: boolean, ith element is true if the line is valid

[scan_motor_pos1,scan_motor_pos2,scan_motor_pos3] = crism_hkp_get_scan_motor_pos(hkp_fpath);

scan_motor_pos3(scan_motor_pos3<(-2^21-1)) = scan_motor_pos3(scan_motor_pos3<(-2^21-1)) + (2^22-1);
scan_motor_pos1(scan_motor_pos1<(-2^21-1)) = scan_motor_pos1(scan_motor_pos1<(-2^21-1)) + (2^22-1);   
scan_motor_diff = abs(scan_motor_pos3 - scan_motor_pos1);
max_diff = max(scan_motor_diff);

w = double(scan_motor_diff>0.01*max_diff);

% Solve a minimization problem
L = length(scan_motor_diff);
x = ( (1:L) - 0.5*(1+L) ) ./ (0.5*L); x = x(:);

n = 3;
A = ones(L,n+1);
for i=1:n
    A(:,i+1) = legendreP(i,x);
end

Anrm = vnorms(A,1,2);
Anrmd = A ./ Anrm;

[x1] = wclad_admm_gat(Anrmd,scan_motor_diff,'W',w,'verbose','no','tol',1e-5,'maxiter',1000);

r = abs(scan_motor_diff - Anrmd*x1);


valid_lines_bool = and(r < 200,logical(w));

end