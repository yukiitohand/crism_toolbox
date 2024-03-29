function [archinfo] = mro_crism_spice_kernel_ck_crism_arch_info()

archinfo_fpath = 'mro_spice_ck_crism_arch_info.txt';
fid = fopen(archinfo_fpath,'r');
archinfo_txt = textscan(fid,'%s','Delimiter','\r\n');
archinfo_txt = archinfo_txt{1};
fclose(fid);
archinfo_char = cat(1,archinfo_txt{:});

phase      = archinfo_char(:,1:3);
start_time = archinfo_char(:,5:10);
end_time   = archinfo_char(:,12:17);


archinfo = [];
archinfo.phase = phase;
archinfo.start_time = start_time;
archinfo.end_time   = end_time;

end