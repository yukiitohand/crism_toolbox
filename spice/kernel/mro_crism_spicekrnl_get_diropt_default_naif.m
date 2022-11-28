function [diropt] = mro_crism_spicekrnl_get_diropt_default_naif()

diropt = [];
diropt.sclk = 'PDS';
diropt.fk   = 'PDS';
diropt.ik   = 'PDS';
diropt.lsk  = 'PDS';
diropt.pck  = 'PDS';
diropt.spk_de   = 'PDS';
diropt.spk_sc   = 'PDS';
diropt.ck_sc    = 'PDS';
diropt.ck_crism = 'PDS';

end