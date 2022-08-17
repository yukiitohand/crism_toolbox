function [sl_crm_out,crismFOVcell_out,srange,lrange,pffval] = mapper_mastcam2crism_get_crismFOVcell( ...
    x_mst,y_mst,crismpffonmastcam_obj,varargin)
% [sl_crm_out,crismFOVcell_out,srange,lrange] = mapper_mastcam2crism_get_crismFOVcell( ...
%     x_mst,y_mst,crismpffonmsldem_obj,varargin)
%  Find the footprint of CRISM pixels that are associated with the input coordinate 
%  (x_mst, y_mst) in the MASTCAM camera image plane.
% INPUTS
%   x_mst: scalar, x coordinate in the MASTCAM image.
%   y_mst: scalar, y coordinate in the MASTCAM image.
%   crismpffonmsldem_obj: object of CRISMPFFonMASTCAM class
% OUTPUTS
%   sl_crm_out: [* x 2] array, storing indices of the 
%   crismFOVcell_out: cell array of the crism pixel footprint function
%   associated with xy_crm_out
% Optional Parameters
%  "THRESHOLD": numeric or "MAX"
%    the value of PFF larger than this is considered as valid. In case
%    "MAX", only the PFF with maximum reponse is retrieved.
%     (default) 0.5
%    
%   

thresh = 0.5;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            % ## PROCESSING OPTIONS #--------------------------------------
            case {'THRESHOLD'}
                thresh = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

crismFOV_s1   = crismpffonmastcam_obj.sample_offset + 1;
crismFOV_send = crismpffonmastcam_obj.sample_offset + crismpffonmastcam_obj.samples;

crismFOV_l1   = crismpffonmastcam_obj.line_offset + 1;
crismFOV_lend = crismpffonmastcam_obj.line_offset + crismpffonmastcam_obj.lines;

[rows,cols] = find( ...
    and( ...
            and(x_mst>=crismFOV_s1,x_mst<=crismFOV_send), ...
            and(y_mst>=crismFOV_l1,y_mst<=crismFOV_lend) ...
        ) ...
    );
N = length(rows); 
sl_crm_out = []; crismFOVcell_out = []; srange = []; lrange = [];
if isnumeric(thresh)
    resList = [];
    for i=1:N
        row = rows(i); col = cols(i);
        [crismFOV_n,srange_n,lrange_n] = crismpffonmastcam_obj.getPFF(col,row);
        res = crismFOV_n(y_mst-crismpffonmastcam_obj.line_offset(row,col),x_mst-crismpffonmastcam_obj.sample_offset(row,col));

        if res>thresh
            sl_crm_out = [sl_crm_out;[col row]];
            crismFOVcell_out = [crismFOVcell_out,{crismFOV_n}];
            srange = [srange;srange_n];
            lrange = [lrange;lrange_n];
            resList = [resList res];
        end
    end
    
    % sort by PFF response value.
    [pffval,isort] = sort(resList,'desc');
    sl_crm_out = sl_crm_out(isort,:);
    crismFOVcell_out = crismFOVcell_out(isort);
    srange = srange(isort,:);
    lrange = lrange(isort,:);
    
    
elseif ischar(thresh) && strcmpi(thresh,'MAX')
    res_max = 0;
    for i=1:N
        row = rows(i); col = cols(i);
        [crismFOV_n,srange_n,lrange_n] = crismpffonmastcam_obj.getPFF(col,row);
        res = crismFOV_n(y_mst-crismpffonmastcam_obj.line_offset(row,col),x_mst-crismpffonmastcam_obj.sample_offset(row,col));

        if res>res_max
            res_max = res;
            sl_crm_out = [col row];
            crismFOVcell_out = {crismFOV_n};
            srange = srange_n;
            lrange = lrange_n;
        end
    end
    pffval = res_max;
    
else
    error('Invalid "THRESHOLD"');
    
end
    


end