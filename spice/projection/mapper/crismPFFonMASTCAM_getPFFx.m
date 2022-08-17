function [pffclx,srange,lrange] = crismPFFonMASTCAM_getPFFx(crismPFFonMASTCAMobj,x_crm,y_crm,varargin)
% [pffclx,srange,lrange] = crismPFFonMASTCAM_getPFFx(crismPFFonMASTCAMobj,x_crm,y_crm,varargin)
%  Get PFF for the given CRISM pixel (x_crm,y_crm) on MASTCAM
% INPUTS
%  crismPFFonMASTCAMobj: object of class CRISMPFFonMASTCAM
%  x_crm: sample index of the crism image for which footprint are read
%  y_crm: line index of the crism image for which footprint are read
% OUTPUTS
%  pffclx: PFF at (x_crm,y_crm) (averaged over the window if specified)
%  srange: [1x2], the sample range of the PFF in the MASTCAM pixel coordinate
%  lrange: [1x2], the line range of the PFF in the MASTCAM pixel coordinate
% OPTIONAL Parameters
%  'AVERAGE_WINDOW': [l_size,s_size]
%     (default) [1 1]
%    

validateattributes(crismPFFonMASTCAMobj,{'CRISMPFFonMASTCAM'},{});

ave_window = [1 1];
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case {'AVERAGE_WINDOW'}
                ave_window = varargin{i+1};
                % varargin_rmidx = [varargin_rmidx i i+1];
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

[L,S] = size(crismPFFonMASTCAMobj.sample_offset);

wdw_strt = max(-floor((ave_window-1)/2)+[y_crm,x_crm],[1 1]);
wdw_end = min(floor(ave_window/2)+[y_crm,x_crm],[L,S]);
xave_range = wdw_strt(2):wdw_end(2);
yave_range = wdw_strt(1):wdw_end(1);


% Read the file to get PFF around at (x_crm,y_crm)
pff = reshape(crismPFFonMASTCAMobj.PFFcell(yave_range,xave_range),[],1);
crismPxl_sofst_in = int32(reshape(crismPFFonMASTCAMobj.sample_offset(yave_range,xave_range),[],1));
crismPxl_lofst_in = int32(reshape(crismPFFonMASTCAMobj.line_offset(yave_range,xave_range),[],1));
crismPxl_smpls_in = int32(reshape(crismPFFonMASTCAMobj.samples(yave_range,xave_range),[],1));
crismPxl_lines_in = int32(reshape(crismPFFonMASTCAMobj.lines(yave_range,xave_range),[],1));

idxbool_notisempty = true([length(pff),1]);
for j=1:length(pff)
    pff{j} = double(pff{j});
    idxbool_notisempty(j) = ~isempty(pff{j});
end

pff = pff(idxbool_notisempty);
crismPxl_sofst_in = crismPxl_sofst_in(idxbool_notisempty);
crismPxl_lofst_in = crismPxl_lofst_in(idxbool_notisempty);
crismPxl_smpls_in = crismPxl_smpls_in(idxbool_notisempty);
crismPxl_lines_in = crismPxl_lines_in(idxbool_notisempty);

if ~isempty(pff)
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
        clx_sofst = int16(clx_sofst);
        clx_lofst = int16(clx_lofst);
        clx_smpls = int16(clx_smpls);
        clx_lines = int16(clx_lines);

    end

    % 
    if clx_smpls>0
        s1   = clx_sofst + 1;
        send = clx_sofst + clx_smpls;
        l1   = clx_lofst + 1;
        lend = clx_lofst + clx_lines;
        srange = [s1 send];
        lrange = [l1 lend];
    else
        srange = []; lrange = [];
    end
else
    pffclx=[]; srange=[]; lrange=[];
end

end