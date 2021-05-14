function [ tab ] = crismTABread(fdpath,lbl,varargin)
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


skip_line = 0;
readmode = 'normal';
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'SKIP_LINE'
                skip_line = varargin{i+1};
            case 'MODE'
                readmode = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end


% determine obj_table
[ obj_file_table, obj_table ] = crism_find_OBJECT_FILE_TABLE( lbl );

if ~isempty(obj_file_table)
    if exist(fdpath,'dir')==7 % isdir
        fname = obj_file_table.POINTER_TABLE;
        fpath = joinPath(fdpath,fname);
    elseif (exist(fdpath,'file') == 2)
        fpath = fdpath;
    else
        error('Something wrong with fdpath:%s',fdpath);
    end
    obj_TAB = obj_file_table.OBJECT_TABLE;

    [data,colinfo,colinfo_names] = crismTABread_sub(fpath,obj_TAB,...
        'SKIP_LINE',skip_line,'MODE',readmode);

    tab=[];
    tab.colinfo = colinfo;
    tab.colinfo_names = colinfo_names;
    tab.data = data;
else
    if ~isempty(obj_table)
        [data,colinfo,colinfo_names] = crismTABread_sub(fdpath,obj_table,...
            'SKIP_LINE',skip_line,'MODE',readmode);
        tab=[];
        tab.colinfo = colinfo;
        tab.colinfo_names = colinfo_names;
        tab.data = data;
    else
        tab = [];
    end
end

end



