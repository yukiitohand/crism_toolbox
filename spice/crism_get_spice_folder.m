function [fldr] = crism_get_spice_folder(kernel_name)

[~,~,ext] = fileparts(kernel_name);

[fldr] = crism_get_spice_folder_wext(ext);

end