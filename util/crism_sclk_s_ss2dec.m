function [sclkdec] = crism_sclk_s_ss2dec(sclk_s,sclk_ss)
sclkdec = sclk_s + sclk_ss/(2.^16);
end