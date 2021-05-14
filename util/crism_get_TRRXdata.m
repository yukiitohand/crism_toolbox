function [TRRXIFdata] = get_TRRXdata(TRRdata,vr,dir_trrx)

[basename_trrx] = crism_get_TRRXbasename(TRRdata,vr);
TRRXIFdata = CRISMdata(basename_trrx,dir_trrx);

end