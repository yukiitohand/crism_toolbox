function [BPdata1,BPdata2,BPdata_post] = load_BPdata(crismdata_obj)

BPdata1 = []; BPdata2 = []; BPdata_post = [];

if ~isfield(crismdata_obj.lbl,'SOURCE_PRODUCT_ID')
    error('The input data seems not to be TRR3 data');
end
if isempty(crismdata_obj.basenamesCDR)
    crismdata_obj.load_basenamesCDR();
end
if ~isfield(crismdata_obj.basenamesCDR,'BP')
    error('The input data seems not to be TRR3 data');
end


propCRISMdata = crismdata_obj.prop;
obs_counterCRISMdata = propCRISMdata.obs_counter;


propDF = create_propOBSbasename();
propDF.obs_class_type = propCRISMdata.obs_class_type;
propDF.ob_id = propCRISMdata.obs_id;
propDF.sensor_id = propCRISMdata.sensor_id;
propDF.activity_id = 'DF';
propDF.product_type = 'EDR';
DFptrn = get_basenameOBS_fromProp(propDF);

propEDRSC = create_propOBSbasename();
propEDRSC.obs_class_type = propCRISMdata.obs_class_type;
propEDRSC.ob_id = propCRISMdata.obs_id;
propEDRSC.sensor_id = propCRISMdata.sensor_id;
propEDRSC.activity_macro_num = propCRISMdata.activity_macro_num;
propEDRSC.activity_id = 'SC';
propEDRSC.product_type = 'EDR';
EDRSCptrn = get_basenameOBS_fromProp(propEDRSC);

% read bad pixel data
crismdata_obj.readCDR('BP');
for i=1:length(crismdata_obj.cdr.BP)
    bpdata = crismdata_obj.cdr.BP(i);
    basename_edrsc = extractMatchedBasename_v2(EDRSCptrn,bpdata.lbl.SOURCE_PRODUCT_ID); 
    if ~isempty(basename_edrsc)
        BPdata_post = bpdata;
    else
        basename_df = extractMatchedBasename_v2(DFptrn,bpdata.lbl.SOURCE_PRODUCT_ID);
        if isempty(basename_df)
            error('check %s',bpdata.basename);
        end
        propDF_test = getProp_basenameOBSERVATION(basename_df);
        if hex2dec(propDF_test.obs_counter) < hex2dec(obs_counterCRISMdata)
            BPdata1 = bpdata;
        elseif hex2dec(propDF_test.obs_counter) > hex2dec(obs_counterCRISMdata)
            BPdata2 = bpdata;
        end
    end
end

end