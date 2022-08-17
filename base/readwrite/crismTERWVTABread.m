function [ tab ] = crismTERWVTABread(dirpath,lbl)
% [ tab ] = crismTERWVTABread( dirpath,lbl )
%   Read TER WV TABLE (TAB) file and stores it in the struct.
%   Inputs
%       dirpath: path to the directory (*.tab)
%       lbl: crism LBL file
%   Outputs
%       tab: struct, having two fields
%         data - struct with the length of lines
%         colinfo - meta information of column, easy accss with column number
%         colinfo_names - meta information of column, easy accss with NAME
%         of each column
%       if no table data is found, [] is returned.


% determine obj_table
fname = lbl.WAVELENGTH_SOURCE_TABLE;
fpath = joinPath(dirpath,fname);

[data,colinfo,colinfo_names] = crismTABread_sub(fpath,lbl.OBJECT_WAVELENGTH_SOURCE_TABLE); 
tab=[];
tab.colinfo = colinfo;
tab.colinfo_names = colinfo_names;
tab.data = data;

end
