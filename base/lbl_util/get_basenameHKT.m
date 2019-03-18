function [ basenameHKT ] = get_basenameHKT( lbl )
% [ basenameHKT ] = get_basenameHKT( lbl )
%  get basename of HKT file from lbl
%   INPUT: lbl, label struct of CRISM data
%   OUTPUT : basenameHKT

[ obj_file_hk_table,fldnmHKTname,fldnmHKTobj ] = find_OBJECT_FILE_HK_TABLE( lbl );

if isempty(obj_file_hk_table)
    basenameHKT = '';
    fprintf('no hkt is found.\n');
    return;
end

if isfield(obj_file_hk_table.(fldnmHKTobj),'STRUCTURE')
    if ~isempty(regexpi(obj_file_hk_table.(fldnmHKTobj).STRUCTURE,'.*HK.FMT','ONCE'))
        fmtfname = obj_file_hk_table.(fldnmHKTobj).STRUCTURE;
        [ fmt ] = crismHKFMTread( lbl.PRODUCT_TYPE,'Fname',fmtfname);
        obj_file_hk_table.(fldnmHKTobj).OBJECT_COLUMN = fmt.OBJECT_COLUMN;
    end
end

filenameHKT = obj_file_hk_table.(fldnmHKTname);

[~,basenameHKT,~] = fileparts(filenameHKT);

end