function [ obj_file_hk_table,fldnmHKTname,fldnmHKTobj] = find_OBJECT_FILE_HK_TABLE( lbl_info,varargin )
%  [ obj_file_hk_table,fldnmHKT ] = find_OBJECT_FILE_HK_TABLE( lbl_info )
%    In the lbl_info, find OBJECT_FILE struct that contains field 
%    OBJECT_[acronym of PRODUCT TYPE]_HK_TABLE
%     Inputs:
%       lbl_info: struct, LABEL of the crism image/table data
%     Outputs:
%       obj_file_hk_table: 
%         struct, having field "OBJECT_[product_type]_HK_TABLE". Normally such a struct is 
%         stored in "lbl_info.OBJECT_FILE", which could be a cell array of 
%         such structs, or just a struct if only one "OBJECT_FILE" is 
%         defined. 
%         Normally, "lbl_info.OBJECT_FILE" is searched. A sub structure of
%         LABEL file can be also used as an input. In that case, if the
%         input has the field "OBJECT_[product_type]_TABLE", then the original input is
%         returned. If nothing is found, then [] is returned.
%         Currently the first one of such structs is returned and this 
%         function does not support for lbl_info that contains multiple 
%         ones.
%       fldnmHKTname: field name of the house keeping table 
%           '[acronym of PRODUCT TYPE]_HK_TABLE'
%           'TRDR_HK_TABLE' for PRODUCT_TYPE 'TARGETED RDR'
%           'EDR_HK_TABLE'  for PRODUCT_TYPE 'EDR'
%       fldnmHKTobj: field name of the house keeping table 
%           'OBJECT_[acronym of PRODUCT TYPE]_HK_TABLE'
%           'OBJECT_TRDR_HK_TABLE' for PRODUCT_TYPE 'TARGETED RDR'
%           'OBJECT_EDR_HK_TABLE'  for PRODUCT_TYPE 'EDR'
%          
%     Optional Parameters
%        'PRODUCT_TYPE' : {'TARGETED RDR', 'EDR'} 
%           specify if lbl_info is just a sub structure of LABL file. If it
%           is just a original LABEL file, you do not have to specify.
%           

if isfield(lbl_info,'PRODUCT_TYPE')
    product_type = lbl_info.PRODUCT_TYPE;
else
    product_type = '';
end

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'PRODUCT_TYPE'
                product_type = varargin{i+1};
            otherwise
                error('The option %s is not defined',varargin{i});
        end
    end
end

switch upper(product_type)
    case 'TARGETED_RDR'
        product_type_acro = 'TRDR';
    case 'EDR'
        product_type_acro = 'EDR';
%     case ''
%         product_type_acro = '(TRDR|EDR)';
    otherwise
        fprintf('product_type %s is not valid.\n',product_type);
        obj_file_hk_table=[];
        fldnmHKTname = ''; fldnmHKTobj = '';
        return
end
fldnmHKTname =  ['POINTER_' product_type_acro '_HK_TABLE'];
fldnmHKTobj =  ['OBJECT_', product_type_acro '_HK_TABLE'];

if isfield(lbl_info,'OBJECT_FILE')
    if iscell(lbl_info.OBJECT_FILE)
        i = 1;
        flg = 1;
        L = length(lbl_info.OBJECT_FILE);
        while flg && i<=L
            if isfield(lbl_info.OBJECT_FILE{i},fldnmHKTobj)
                obj_file_hk_table = lbl_info.OBJECT_FILE{i};
                flg = 0;
            end
            i=i+1;
        end
    else
        if isfield(lbl_info.OBJECT_FILE,fldnmHKTobj)
            obj_file_hk_table = lbl_info.OBJECT_FILE;
        else
            obj_file_hk_table = [];
        end
    end
elseif isfield(lbl_info,fldnmHKTobj)
    obj_file_hk_table = lbl_info;
else
    obj_file_hk_table = [];
end

end

% function [fldnmHKT] = findFieldnameOfHKT(lbl_info,product_type_acro)
%     ptrn = ['(OBJECT', product_type_acro '_HK_TABLE)'];
%     flds = fields(lbl_info);
%     for i=1:length(flds)
%         fld = flds{i};
%         fldnmHKT = regexpi(fld,ptrn,'tokens');
%         if 
%     end
%     
% end