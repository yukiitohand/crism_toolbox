function [ rownum_table ] = crismrownumtableread( imgpath,lbl )
% [ rownum_tbl ] = crismrownumtableread( imgpath,lbl )
%   Read row

[ obj_file_img ] = crism_find_OBJECT_FILE_IMAGE( lbl );
obj_rownum_tbl = obj_file_img.OBJECT_ROWNUM_TABLE;
obj_img = obj_file_img.OBJECT_IMAGE;
switch obj_rownum_tbl.OBJECT_COLUMN.DATA_TYPE
    case 'MSB_UNSIGNED_INTEGER'
        machine = 'ieee-be';
        format= 'uint16';
    otherwise
        error('DATA_TYPE: %s is not implemented',...
            obj_rownum_tbl.OBJECT_COLUMN.DATA_TYPE);
end

% offset = obj_file_img.ROWNUM_TABLE.offset;

offset = obj_img.LINES .* obj_img.LINE_SAMPLES .* obj_img.BANDS .* (obj_img.SAMPLE_BITS/8);

% bytes = obj_rownum_tbl.OBJECT_COLUMN.BYTES;

n = obj_rownum_tbl.ROWS*obj_rownum_tbl.COLUMNS;

% n1 = img_obj.RECORD_BYTES*(img_obj.FILE_RECORDS-img_obj.ROWNUM_TABLE{2}+1)/bytes;
% size(n1) >= n. The extra elements (indices larger than n) are padded with
% zeros.

% read row num table
fp = fopen(imgpath,'rb');
pointer = offset;
fseek(fp,pointer,-1);
rownum_table = fread(fp,n,format,0,machine);
fclose(fp);


end