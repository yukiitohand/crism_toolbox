function [lbl_info] = crismlblread_v2(fpth_lbl)
% read CRISM lbl file
%   Input parameters
%     fpth_lbl: file path to the label file
%   Output parameters
%     lbl_info: struct with many fields (all the item in the file)
 
fid = fopen(fpth_lbl);
lbl_info = []; zzz = [];
flg_end = 0;
while ~feof(fid) && ~flg_end
    [isprm,param,value,param_ori] = readLBLComponent(fid);
    if isprm 
        if ~strcmp(param,'OBJECT')
            lbl_info.(param) = value;
            zzz.(param) = param_ori;
        else % strcmp(param,'OBJECT')
            [obj,obj_name] = readObject(fid,value);
            if isfield(lbl_info,obj_name)
                if length(lbl_info.(obj_name))==1
                    lbl_info.(obj_name) = {lbl_info.(obj_name)};
                end
                lbl_info.(obj_name) = [lbl_info.(obj_name), {obj}];
            else
                lbl_info.(obj_name) = obj;
            end
        end
    else
        if strcmpi(param,'END') % finish if it is end
            flg_end = 1;
        end
    end
end
lbl_info.zzz_original_field_names = zzz;
fclose(fid);

end


function [obj,obj_name] = readObject(fid,obj_value)
    obj_name = ['OBJECT_' obj_value];
    obj = []; zzz = [];
    flg = 1;
    while flg
        [isprm,param,value,param_ori] = readLBLComponent(fid);
        if isprm
            if strcmp(param,'OBJECT')
                [child,child_name] = readObject(fid,value);
                if isfield(obj,child_name)
                    if length(obj.(child_name))==1
                        obj.(child_name) = {obj.(child_name)};
                    end
                    obj.(child_name) = [obj.(child_name), {child}];
                else
                    obj.(child_name) = child;
                end
            else
                if strcmp(param,'END_OBJECT') && strcmp(value,obj_value)
                    flg = 0;
                else
                    obj.(param) = value;
                    zzz.(param) = param_ori;
                end
            end
        end
        if strcmp(param,'END_OBJECT') && strcmp(value,obj_value)
            flg=0;
        end
    end
    obj.zzz_original_field_names = zzz;
end