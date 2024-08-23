function [sclk_s,sclk_ss,p] = crism_sclkch2s_ss(sclkch)

sclk_ch_ptrn = '^\s*(?<partition>\d+)/(?<sclk_s>\d+)[:.]{1}(?<sclk_ss>\d+)\s*$';
sclk_mtch = regexp(sclkch,sclk_ch_ptrn,'names','once');

if ~isempty(sclk_mtch)
    if isstruct(sclk_mtch)
        p       = str2double(sclk_mtch.partition);
        sclk_s  = str2double(sclk_mtch.sclk_s);
        sclk_ss = str2double(sclk_mtch.sclk_ss);
    elseif iscell(sclk_mtch)
        sclk_mtch = [sclk_mtch{:}];
        p       = cellfun(@(x) str2double(x), {sclk_mtch.partition});
        sclk_s  = cellfun(@(x) str2double(x), {sclk_mtch.sclk_s});
        sclk_ss = cellfun(@(x) str2double(x), {sclk_mtch.sclk_ss});
    else
        p = []; sclk_s = []; sclk_ss = [];
    end
else
    p = []; sclk_s = []; sclk_ss = [];
end

end