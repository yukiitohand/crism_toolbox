function [hdr] = crism_lbl2hdr(lbl,varargin)
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

[ obj_file_image ] = crism_find_OBJECT_FILE_IMAGE( lbl );

if isempty(obj_file_image)
    hdr = [];
else
    hdr = [];
    hdr.samples = obj_file_image.OBJECT_IMAGE.LINE_SAMPLES;
    hdr.lines = obj_file_image.OBJECT_IMAGE.LINES;
    hdr.bands = obj_file_image.OBJECT_IMAGE.BANDS;
    
    [hdr.data_type,hdr.byte_order] = pds3_stsb2envihdr_dtbo(...
        obj_file_image.OBJECT_IMAGE.SAMPLE_TYPE,...
        obj_file_image.OBJECT_IMAGE.SAMPLE_BITS);
    
    if iscell(obj_file_image.POINTER_IMAGE)
        error('Image may have offset. This mode is not implemented yet');
    else
        hdr.header_offset = 0;
    end
    
    hdr.interleave = pds3_bst2envihdr_interleave(...
        obj_file_image.OBJECT_IMAGE.BAND_STORAGE_TYPE);
    
    if isfield(obj_file_image.OBJECT_IMAGE,'BAND_NAME')
        hdr.band_names = obj_file_image.OBJECT_IMAGE.BAND_NAME;
    end
    
    hdr.data_ignore_value = missing_constant;
    
    %% Set default bands
    % hard coded 
    if all(isfield(lbl,{'MRO_SENSOR_ID','MRO_WAVELENGTH_FILTER'}))
        switch upper(lbl.MRO_SENSOR_ID)
            case 'S'
                switch lbl.MRO_WAVELENGTH_FILTER
                    case 0
                        hdr.default_bands = [54 37 27];
                    case 1
                        hdr.default_bands = [7 4 3];
                    case 2
                        hdr.default_bands = [7 4 3];
                    case 3
                        hdr.default_bands = [10 6 4];
                    otherwise
                        error('Undefined wavelength filter id %d.', ...
                            lbl.MRO_WAVELENGTH_FILTER);
                end
            case 'L'
                switch lbl.MRO_WAVELENGTH_FILTER
                    case 0
                        hdr.default_bands = [206 361 426];
                    case 1
                        hdr.default_bands = [14 40 53];
                    case 2
                        hdr.default_bands = [18 54 68];
                    case 3
                        hdr.default_bands = [15 47 60];
                    otherwise
                        error('Undefined wavelength filter id %d.', ...
                            lbl.MRO_WAVELENGTH_FILTER);
                end

            otherwise
                error('Undefined sensor_id %s.',lbl.MRO_SENSOR_ID);
        end
    end

end




end