function [rgb_bands] = crism_get_default_bands_L(wv_sweetspot)

[~,ri] = min(abs(wv_sweetspot-2529.5));
[~,gi] = min(abs(wv_sweetspot-1506.6));
[~,bi] = min(abs(wv_sweetspot-1080.0));

rgb_bands = [ri gi bi];
end
