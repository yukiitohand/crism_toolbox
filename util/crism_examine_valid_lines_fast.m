function [valid_lines_bool,scan_motor_diff,m,options] = ...
    crism_get_disconframe_mask_w_scan_motor_diff(hkp_fpath,varargin)
% [valid_lines_bool,scan_motor_diff,m,options] = ...
%     crism_get_disconframe_mask_w_scan_motor_diff(hkp_fpath,varargin)
% examine valid lines from the scan motor position
% Input parameters
%    hkp_fpath: file path to the HKP table file.
% Output parameters
%    valid_lines_bool: boolean, ith element is true if the line is valid
%    scan_motor_diff: scan_motor_movement between the start and end
%    exposure for each frame
%    m: polynomial fit on scan_motor_diff
%    options: struct having tolerance values used for the operation.
%      'TOL_PRESCREEN'
%      'TOL_ABS'
%      'TOL_RATIO'
% OPTIONAL PARAMETERS
%    'TOL_PRESCREEN': tolerance values on the ratio of scan_motor_diff with
%       respect to its close-to-maximum value.
%       (default) 0.01
%    'TOL_ABS': Allowed absolute value of the residual
%       (default) 300
%    'TOL_RATIO': allowed ratio of the residual with respect to the
%       polynomial model
%       (default) 0.3
%   Note that the evaluation of 'TOL_ABS' and 'TOL_RATIO' are integrated
%   with 'or' and prescreened lines are removed even if they passed the 
%   post evaluation.
% 

is_debug = false;
tol_r2max_prescrn = 0.01;
tol_abs = 300;
tol_ratio = 0.3;


if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'TOL_PRESCREEN'
                tol_r2max_prescrn = varargin{i+1};
            case 'TOL_ABS'
                tol_abs = varargin{i+1};
            case 'TOL_RATIO'
                tol_ratio = varargin{i+1};
            case 'DEBUG'
                is_debug = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

options = [];
options.tol_prescreen = tol_r2max_prescrn;
options.tol_abs = tol_abs;
options.tol_ratio = tol_ratio;


[scan_motor_pos1,scan_motor_pos2,scan_motor_pos3] = crism_hkp_get_scan_motor_pos(hkp_fpath);

scan_motor_pos3(scan_motor_pos3<(-2^21-1)) = scan_motor_pos3(scan_motor_pos3<(-2^21-1)) + (2^22-1);
scan_motor_pos1(scan_motor_pos1<(-2^21-1)) = scan_motor_pos1(scan_motor_pos1<(-2^21-1)) + (2^22-1);   
scan_motor_diff = abs(scan_motor_pos3 - scan_motor_pos1);
L = length(scan_motor_diff);

if L<40
    fprintf('The number of lines %d look small.\n',L);
    max_diff = maxk(scan_motor_diff,max(round(L/10),1));
else
    max_diff = maxk(scan_motor_diff,4);
end

w = double(scan_motor_diff>tol_r2max_prescrn*max_diff(end));

% Solve a minimization problem

x = ( (1:L) - 0.5*(1+L) ) ./ (0.5*L); x = x(:);

n = 3;
A = ones(L,n+1);
for i=1:n
    A(:,i+1) = legendreP(i,x);
end

Anrm = vnorms(A,1,2);
Anrmd = A ./ Anrm;

[x1] = wclad_admm_gat(Anrmd,scan_motor_diff,'W',w,'verbose','no','tol',1e-5,'maxiter',1000);
m = Anrmd*x1;
r = abs(scan_motor_diff - m);
rdivm = r ./ m;

valid_lines_bool = and(or(rdivm<tol_ratio, r < tol_abs),logical(w));

if is_debug
    figure; plot(scan_motor_diff,'.'); hold on; plot(Anrmd*x1);
    plot(scan_motor_diff.*convertBoolTo1nan(~valid_lines_bool),'rO');
    figure; plot(r,'.'); hold on; plot(r.*convertBoolTo1nan(~valid_lines_bool),'rO');

    figure; plot(rdivm,'.'); hold on; plot(rdivm.*convertBoolTo1nan(~valid_lines_bool),'rO');

    % show I/F image
    [~,basenameHKP,~] = fileparts(hkp_fpath);
    prop_trrhkp = crism_getProp_basenameOBSERVATION(basenameHKP);
    prop_trrif = prop_trrhkp;
    prop_trrif.activity_id = 'IF';
    prop_trrif.product_type = 'TRR';

    basenameTRRIF = crism_get_basenameOBS_fromProp(prop_trrif);
    TRRIFdata = CRISMdata(basenameTRRIF,'');
    switch upper(prop_trrif.sensor_id)
        case 'S'
            bref = 62;
        case 'L'
            bref = 350;
    end
    imb = TRRIFdata.lazyEnviReadb(bref);

    figure; imsc(imb); set(gca,'dataAspectRatio',[1 1 1]);
    figure; imsc(imb(valid_lines_bool,:)); set(gca,'dataAspectRatio',[1 1 1]);
    
    
    % show ddr image
    prop_ddrde = prop_trrhkp;
    prop_ddrde.activity_id = 'DE';
    prop_ddrde.product_type = 'DDR';
    prop_ddrde.version = 1;

    basenameDDRDE = crism_get_basenameOBS_fromProp(prop_ddrde);
    DEdata = CRISMDDRdata(basenameDDRDE,'');
    DEdata.readimg();
    lats_ctrcol = mean(DEdata.ddr.Latitude.img,2,'omitnan');
    lons_ctrcol = mean(DEdata.ddr.Longitude.img,2,'omitnan');
    
    rMars = 3396.19 * 10^3;
    cos_lats = cosd(lats_ctrcol); sin_lats = sind(lats_ctrcol);
    cos_lons = cosd(lons_ctrcol); sin_lons = sind(lons_ctrcol);
    xyz = rMars * [cos_lats.*cos_lons, cos_lats.*sin_lons, sin_lats];

    dist_diff = sqrt(sum((xyz(1:end-1,:) - xyz(2:end,:)).^2,2));
    dist_diff_both = min([dist_diff; nan],[nan; dist_diff],'omitnan');
    
    median(dist_diff_both(valid_lines_bool))

    figure; plot(dist_diff_both,'.'); hold on; 
    plot(dist_diff_both.*convertBoolTo1nan(~valid_lines_bool),'rO');

end

end