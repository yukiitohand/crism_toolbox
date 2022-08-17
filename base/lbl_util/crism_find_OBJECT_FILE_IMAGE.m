function [ obj_file_image ] = crism_find_OBJECT_FILE_IMAGE( lbl_info )
%  [ obj_file_image ] = crism_find_OBJECT_FILE_IMAGE( lbl_info )
%    In the lbl_info, find OBJECT_FILE struct that contains field 
%    OBJECT_IMAGE
%     Inputs:
%       lbl_info: struct, LABEL of the crism image/table data
%     Outputs:
%       obj_file_image: 
%         struct, having field "OBJECT_IMAGE". Normally such a struct is 
%         stored in "lbl_info.OBJECT_FILE", which could be a cell array of 
%         such structs, or just a struct if only one "OBJECT_FILE" is 
%         defined. 
%         Normally, "lbl_info.OBJECT_FILE" is searched. A sub structure of
%         LABEL file can be also used as an input. In that case, if the
%         input has the field "OBJECT_IMAGE", then the original input is
%         returned. If nothing is found, then [] is returned.
%         Currently the first one of such structs is returned and this 
%         function does not support for lbl_info that contains multiple 
%         ones.

if isfield(lbl_info,'OBJECT_FILE')
    if iscell(lbl_info.OBJECT_FILE)
        i = 1;
        flg = 1;
        L = length(lbl_info.OBJECT_FILE);
        while flg && i<=L
            if isfield(lbl_info.OBJECT_FILE{i},'OBJECT_IMAGE')
                obj_file_image = lbl_info.OBJECT_FILE{i};
                flg = 0;
            end
            i=i+1;
        end
    else
        if isfield(lbl_info.OBJECT_FILE,'OBJECT_IMAGE')
            obj_file_image = lbl_info.OBJECT_FILE;
        else
            obj_file_image = [];
        end
    end
elseif isfield(lbl_info,'OBJECT_IMAGE')
    obj_file_image = lbl_info;
else
    obj_file_image = [];
end

end

