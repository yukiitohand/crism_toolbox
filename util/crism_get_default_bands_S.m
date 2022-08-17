function [rgb_bands] = crism_get_default_bands_S(wv_sweetspot,mode)

switch mode
    case 1
        [~,ri] = min(abs(wv_sweetspot-709.7));
        [~,gi] = min(abs(wv_sweetspot-598.9));
        [~,bi] = min(abs(wv_sweetspot-533.7));
    case 2
        [~,ri] = min(abs(wv_sweetspot-592));
        [~,gi] = min(abs(wv_sweetspot-533));
        [~,bi] = min(abs(wv_sweetspot-492));
    case 3
        [~,ri] = min(abs(wv_sweetspot-640));
        [~,gi] = min(abs(wv_sweetspot-554));
        [~,bi] = min(abs(wv_sweetspot-495));
    case 4
        [~,ri] = min(abs(wv_sweetspot-600));
        [~,gi] = min(abs(wv_sweetspot-554));
        [~,bi] = min(abs(wv_sweetspot-495));

end

rgb_bands = [ri gi bi];

end