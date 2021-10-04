function [pffclx,srange,lrange] = crismPFFonMSLDEM_getPFFx(crismPFFmsldemObj,x_crm,y_crm,varargin)
% [pffclx,srange,lrange] = crismPFFonMSLDEM_getPFFx(crismPFFmsldemObj,x_crm,y_crm,varargin)
%  Get PFF for the given CRISM pixel (x_crm,y_crm)
% INPUTS
%  crismPFFmsldemObj: object of class CRISMPFFonMSLDEM
%  x_crm: sample index of the crism image for which footprint are read
%  y_crm: line index of the crism image for which footprint are read
% OUTPUTS
%  pffclx: PFF at (x_crm,y_crm) (averaged over the window if specified)
%  srange: [1x2], the sample range of the PFF in the MSLDEM pixel coordinate
%  lrange: [1x2], the line range of the PFF in the MSLDEM pixel coordinate
% OPTIONAL Parameters
%  'AVERAGE_WINDOW': [l_size,s_size]
%     (default) [1 1]
%  'XY_COORDINATE': the coordinate of output range {'PIXEL','NE','LATLON'}
%     (default) 'PIXEL'
%    

validateattributes(crismPFFmsldemObj,{'CRISMPFFonMSLDEM'},{});

ave_window = [1 1];
xy_coord = 'PIXEL';
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case {'AVERAGE_WINDOW'}
                ave_window = varargin{i+1};
                % varargin_rmidx = [varargin_rmidx i i+1];
            case {'XY_COORDINATE'}
                xy_coord = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

[L,S] = size(crismPFFmsldemObj.sample_offset);

wdw_strt = max(-floor((ave_window-1)/2)+[y_crm,x_crm],[1 1]);
wdw_end = min(floor(ave_window/2)+[y_crm,x_crm],[L,S]);
xave_range = wdw_strt(2):wdw_end(2);
yave_range = wdw_strt(1):wdw_end(1);


% Read the file to get PFF around at (x_crm,y_crm)
pff = [];
for y=yave_range
    bname = sprintf('%s_l%03d',crismPFFmsldemObj.basename_com,y);
    fpath = joinPath(crismPFFmsldemObj.dirpath,[bname '.mat']);
    load(fpath,'crism_FOVcell_lcomb');
    pffy = crism_FOVcell_lcomb(xave_range);
    pff = [pff; pffy];
end
pff = pff(:);
for j=1:length(pff)
    pff{j} = double(pff{j});
end
crismPxl_sofst_in = reshape(crismPFFmsldemObj.sample_offset(yave_range,xave_range),[],1);
crismPxl_lofst_in = reshape(crismPFFmsldemObj.line_offset(yave_range,xave_range),[],1);
crismPxl_smpls_in = reshape(crismPFFmsldemObj.samples(yave_range,xave_range),[],1);
crismPxl_lines_in = reshape(crismPFFmsldemObj.lines(yave_range,xave_range),[],1);

if all(ave_window==[1 1])
    pffclx = pff{1};
    clx_sofst = crismPxl_sofst_in;
    clx_lofst = crismPxl_lofst_in;
    clx_smpls = crismPxl_smpls_in;
    clx_lines = crismPxl_lines_in;
else

    [pffclx,clx_sofst,clx_smpls, clx_lofst, clx_lines] ...
        = crism_combine_FOVcell_PSF_1expo_v3_mex( ...
            pff,  ... 0
            crismPxl_sofst_in, ... 1
            crismPxl_smpls_in, ... 2
            crismPxl_lofst_in, ... 3
            crismPxl_lines_in  ... 4
        );
    pffclx = pffclx{1};
end

% 
if clx_smpls>0
    s1   = clx_sofst + 1;
    send = clx_sofst + clx_smpls;
    l1   = clx_lofst + 1;
    lend = clx_lofst + clx_lines;
    srange = [s1 send];
    lrange = [l1 lend];
    switch upper(xy_coord)
        case 'PIXEL'
        case 'NE'
            srange = crismPFFmsldemObj.MSLDEMdata.easting(double(srange));
            lrange = crismPFFmsldemObj.MSLDEMdata.northing(double(lrange));
        case 'LATLON'
            srange = crismPFFmsldemObj.MSLDEMdata.longitude(double(srange));
            lrange = crismPFFmsldemObj.MSLDEMdata.latitude(double(lrange));
        otherwise
            error('Undefined xy_coord %s',xy_coord);
    end

else
    srange = []; lrange = [];
end

end