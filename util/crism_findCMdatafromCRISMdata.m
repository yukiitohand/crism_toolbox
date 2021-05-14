function [CMdata] = crism_findCMdatafromCRISMdata(CRISMdataobj)
% find CDR CM data from CRISMdata object
%   Input Parameters
%     CRISMdataobj: 
%   Output Parameters
%     CMdata: corresponding CMdata. CMdata is found based on its timestamp.
%             Most recent CDR before the WA timestamp is selected.
CRISMdataobj.load_basenamesCDR();
CRISMdataobj.readCDR('WA');
propCM = CRISMdataobj.cdr.WA.prop;
propCM.acro_calibration_type = 'CM';
propCM.version = '0';

[basenameCMmrb,propCMmrb] = crism_searchCDRmrb(propCM);
CMdata = CRISMdata(basenameCMmrb,'');

end