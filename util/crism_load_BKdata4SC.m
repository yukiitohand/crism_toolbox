function [BKdata1, BKdata2] = crism_load_BKdata4SC(TRRIFdata)
% [BKdata1, BKdata2] = crism_load_BKdata4SC(TRRIFdata)
%  Identify and load CDR BK (background) data for the central scan segment.
%  BKdata1 and BKdata2 are BK prior and posterior to the central scan 
%  measurement, respectively
% INPUTS
%   TRRIFdata : CRISMdata obj of the TRR3 I/F of the central scan 
%     measurement 
% OUTPUTS
%   BKdata1: CRISMdata obj of CDR BK data corresponding to the prior to the
%     central scan measurement. If none found, then it is empty
%   BKdata2: CRISMdata obj of CDR BK data corresponding to the posterior to
%     the central scan measurement. If none found, then it is empty

if isempty(TRRIFdata.basenamesCDR)
    TRRIFdata.load_basenamesCDR();
end

if any(cellfun('isempty',TRRIFdata.dir_cdr.BK))
    TRRIFdata.load_basenamesCDR('dwld',2);
end
TRRIFdata.readCDR('BK');

obs_id_scene = TRRIFdata.get_obsid;
binning_id_scene = crism_get_binning_id(TRRIFdata.lbl.PIXEL_AVERAGING_WIDTH);
wvfilter_id_scene = TRRIFdata.lbl.MRO_WAVELENGTH_FILTER;
BKdata1 = []; BKdata2 = [];
for j=1:length(TRRIFdata.cdr.BK)
    bkdata = TRRIFdata.cdr.BK(j);
    if strcmpi(bkdata.get_obsid, obs_id_scene)
        if bkdata.prop.binning == binning_id_scene && bkdata.prop.wavelength_filter == wvfilter_id_scene
            if hex2dec(bkdata.get_obs_number()) < hex2dec(TRRIFdata.get_obs_number())
                BKdata1 = [BKdata1 bkdata];
            else
                BKdata2 = [BKdata2 bkdata];
            end
        end
    end
end

end

