function [gltimg_mst2crm] = mastcam_calculate_crism_glt( ...
    mastcam_nn_msldem_obj,GLTdata_msldemc2crism)
% [gltimg_mast2crm] = mastcam_calculate_crism_glt( ...
%     mastcam_nn_msldem_obj,GLTdata_msldemc2crism)
% Get GLT image pointing from MASTCAM directly CRISM image using GLT image.
% INPUTS
%   mastcam_nn_msldem_obj: ENVIRasterMultBand class obj
%   GLTdata_msldemc2crism: ENVIRasterMultBandMSLDEMCproj class obj
% OUTPUTS
%   gltimg_mst2crm : glt image [L_mst x S_mst]


S_mst = mastcam_nn_msldem_obj.hdr.samples;
L_mst = mastcam_nn_msldem_obj.hdr.lines;

nn_msldem_img = mastcam_nn_msldem_obj.readimg('precision','raw');
gltxy_dem2crm = GLTdata_msldemc2crism.readimg('precision','raw');

msldemc_sofst = GLTdata_msldemc2crism.chdr.sample_offset;
msldemc_lofst = GLTdata_msldemc2crism.chdr.line_offset;
msldemc_smpls = GLTdata_msldemc2crism.chdr.samples;
msldemc_lines = GLTdata_msldemc2crism.chdr.lines;

gltimg_mst2crm = (-1) * ones(L_mst,S_mst,2,'int16');

for c=1:S_mst
    for l=1:L_mst
        if nn_msldem_img(l,c,1)>0
            ss = nn_msldem_img(l,c,1)-msldemc_sofst;
            ll = nn_msldem_img(l,c,2)-msldemc_lofst;
            if ss>0 && ss<=msldemc_smpls && ll>0 && ll<=msldemc_lines
                gltimg_mst2crm(l,c,:) = gltxy_dem2crm(ll,ss,:);
            end
        end
    end
end

end

