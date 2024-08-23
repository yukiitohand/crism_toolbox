function [DFdata] = crism_load_DFdata4BK(BKdata)
% [DFdata1, DFdata2] = crism_load_DFdata4BK(BKdata)
%  Identify and load EDR DF (dark frame) data for given CDR BK data
%  measurement, respectively
% INPUTS
%   BKdata: CRISMdata obj of CDR BK data
% OUTPUTS
%   DFdata: CRISMdata obj of EDR DF data corresponding to the CDR BK data.


if isempty(BKdata)
    DFdata = [];
else
    BKdata.load_basenames_SOURCE_OBS();
    if isempty(BKdata.dir_SOURCE_OBS.DF)
        BKdata.load_basenames_SOURCE_OBS('dwld', 2);
    end
    DFdata = CRISMdata(BKdata.basenames_SOURCE_OBS.DF, '');
end

end

