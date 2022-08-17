function [ hkt ] = crismHKTread( dirpath,lbl )
% [ hkt ] = crismHKTread( dirpath,lbl )
%   Read House Keeping Table (HKT) file and stores it in the struct.
%   Inputs
%       dirpath: path to the directory
%       lbl: crism LBL file
%   Outputs
%       hkt: struct, having two fields
%         data - struct with the length of lines
%         colinfo - meta information of column, easy accss with column number
%         colinfo_names - meta information of column, easy accss with NAME
%         of each column

[ obj_file_hk_table,fldnmHKTname,fldnmHKTobj ] = crism_find_OBJECT_FILE_HK_TABLE( lbl );

if isempty(obj_file_hk_table)
    hkt = [];
    fprintf('no hkt is found');
end

if isfield(obj_file_hk_table.(fldnmHKTobj),'POINTER_STRUCTURE')
    if ~isempty(regexpi(obj_file_hk_table.(fldnmHKTobj).POINTER_STRUCTURE,'.*HK.FMT','ONCE'))
        fmtfname = obj_file_hk_table.(fldnmHKTobj).POINTER_STRUCTURE;
        [ fmt ] = crismHKFMTread( lbl.PRODUCT_TYPE,'Fname',fmtfname);
        obj_file_hk_table.(fldnmHKTobj).OBJECT_COLUMN = fmt.OBJECT_COLUMN;
    end
end

fname = obj_file_hk_table.(fldnmHKTname);
fpath = joinPath(dirpath,fname);
obj_HKT = obj_file_hk_table.(fldnmHKTobj);

[data,colinfo,colinfo_names] = crismTABread_sub(fpath,obj_HKT);

hkt = [];
hkt.colinfo = colinfo;
hkt.colinfo_names = colinfo_names;
hkt.data = data;


end


