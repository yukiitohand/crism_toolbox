function [] = tab_view(tab)

headers = join([{tab.colinfo.NAME}],'\t');
fprintf(join([headers '\n']));
for i=1:length(tab.data)
    for j=1:length(tab.colinfo)
        switch tab.colinfo(j).DATA_TYPE
            case 'CHARACTER'
                fprintf('%s',tab.data(i).(tab.colinfo(j).NAME));
            case 'ASCII_REAL'
                fprintf('%f',tab.data(i).(tab.colinfo(j).NAME));
            case 'ASCII_INTEGER'
                fprintf('%d',tab.data(i).(tab.colinfo(j).NAME));
            otherwise
                error('c=%d,DATA_TYPE %s is not defined',c,tab.colinfo{j}.DATA_TYPE);
        end
         if j<length(tab.colinfo)
             fprintf('\t');
         else
             fprintf('\n');
         end
    end
end

end