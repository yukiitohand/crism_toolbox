function [rgb_bands] = get_default_bands(wv_sweetspot)

[~,ri] = min(abs(wv_sweetspot-2529));
[~,gi] = min(abs(wv_sweetspot-1506));
[~,bi] = min(abs(wv_sweetspot-1080));

rgb_bands = [ri gi bi];
end