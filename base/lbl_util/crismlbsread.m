function [lbs] = crismlbsread(fpath_lbs)

fid = fopen(fpath_lbs);
cmout = '^;.*$'; % added by Yuki for read commented out parameters
lbs = []; zzz = [];
while true
    line = fgetl(fid);
    if line == -1
        break
    else
        if ~isempty(regexpi(line,cmout,'once'))
            line = line(2:end);
        end
        eqsn = strfind(line,'=');
        if ~isempty(eqsn)
            param_ori = strtrim(line(1:eqsn-1));
            param = replace(param_ori,{':',' '},'_');
            param = replace(param,{'(',')','/'},'_');
            zzz.(param) = param_ori;
            value = strtrim(line(eqsn+1:end));
            % value = rmdq(value);
            if isnan(str2double(value))
                if strcmp(value(1),'(') && ~strcmp(value(end),')')
                    while ~strcmp(value(end),')')
                        line = fgetl(fid);
                        value = [value,strtrim(line)];
                    end
                end
                lbs.(param) = value;
            else
                lbs.(param) = str2double(value);
            end
        end
    end
end
lbs.zzz = zzz;

fclose(fid);

if isfield(lbs,'BAND_NAME')
    band_name = strip(strip(lbs.BAND_NAME,'left', '('),'right',')');
    lbs.BAND_NAME = strsplit(band_name,',');
end

if isfield(lbs,'ROWNUM')
    rownum = strip(strip(lbs.ROWNUM,'left', '('),'right',')');
    lbs.ROWNUM = strsplit(rownum,',');
end


end
