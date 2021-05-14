function [tab,lbl] = crismspclibTABread(fpath)
% [tab,lbl] = crismspclibTABread(fpath)
%   read a tab file in the CRISM spectral library
% Input Parameters
%  fpath: path to the file. LABEL information is embedded in the *.tab file
% Output Parameters
%  tab: struct, having two fields
%     data - struct with the length of lines
%     colinfo - meta information of column, easy accss with column number
%     colinfo_names - meta information of column, easy accss with NAME
%     of each column
%  lbl: LABEL in a struct format

lbl = crismlblread_v2(fpath);

[ obj_file_table, obj_table ] = crism_find_OBJECT_FILE_TABLE( lbl );

[data,colinfo,colinfo_names] = crismTABread_sub(fpath,obj_table,...
    'SKIP_LINE',lbl.LABEL_RECORDS,'MODE','fast');
tab=[];
tab.colinfo = colinfo;
tab.colinfo_names = colinfo_names;
tab.data = data;


end