function [DFdata1,DFdata2] = crism_get_DFdata4SC(EDRdata,crism_obs)
% [DFdata1,DFdata2] = crism_get_DFdata4SC(EDRdata,crism_obs)
% switch EDRdata.lbl.OBSERVATION_TYPE
%     case {'FRT','HRL','HRS'}
%         obs_counter_sc = 7;
%     case {'FRS','ATO','MSP','HSP'}
%         obs_counter_sc = 1;
%     case {'FFC'}
%         obs_counter_sc = [1,3];
%     otherwise
%         error('Undefined observation class type %s',crism_obs.info.obs_classType);
% end
% if ~any(hex2dec(EDRdata.prop.obs_counter) == obs_counter_sc)
%     error('Input EDR is not a main scene image.');
% end

switch upper(EDRdata.lbl.OBSERVATION_TYPE)
    case {'FRT','HRL','HRS'}
        DFdata1 = CRISMdata(crism_obs.info.basenameDF{1},crism_obs.info.dir_edr);
        DFdata2 = CRISMdata(crism_obs.info.basenameDF{2},crism_obs.info.dir_edr);
    case {'FRS','ATO'}
        DFdata1 = CRISMdata(crism_obs.info.basenameDF{1},crism_obs.info.dir_edr);
        DFdata2 = [];
    case {'MSP','HSP'}
        DFdata1 = CRISMdata(crism_obs.info.basenameDF{1},crism_obs.info.dir_edr);
        DFdata2 = CRISMdata(crism_obs.info.basenameDF{2},crism_obs.info.dir_edr); 
    case {'FFC'}
        ffc_counter = EDRdata.prop.obs_counter;
        switch ffc_counter
            case {'01',1}
                DFdata1 = CRISMdata(crism_obs.info.basenameDF{1},crism_obs.info.dir_edr);
                DFdata2 = CRISMdata(crism_obs.info.basenameDF{2},crism_obs.info.dir_edr);
            case {'03',3}
                DFdata1 = CRISMdata(crism_obs.info.basenameDF{2},crism_obs.info.dir_edr);
                DFdata2 = CRISMdata(crism_obs.info.basenameDF{3},crism_obs.info.dir_edr);
            case {'00',0}
                DFdata1 = CRISMdata(crism_obs.info.basenameDF{1},crism_obs.info.dir_edr);
                DFdata2 = CRISMdata(crism_obs.info.basenameDF{1},crism_obs.info.dir_edr);
            case {'02',2}
                DFdata1 = CRISMdata(crism_obs.info.basenameDF{1},crism_obs.info.dir_edr);
                DFdata2 = CRISMdata(crism_obs.info.basenameDF{2},crism_obs.info.dir_edr);
        end
    otherwise
        error('Undefined observation class type %s',crism_obs.info.obs_classType);
end

end