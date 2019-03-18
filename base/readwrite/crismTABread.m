function [ tab ] = crismTABread(fdpath,lbl)
% [ tab ] = crismTABread( dirpath,lbl )
%   Read TABLE (TAB) file and stores it in the struct.
%   Inputs
%       fdpath: path to the directory or file (*.tab)
%       lbl: crism LBL file
%   Outputs
%       tab: struct, having two fields
%         data - struct with the length of lines
%         colinfo - meta information of column, easy accss with column number
%         colinfo_names - meta information of column, easy accss with NAME
%         of each column
%       if no table data is found, [] is returned.


% determine obj_table
[ obj_file_table, obj_table ] = find_OBJECT_FILE_TABLE( lbl );

if ~isempty(obj_file_table)
    if exist(fdpath,'dir')==7 % isdir
        fname = obj_file_table.TABLE;
        fpath = joinPath(fdpath,fname);
    elseif (exist(fdpath,'file') == 2)
        fpath = fdpath;
    else
        error('Something wrong with fdpath:%s',fdpath);
    end
    obj_TAB = obj_file_table.OBJECT_TABLE;

    [data,colinfo,colinfo_names] = crismTABread_sub(fpath,obj_TAB); 

    tab=[];
    tab.colinfo = colinfo;
    tab.colinfo_names = colinfo_names;
    tab.data = data;
else
    if ~isempty(obj_table)
        [data,colinfo,colinfo_names] = crismTABread_sub(fdpath,obj_table);
        tab=[];
        tab.colinfo = colinfo;
        tab.colinfo_names = colinfo_names;
        tab.data = data;
    else
        tab = [];
    end
end

end



