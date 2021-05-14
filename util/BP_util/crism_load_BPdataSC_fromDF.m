function [BPdata1,BPdata2,BPdata_post] = crism_load_BPdataSC_fromDF(crismdata_obj,basename_df1_ptrn,basename_df2_ptrn)
% [BPdata1,BPdata2,BPdata_post] = crism_load_BPdataSC_fromDF(crismdata_obj,basename_df1_ptrn,basename_df2_ptrn)
%  Examine types of CDR BP data recorded in source_product_id in LBL 
%  information in crismdata_obj and return each BP data as a CRISMdata 
%  object.
%  INPUTS
%   crismdata_obj: CRISMdata obj, whose "lbl" is required to have 
%                  a field 'SOURCE_PRODUCT_ID'.
%   basename_df1_ptrn: string, regular expression for the pattern of df1
%   basename_df2_ptrn: string, regular expression for the pattern of df2
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

EDRSCptrn = crismdata_obj.basenames_SOURCE_OBS.SC;

% read bad pixel data
crismdata_obj.readCDR('BP');
for i=1:length(crismdata_obj.cdr.BP)
    bpdata = crismdata_obj.cdr.BP(i);
    basename_edrsc = extractMatchedBasename_v2(EDRSCptrn,bpdata.lbl.SOURCE_PRODUCT_ID); 
    if ~isempty(basename_edrsc)
        BPdata_post = [BPdata_post bpdata];
    else
        if ~isempty(basename_df1_ptrn)
            basename_df1 = extractMatchedBasename_v2(basename_df1_ptrn,bpdata.lbl.SOURCE_PRODUCT_ID);
            if ~isempty(basename_df1)
                BPdata1 = [BPdata1 bpdata];
            end
        end
        if ~isempty(basename_df2_ptrn)
            basename_df2 = extractMatchedBasename_v2(basename_df2_ptrn,bpdata.lbl.SOURCE_PRODUCT_ID);
            if ~isempty(basename_df2)
                BPdata2 = [BPdata2 bpdata];
            end
        end
    end
end

end