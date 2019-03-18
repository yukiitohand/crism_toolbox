function [hdr_info] = extract_imghdr_from_lbl(lbl_info)
% [hdr_info] = extract_imghdr_from_lbl(lbl_info)
%   extract header information (envi format) from CRISM LABEL file
%  Input Parameters
%   lbl: struct of LABEL file
%  Output Parameters
%   hdr_info: struct of header in envi format, if no image is found, [] is
%             returend.

[ obj_file_image ] = find_OBJECT_FILE_IMAGE( lbl_info );

if isempty(obj_file_image)
    hdr_info = [];
else
    hdr_info = [];
    hdr_info.samples = obj_file_image.OBJECT_IMAGE.LINE_SAMPLES;
    hdr_info.lines = obj_file_image.OBJECT_IMAGE.LINES;
    hdr_info.bands = obj_file_image.OBJECT_IMAGE.BANDS;

    if strcmp(obj_file_image.OBJECT_IMAGE.SAMPLE_TYPE,'PC_REAL')
        hdr_info.data_type = 4;
        hdr_info.byte_order = 0;
    elseif strcmp(obj_file_image.OBJECT_IMAGE.SAMPLE_TYPE,'MSB_UNSIGNED_INTEGER')
        hdr_info.byte_order = 1;
        if obj_file_image.OBJECT_IMAGE.SAMPLE_BITS==16
            hdr_info.data_type = 12;
        elseif obj_file_image.OBJECT_IMAGE.SAMPLE_BITS==8
            hdr_info.data_type = 1;
        else
            error('Undefined "img_obj.OBJECT_IMAGE.SAMPLE_BITS"');
        end
    else
        error('The data type: %s is not supported.',obj_file_image.OBJECT_IMAGE.SAMPLE_TYPE);
    end

    hdr_info.header_offset = 0;
    % hdr_info.header_offset = img_obj.RECORD_BYTES;

    if strcmp(obj_file_image.OBJECT_IMAGE.BAND_STORAGE_TYPE,'LINE_INTERLEAVED')
        hdr_info.interleave = 'bil';
    elseif strcmp(obj_file_image.OBJECT_IMAGE.BAND_STORAGE_TYPE,'BAND_SEQUENTIAL')
        hdr_info.interleave = 'bsq';
    else
        error('The interleave: %s is not supported.',obj_file_image.OBJECT_IMAGE.BAND_STORAGE_TYPE);
    end
    
    if isfield(obj_file_image.OBJECT_IMAGE,'BAND_NAME')
        hdr_info.band_names = obj_file_image.OBJECT_IMAGE.BAND_NAME;
    end

end




end