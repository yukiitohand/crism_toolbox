function [fldr] = crism_get_spice_folder_wext(ext)

switch lower(ext)
    case {'.bc','bc'}
        fldr = 'ck';
    case {'.tf','tf'}
        fldr = 'fk';
    case {'.ti','ti'}
        fldr = 'ik';
    case {'.tls','tls'}
        fldr = 'lsk';
    case {'.tpc','tpc'}
        fldr = 'pck';
    case {'.tsc','tsc'}
        fldr = 'sclk';
    case {'.bsp','bsp'}
        fldr = 'spk';
    otherwise
        error('Undefined kernel extension %s',ext);
end

end