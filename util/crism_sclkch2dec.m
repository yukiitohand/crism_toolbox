function [sclkdec,p] = crism_sclkch2dec(sclkch)

[sclk_s,sclk_ss,p] = crism_sclkch2s_ss(sclkch);
[sclkdec] = crism_sclk_s_ss2dec(sclk_s,sclk_ss);

end
