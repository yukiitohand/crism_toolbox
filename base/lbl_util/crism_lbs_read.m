function [lbs] = crismlbsread(fpath_lbs)

fid = fopen(fpth_lbs);
cmout = '^;.*$'; % added by Yuki for read commented out parameters
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
            param = strtrim(line(1:eqsn-1));
            param = replace(param,{':',' '},'_');
            param = replace(param,{'(',')','/'},'_');
            value = strtrim(line(eqsn+1:end));
            if isnan(str2double(value))
                if ~isempty(strfind(value,'{')) && isempty(strfind(value,'}'))
                    while isempty(strfind(value,'}'))
                        line = fgetl(fid);
                        value = [value,strtrim(line)];
                    end
                end
                hdr.(param) = value;
            else
                hdr.(param) = str2double(value);
            end
        end
    end
end

fclose(fid);

if isfield(hdr,'band_names')
    line = hdr.band_names;
    line = line(2:end-1);
    line = strsplit(line,',');
    for i=1:length(line)
        line{i} = strtrim(line{i});
    end
    hdr.band_names = line;
end


end
