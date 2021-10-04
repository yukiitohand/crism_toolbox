function [sl_crm_out,crismFOVcell_out,srange,lrange,pffval] = mapper_msldem2crism_get_crismFOVcell( ...
    x_dem,y_dem,crismpffonmsldem_obj,varargin)
% [sl_crm_out,crismFOVcell_out,srange,lrange] = mapper_msldem2crism_get_crismFOVcell( ...
%     x_dem,y_dem,crismpffonmsldem_obj,varargin)
%  Find the footprint of CRISM pixels that are associated with the input coordinate 
%  (x_dem, y_dem) in the MSLDEM image pixel coordinate.
% INPUTS
%   x_dem: scalar, x coordinate in the MSLDEM image.
%   y_dem: scalar, y coordinate in the MSLDEM image.
%   crismpffonmsldem_obj: object of CRISMPFFonMSLDEM class
% OUTPUTS
%   xy_crm_out: [* x 2] array, storing indices of the 
%   crismFOVcell_out: cell array of the crism pixel footprint function
%   associated with xy_crm_out
% Optional Parameters
%  "XY_COORDINATE" {'NE','LATLON','PIXEL'}
%     (default) 'PIXEL'
%  "THRESHOLD": numeric or "MAX"
%    the value of PFF larger than this is considered as valid. In case
%    "MAX", only the PFF with maximum reponse is retrieved.
%     (default) 0.5
%    
%   

thresh = 0.5;
xy_coord = 'PIXEL';
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            % ## PROCESSING OPTIONS #--------------------------------------
            case {'THRESHOLD'}
                thresh = varargin{i+1};
            case 'XY_COORDINATE'
                xy_coord = varargin{i+1};
                
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

% First find the potential crism pixels that include the input index
% (x_dem,y_dem) in its PFF-enclosing rectangular window using the window
% information from (sample_offset, line_offset, samples, and lines)
crismFOV_s1   = crismpffonmsldem_obj.sample_offset + 1;
crismFOV_send = crismpffonmsldem_obj.sample_offset + crismpffonmsldem_obj.samples;

crismFOV_l1   = crismpffonmsldem_obj.line_offset + 1;
crismFOV_lend = crismpffonmsldem_obj.line_offset + crismpffonmsldem_obj.lines;

[rows,cols] = find( ...
    and( ...
            and(x_dem>=crismFOV_s1,x_dem<=crismFOV_send), ...
            and(y_dem>=crismFOV_l1,y_dem<=crismFOV_lend) ...
        ) ...
    );

% Next for each candidate of the window, get the pixels that have its pff
% larger than the threshold value.
N = length(rows); 
sl_crm_out = []; crismFOVcell_out = []; srange = []; lrange = [];
if isnumeric(thresh)
    resList = [];
    for i=1:N
        row = rows(i); col = cols(i);
        [crismFOV_n,srange_n,lrange_n] = crismpffonmsldem_obj.getPFF(col,row,xy_coord);
        res = crismFOV_n(y_dem-crismpffonmsldem_obj.line_offset(row,col),x_dem-crismpffonmsldem_obj.sample_offset(row,col));

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
        [crismFOV_n,srange_n,lrange_n] = crismpffonmsldem_obj.getPFF(col,row,xy_coord);
        res = crismFOV_n(y_dem-crismpffonmsldem_obj.line_offset(row,col),x_dem-crismpffonmsldem_obj.sample_offset(row,col));

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