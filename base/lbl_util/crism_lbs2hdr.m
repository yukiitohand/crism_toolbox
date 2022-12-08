function [hdr] = crism_lbs2hdr(lbs,varargin)
% [hdr] = crism_lbl2hdr(lbl,missing_constant)
%   extract ENVI header information from CRISM PDS3 LABEL file
%  Input Parameters
%   lbl: struct of PDS3 LABEL file
%  Output Parameters
%   hdr: ENVI header struct. If no image is found, [] is returend.
%  OPTIONAL Parameters
%   "MISSING_CONSTANT": data ignore value for ENVI header
%     (default) 65535

missing_constant = 65535;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MISSING_CONSTANT'
                missing_constant = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

if isempty(lbs)
    hdr = [];
else
    hdr = [];
    hdr.samples = lbs.LINE_SAMPLES;
    hdr.lines = lbs.LINES;
    hdr.bands = lbs.BANDS;
    
    [hdr.data_type,hdr.byte_order] = pds3_stsb2envihdr_dtbo(...
        lbs.SAMPLE_TYPE, lbs.SAMPLE_BITS);
    
    hdr.header_offset = 0;
    
    hdr.interleave = pds3_bst2envihdr_interleave(lbs.BAND_STORAGE_TYPE);
    
    if isfield(lbs,'BAND_NAME')
        band_names= strip(lbs.BAND_NAME,'both','"');
        hdr.band_names = cellfun(@(x) str2double(x), band_names);
    end

    if isfield(lbs,'ROWNUM')
        rownum = strip(lbs.ROWNUM,'both','"');
        hdr.rownum = cellfun(@(x) str2double(x), rownum);
    end
    
    hdr.data_ignore_value = missing_constant;
    
end

end