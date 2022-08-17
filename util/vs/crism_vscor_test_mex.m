dwld = 0; % set this option to 2 if you need to download the data
obs_id_test = '11739';
crism_obs = CRISMObservation(obs_id_test,'SENSOR_ID','L','Download_DDR',dwld,...
'Download_TRRIF',dwld); 

switch upper(crism_obs.info.obs_classType)
    case {'FFC'}
        basenameIF = crism_obs.info.basenameIF{1};
        basenameDDR = crism_obs.info.basenameDDR{1};
    case {'FRT','HRL','FRS','HRS','ATO'}
        basenameIF = crism_obs.info.basenameIF;
        basenameDDR = crism_obs.info.basenameDDR;
    otherwise
end

TRRIFdata = CRISMdata(basenameIF,'');

tic; crism_vscor(TRRIFdata,'save_file',1,'art',1,'additional_suffix','test','force',1); toc;