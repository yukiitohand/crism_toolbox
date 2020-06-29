function [TRRXIFdata] = get_TRRXdata(TRRdata,vr,dir_trrx)

product_type = 'TRR';
propXIF = getProp_basenameOBSERVATION(TRRdata.basename);
propXIF.product_type = product_type;
propXIF.version = vr;
bnameXIF = get_basenameOBS_fromProp(propXIF);
TRRXIFdata = CRISMdata(bnameXIF,dir_trrx);

end