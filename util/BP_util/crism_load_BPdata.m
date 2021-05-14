function [BPdata1,BPdata2,BPdata_post] = crism_load_BPdata(crismdata_obj)
% [BPdata1,BPdata2,BPdata_post] = crism_load_BPdata(crismdata_obj)
%  Examine types of CDR BP data recorded in source_product_id in LBL 
%  information in crismdata_obj and return each BP data as a CRISMdata 
%  object.
%  INPUTS
%   crismdata_obj: CRISMdata obj, whose "lbl" is required to have 
%                  a field 'SOURCE_PRODUCT_ID'.
%  OUTPUTS
%   BPdata1: CDR BP data (may be an array or an empty array), 
%            created based on a prior dark measurement
%   BPdata2: CDR BP data (may be an array or an empty array), 
%            created based on a post dark measurement
%   BPdata_post: CDR BP data (may be an array), 
%            created based also on scene measurement
%


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
if isempty(crismdata_obj.basenames_SOURCE_OBS)
    crismdata_obj.load_basenames_SOURCE_OBS();
end

propCRISMdata = crismdata_obj.prop;
obs_counterCRISMdata = propCRISMdata.obs_counter;


propDF = crism_create_propOBSbasename();
propDF.obs_class_type = propCRISMdata.obs_class_type;
propDF.ob_id = propCRISMdata.obs_id;
propDF.sensor_id = propCRISMdata.sensor_id;
propDF.activity_id = 'DF';
propDF.product_type = 'EDR';
DFptrn = crism_get_basenameOBS_fromProp(propDF);

% propEDRSC = crism_create_propOBSbasename();
% propEDRSC.obs_class_type = propCRISMdata.obs_class_type;
% propEDRSC.ob_id = propCRISMdata.obs_id;
% propEDRSC.sensor_id = propCRISMdata.sensor_id;
% propEDRSC.activity_macro_num = propCRISMdata.activity_macro_num;
% propEDRSC.activity_id = 'SC';
% propEDRSC.product_type = 'EDR';
% EDRSCptrn = crism_get_basenameOBS_fromProp(propEDRSC);

EDRSCptrn = crismdata_obj.basenames_SOURCE_OBS.SC;

% read bad pixel data
crismdata_obj.readCDR('BP');
for i=1:length(crismdata_obj.cdr.BP)
    bpdata = crismdata_obj.cdr.BP(i);
    basename_edrsc = extractMatchedBasename_v2(EDRSCptrn,bpdata.lbl.SOURCE_PRODUCT_ID); 
    if ~isempty(basename_edrsc)
        BPdata_post = [BPdata_post bpdata];
    else
        basename_df = extractMatchedBasename_v2(DFptrn,bpdata.lbl.SOURCE_PRODUCT_ID);
        if isempty(basename_df)
            error('check %s',bpdata.basename);
        end
        propDF_test = crism_getProp_basenameOBSERVATION(basename_df);
        if hex2dec(propDF_test.obs_counter) < hex2dec(obs_counterCRISMdata)
            BPdata1 = [BPdata1 bpdata];
        elseif hex2dec(propDF_test.obs_counter) > hex2dec(obs_counterCRISMdata)
            BPdata2 = [BPdata2 bpdata];
        end
    end
end

end