function [partition,sclk] = crism_get_startsclkfromlbl(lbl)
sclkstr = lbl.SPACECRAFT_CLOCK_START_COUNT;
c = sscanf(sclkstr,'%d/%f');
sclk = c(2);
partition = c(1);
end