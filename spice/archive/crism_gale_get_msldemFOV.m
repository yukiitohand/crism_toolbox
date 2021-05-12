function [msldemc_radius,msldemc_imFOVmask,msldemc_hdr] = crism_gale_get_msldemFOV(...
    msldem_radius,latitude_rad,longitude_rad,cahv_mdl_fixref,varargin)

im_srange = [-0.5 639.5];
im_lrange = [0.0 0.0];
coef_mrgn = 2.1;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'IMAGESAMPLERANGE'
                im_srange = varargin{i+1};
            case 'IMAGELINERANGE'
                im_lrange = varargin{i+1};
            case 'COEF_MARGIN'
                coef_mrgn = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

msldem_lines = size(msldem_radius,1); msldem_samples = size(msldem_radius,2);

[msldem_imFOVmask] = crism_gale_get_msldemFOV_enclosing_rectangle_mex(msldem_radius,...
    latitude_rad,longitude_rad,cahv_mdl_fixref,im_srange,im_lrange,coef_mrgn);

msldem_imFOVmask_gt0 = msldem_imFOVmask>0;
valid_lines = find(any(msldem_imFOVmask_gt0',1));
lrnge = [max(valid_lines(1)-1,1), min(valid_lines(end)+1,msldem_lines)];
len_vl = lrnge(2)-lrnge(1)+1;
valid_samples = find(any(msldem_imFOVmask_gt0,1));
srnge = [max(valid_samples(1)-1,1), min(valid_samples(end)+1,msldem_samples)];
len_vs = srnge(2)-srnge(1)+1;

line_offset = lrnge(1)-1;
sample_offset = srnge(1)-1;

% cropping the image for the computation of sageguarding
msldemc_hdr = [];
msldemc_hdr.lines = len_vl;
msldemc_hdr.samples = len_vs;
msldemc_hdr.line_offset = line_offset;
msldemc_hdr.sample_offset = sample_offset;

msldemc_latitude_rad = latitude_rad(lrnge(1):lrnge(2));
msldemc_longitude_rad  = longitude_rad(srnge(1):srnge(2));
msldemc_hdr.latitude_rad = msldemc_latitude_rad;
msldemc_hdr.longitude_rad = msldemc_longitude_rad;

msldemc_imFOVmask = msldem_imFOVmask(lrnge(1):lrnge(2),srnge(1):srnge(2));
msldemc_imFOVmask(msldemc_imFOVmask<0) = 0;

clear msldem_imFOVmask;

msldemc_radius = msldem_radius(lrnge(1):lrnge(2),srnge(1):srnge(2));


end





    
    
    